#!/bin/bash

# X65 XEX file header creator with DOS segment
# Professional version with comprehensive error handling by Deepseek
# Usage: ./xexcreator.sh <input.pas> <output.xex> <start_address_HEX>

set -eo pipefail

# Configuration - easily customizable paths
MP_PATH="${MP_PATH:-$HOME/Tools/Mad-Pascal/mp}"
MADS_PATH="${MADS_PATH:-$HOME/Tools/Mad-Assembler/mads}"
BASE_PATH="${BASE_PATH:-$HOME/Tools/Mad-Pascal/base}"
CHARSET_PATH="${CHARSET_PATH:-asm/charset.obx}"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Display usage information
show_usage() {
    cat << EOF
Usage: $0 <input_file.pas> <output_file.xex> <start_address_HEX>

Examples:
  $0 main.pas main.xex 0300
  $0 program.pas game.xex 2000

Environment Variables:
  MP_PATH     - Mad Pascal compiler path (default: $HOME/Tools/Mad-Pascal/mp)
  MADS_PATH   - Mad Assembler path (default: $HOME/Tools/Mad-Assembler/mads)
  BASE_PATH   - Mad Pascal base path (default: $HOME/Tools/Mad-Pascal/base)
  CHARSET_PATH - Charset file path (default: asm/charset.obx)
EOF
}

# Validate and setup tools
validate_environment() {
    local missing_tools=()

    [[ -x "$MP_PATH" ]] || missing_tools+=("Mad Pascal ($MP_PATH)")
    [[ -x "$MADS_PATH" ]] || missing_tools+=("Mad Assembler ($MADS_PATH)")
    [[ -d "$BASE_PATH" ]] || missing_tools+=("Base directory ($BASE_PATH)")
    [[ -f "$CHARSET_PATH" ]] || log_warn "Charset file not found: $CHARSET_PATH"

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "Missing required tools/dependencies:"
        for tool in "${missing_tools[@]}"; do
            log_error "  - $tool"
        done
        exit 1
    fi
}

# Validate file existence and permissions
validate_file() {
    local file="$1" description="$2" should_exist=true
    [[ "${3:-}" == "optional" ]] && should_exist=false

    if [[ ! -f "$file" ]]; then
        if $should_exist; then
            log_error "$description not found: $file"
            exit 1
        else
            return 1
        fi
    fi

    if [[ ! -r "$file" ]]; then
        log_error "Cannot read $description: $file"
        exit 1
    fi
}

# Convert hex string to decimal
hex_to_dec() {
    local hex_str="${1//0x/}"  # Remove 0x prefix
    # Validate hex format
    if [[ ! "$hex_str" =~ ^[0-9A-Fa-f]+$ ]]; then
        log_error "Invalid hex format: $1"
        exit 1
    fi
    printf '%d' "0x$hex_str" 2>/dev/null || {
        log_error "Invalid hex address: $1"
        exit 1
    }
}

# Convert decimal to 2-byte little-endian binary
to_little_endian_2() {
    local dec=$1
    printf "%b" "\\x$(printf "%02x" $((dec & 0xFF)))"
    printf "%b" "\\x$(printf "%02x" $((dec >> 8 & 0xFF)))"
}

# Extract VBL address from label file
extract_vbl_address() {
    local label_file="$1"
    if [[ ! -f "$label_file" ]]; then
        log_error "Label file not found: $label_file"
        exit 1
    fi

    # Multiple grep patterns for flexibility
    local vbl_addr_hex=$(grep -E '\b[0-9A-Fa-f]{4}\b.*MAIN\.VBL' "$label_file" 2>/dev/null | \
                        grep -oE '\b[0-9A-Fa-f]{4}\b' | head -1)

    if [[ -z "$vbl_addr_hex" ]]; then
        vbl_addr_hex=$(grep -E 'MAIN\.VBL' "$label_file" 2>/dev/null | \
                      grep -oE '\b[0-9A-Fa-f]{4}\b' | head -1)
    fi

    if [[ -z "$vbl_addr_hex" ]]; then
        log_warn "VBL address not found in label file, using default 0000"
        echo "0000"
    else
        echo "$vbl_addr_hex"
    fi
}

# Create DOS segment binary data
create_dos_segment() {
    local vbl_addr_hex="$1" start_addr_dec="$2"
    local vbl_addr_dec=$(hex_to_dec "$vbl_addr_hex")

    {
        printf "\xe0\xff"                    # DOS segment marker
        printf "\xff\xff"                    # FFFF
        head -c 26 /dev/zero 2>/dev/null     # 26 zeros
        to_little_endian_2 "$vbl_addr_dec"   # VBL address
        to_little_endian_2 "$start_addr_dec" # Start address
        to_little_endian_2 0                 # Padding
    }
}

# Main execution function
main() {
    # Argument validation - FIXED: check before using $3
    if [[ $# -ne 3 ]]; then
        log_error "Invalid number of arguments: expected 3, got $#"
        show_usage
        exit 1
    fi

    local input_pas="$1"
    local output_xex="$2"
    local start_addr_hex="${3#0x}"  # Remove 0x prefix

    log_info "Starting XEX creation process"
    log_info "Input: $input_pas, Output: $output_xex, Start: \$$start_addr_hex"

    # Validate inputs
    validate_environment
    validate_file "$input_pas" "Pascal source file"
    validate_file "$CHARSET_PATH" "Charset file" "optional"

    # Convert and validate address
    local start_addr_dec=$(hex_to_dec "$start_addr_hex")
    if (( start_addr_dec > 65535 )); then
        log_error "Start address exceeds 16-bit range: $start_addr_dec"
        exit 1
    fi

    # Generate base name without extension
    local base_name="${input_pas%.*}"
    local asm_file="$base_name.a65"
    local bin_file="$base_name.bin"
    local label_file="proc.lab"

    # Cleanup intermediate files on exit
    cleanup() {
        rm -f "$asm_file" "$bin_file" "$label_file"
    }
    trap cleanup EXIT

    # Step 1: Compile Pascal to assembly
    log_info "Compiling Pascal source..."
    if ! "$MP_PATH" -target:raw -cpu:65816 -code:"$start_addr_hex" -ipath:"$MP_FOLDER/lib" "$input_pas"; then
        log_error "Pascal compilation failed"
        exit 1
    fi

    # Step 2: Assemble to binary
    log_info "Assembling to binary..."
    if ! "$MADS_PATH" -x -i:"$BASE_PATH" "$asm_file" -o:"$bin_file" -t:"$label_file"; then
        log_error "Assembly failed"
        exit 1
    fi

    validate_file "$bin_file" "Intermediate binary file"

    # Step 3: Calculate addresses and sizes
    local file_size=$(wc -c < "$bin_file" 2>/dev/null)
    local end_addr_dec=$((start_addr_dec + file_size - 1))

    if (( end_addr_dec > 65535 )); then
        log_error "Program exceeds 64KB memory range"
        exit 1
    fi

    # Step 4: Extract VBL address
    local vbl_addr_hex=$(extract_vbl_address "$label_file")
    local vbl_addr_dec=$(hex_to_dec "$vbl_addr_hex")

    # Step 5: Create XEX file
    log_info "Building XEX file..."
    {
        # File header
        printf "\xff\xff"  # XEX signature
        to_little_endian_2 "$start_addr_dec"  # Start address
        to_little_endian_2 "$end_addr_dec"    # End address

        # Program code
        cat "$bin_file"

        # Charset segment (if available)
        if [[ -f "$CHARSET_PATH" ]]; then
            cat "$CHARSET_PATH"
        fi

        # DOS segment
        create_dos_segment "$vbl_addr_hex" "$start_addr_dec"
    } > "$output_xex"

    # Verification and reporting
    local final_size=$(wc -c < "$output_xex" 2>/dev/null)

    log_info "${GREEN}Successfully created $output_xex${NC}"
    echo "=== Build Summary ==="
    printf "VBL address   : \$%04X (%d)\n" "$vbl_addr_dec" "$vbl_addr_dec"
    printf "Start address : \$%04X (%d)\n" "$start_addr_dec" "$start_addr_dec"
    printf "End address   : \$%04X (%d)\n" "$end_addr_dec" "$end_addr_dec"
    printf "Code size     : %d bytes\n" "$file_size"
    printf "XEX file size : %d bytes\n" "$final_size"

    # Show hex dump of headers
    echo -e "\n=== XEX Header (first 6 bytes) ==="
    xxd -g 1 -l 6 "$output_xex" 2>/dev/null || true

    echo -e "\n=== DOS Segment (last 36 bytes) ==="
    if command -v xxd >/dev/null 2>&1; then
        xxd -g 1 -s -36 "$output_xex" 2>/dev/null || true
    else
        echo "xxd not available, skipping hex dump"
    fi
}

# Check arguments before calling main
if [[ $# -ne 3 ]]; then
    log_error "Invalid number of arguments: expected 3, got $#"
    show_usage
    exit 1
fi

# Run main function with all arguments
main "$@"
