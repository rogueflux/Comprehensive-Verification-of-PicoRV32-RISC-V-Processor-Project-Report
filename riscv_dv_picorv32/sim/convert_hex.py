#!/usr/bin/env python3
import sys

def intel_hex_to_plain(input_file, output_file):
    with open(input_file, 'r') as f:
        lines = f.readlines()
    
    with open(output_file, 'w') as f:
        for line in lines:
            line = line.strip()
            if line.startswith(':'):
                # Intel HEX format
                byte_count = int(line[1:3], 16)
                address = int(line[3:7], 16)
                record_type = int(line[7:9], 16)
                
                if record_type == 0:  # Data record
                    data = line[9:9+byte_count*2]
                    # Write 32-bit words (8 hex characters)
                    for i in range(0, len(data), 8):
                        if i+8 <= len(data):
                            word = data[i:i+8]
                            f.write(word + '\n')
                elif record_type == 1:  # End of file
                    break
            else:
                # Already plain hex, just copy
                f.write(line + '\n')

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python convert_hex.py <input.hex> <output.hex>")
        sys.exit(1)
    
    intel_hex_to_plain(sys.argv[1], sys.argv[2])
    print(f"Converted {sys.argv[1]} to {sys.argv[2]}")

