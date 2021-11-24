# CTF 6

## Desafio 1

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
+ há um *canary* a proteger o *return address* (Stack)
+ a *stack* tem permissão de execução (NX)
+ as posições do binário não estão randomizadas (PIE)
+ os *return addresses* não estão protegidos numa stack em separado (SafeStack)

### Gdb

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

### Qual é a linha do código onde a vulnerabilidade se encontra?

```c
char buffer[32];
(...)
scanf("%32s", &buffer);
```

### O que é que a vulnerabilidade permite fazer?

Permite alterar o endereço para onde buffer aponta.

### Qual é a funcionalidade que te permite obter a flag?

Alterar o endereço para o mesmo que flag?

FLAG   
 <pre>flag{5fc247063bea425edc863667ac9d09bc}</pre>
