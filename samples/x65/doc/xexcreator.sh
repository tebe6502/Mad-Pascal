#!/bin/bash

# Atari XEX file header creator with DOS segment
# Usage: ./xexcreator.sh <input.bin> <output.xex> <start_address_HEX>

# Check arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <input_file> <output_file> <start_address_HEX>"
    exit 1
fi

# File validation
input_file="$1"
output_file="$2"
start_addr_hex="${3#0x}"  # Remove 0x prefix if present

if [ ! -f "$input_file" ]; then
    echo "Error: Input file $input_file not found!"
    exit 1
fi

# Convert hex to decimal
start_addr=$((16#$start_addr_hex))
file_size=$(stat -c%s "$input_file")
end_addr=$((start_addr + file_size - 1))

# Validate addresses
if (( start_addr > 65535 )) || (( end_addr > 65535 )); then
    echo "Error: Addresses exceed 16-bit range!"
    exit 1
fi

# Little-endian conversion
to_le2() {
    printf "%b" "\\x$(printf "%02x" $(($1 & 0xFF)))"
    printf "%b" "\\x$(printf "%02x" $(($1 >> 8 & 0xFF)))"
}

# Create DOS segment
create_dos_segment() {
    printf "\xe0\xff"  # DOS segment marker

    # 32-byte pattern
    printf "\xff\xff"  # FFFF
    dd if=/dev/zero bs=1 count=28 2>/dev/null  # 28 zeros

    # Start address (4 bytes, little-endian)
    to_le2 $start_addr
    to_le2 0  # Padding
}

# Build the complete file
{
    # File header
    printf "\xff\xff"  # XEX signature
    to_le2 $start_addr
    to_le2 $end_addr

    # File content
    cat "$input_file"

    # DOS segment
    create_dos_segment
} > "$output_file"

# Verification
echo "Successfully created $output_file"
echo "Header:"
xxd -g 1 -l 6 "$output_file"
echo "DOS segment (last 36 bytes):"
xxd -g 1 -s -36 "$output_file"
echo "Start address: \$$(printf "%04x" $start_addr)"
echo "End address:   \$$(printf "%04x" $end_addr)"
echo "File size:     $file_size bytes"