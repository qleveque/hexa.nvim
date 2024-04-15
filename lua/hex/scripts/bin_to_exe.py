#!/usr/bin/python3
import sys
input_file = sys.argv[1]
output_file = sys.argv[2]
with open(input_file, 'r') as f:
    bdata = f.read().strip()
bbytes = bytes(int(bdata[i:i+8], 2) for i in range(0, len(bdata), 8))
with open(output_file, 'wb') as f:
    f.write(bbytes)
