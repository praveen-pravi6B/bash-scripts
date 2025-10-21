#!/bin/bash

# ==============================================
# Image Format Converter Script
# Converts images from one format to another in a given directory
# Usage: ./convert_images.sh <source_dir> <input_format> <output_format> [-r]
# Options:
#   -r      (optional, last argument) Remove source file after successful conversion
# ==============================================

# Print usage info
print_usage() {
    echo "Usage: $0 <source_dir> <input_format> <output_format> [-r]"
    echo "  -r : (optional, must be last) Remove original file after successful conversion"
    echo "Example: $0 ./images webp png -r"
    echo ""
    echo "Requirements: ImageMagick ('convert') or WebP tools ('dwebp')"
}

# Check if enough arguments are provided
if [ "$#" -lt 3 ] || [ "$#" -gt 4 ]; then
    echo "❌ Error: Invalid number of arguments."
    print_usage
    exit 1
fi

# Check if last argument is -r
REMOVE_SOURCE=false
if [ "$#" -eq 4 ]; then
    if [ "${4}" == "-r" ]; then
        REMOVE_SOURCE=true
    else
        echo "❌ Error: Invalid fourth argument. Only '-r' is allowed as the last argument."
        print_usage
        exit 1
    fi
fi

# Assign variables
SOURCE_DIR="$1"
INPUT_FORMAT="$2"
OUTPUT_FORMAT="$3"

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "❌ Error: Directory '$SOURCE_DIR' does not exist."
    exit 1
fi

# Check for required tools
if ! command -v convert &>/dev/null && ! command -v dwebp &>/dev/null; then
    echo "❌ Error: Neither 'convert' (ImageMagick) nor 'dwebp' (WebP tools) is installed."
    echo "Install with: sudo apt install imagemagick or sudo apt install webp"
    exit 1
fi

# Determine tool based on formats
USE_DWEBP=false
if [[ "$INPUT_FORMAT" == "webp" && "$OUTPUT_FORMAT" == "png" && $(command -v dwebp) ]]; then
    USE_DWEBP=true
fi

# Enable nullglob
shopt -s nullglob
FILES=("$SOURCE_DIR"/*."$INPUT_FORMAT")

if [ ${#FILES[@]} -eq 0 ]; then
    echo "⚠️  Warning: No .$INPUT_FORMAT files found in '$SOURCE_DIR'."
    exit 0
fi

echo "🔄 Converting .$INPUT_FORMAT → .$OUTPUT_FORMAT in '$SOURCE_DIR'"
echo "Remove source files after conversion: $REMOVE_SOURCE"

for file in "${FILES[@]}"; do
    filename=$(basename "$file")
    base="${filename%.$INPUT_FORMAT}"
    output_file="$SOURCE_DIR/$base.$OUTPUT_FORMAT"

    if $USE_DWEBP; then
        echo "Converting (dwebp): $filename → $base.$OUTPUT_FORMAT"
        dwebp "$file" -o "$output_file"
    else
        echo "Converting (convert): $filename → $base.$OUTPUT_FORMAT"
        convert "$file" "$output_file"
    fi

    # If successful and -r was set, remove original
    if [ $? -eq 0 ] && [ -f "$output_file" ]; then
        if $REMOVE_SOURCE; then
            echo "🗑️  Removing source file: $filename"
            rm "$file"
        fi
    else
        echo "⚠️  Failed to convert: $filename"
    fi
done

echo "✅ Conversion complete."
