#!/bin/bash

# --- Function to display usage information ---
usage() {
    echo "Usage: $0 <source_directory> <destination_directory>"
    echo "  <source_directory>: The folder containing the original images to compress."
    echo "  <destination_directory>: The folder where compressed images will be saved."
    echo ""
    echo "Example: $0 ~/my_photos/originals ~/my_photos/compressed"
    exit 1
}

# --- Check for correct number of arguments ---
if [ "$#" -ne 2 ]; then
    echo "Error: Incorrect number of arguments."
    usage
fi

# --- Get source and destination paths from arguments ---
SOURCE_DIR="$1"
DEST_DIR="$2"

# --- Validate source directory ---
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$SOURCE_DIR' does not exist or is not a directory."
    exit 1
fi

# --- Configuration ---
COMPRESSION_QUALITY="60" # JPEG/WEBP quality (0-100), lower is smaller file

# --- Function to check and install a command ---
install_tool() {
    local cmd_name=$1
    echo "Checking for $cmd_name..."
    if ! command -v "$cmd_name" &> /dev/null; then
        echo "$cmd_name not found. Attempting to install..."
        if command -v apt &> /dev/null; then
            sudo apt update && sudo apt install -y "$cmd_name"
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y "$cmd_name"
        elif command -v yum &> /dev/null; then # For older RHEL/CentOS
            sudo yum install -y "$cmd_name"
        elif command -v brew &> /dev/null; then # For macOS
            brew install "$cmd_name"
        else
            echo "Error: Package manager not found. Please install $cmd_name manually."
            exit 1
        fi

        if ! command -v "$cmd_name" &> /dev/null; then
            echo "Error: Failed to install $cmd_name. Please install it manually and re-run the script."
            exit 1
        else
            echo "$cmd_name installed successfully."
        fi
    else
        echo "$cmd_name is already installed."
    fi
}

# --- Install necessary tools ---
echo "--- Checking and installing required tools ---"
#install_tool imagemagick
install_tool jpegoptim
install_tool optipng
echo "--- Tool check complete ---"
echo ""

# --- Create Destination Directory if it doesn't exist ---
if [ ! -d "$DEST_DIR" ]; then
    mkdir -p "$DEST_DIR"
    echo "Created destination directory: $DEST_DIR"
fi

echo "--- Starting Image Compression ---"
echo "Source: $SOURCE_DIR"
echo "Destination: $DEST_DIR"
echo "Quality (JPEG/WEBP): $COMPRESSION_QUALITY"
echo ""

# --- Compress Images using ImageMagick, jpegoptim, and optipng ---
# We use -type f to ensure we only process files, not directories
find "$SOURCE_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | while read -r img_path; do
    filename=$(basename "$img_path")
    dest_path="$DEST_DIR/$filename"

    echo "Compressing: $filename"

    extension="${filename##*.}"
    extension_lower=$(echo "$extension" | tr '[:upper:]' '[:lower:]')

    case "$extension_lower" in
        jpg|jpeg)
            convert "$img_path" -strip -interlace Plane -quality "$COMPRESSION_QUALITY%" "$dest_path"
            if [ $? -eq 0 ]; then
                jpegoptim --strip-all --all-progressive -m"$COMPRESSION_QUALITY" "$dest_path"
                if [ $? -ne 0 ]; then
                    echo "  jpegoptim failed for $filename, ImageMagick's output kept."
                fi
            fi
            ;;
        png)
            convert "$img_path" -strip -quality 75% "$dest_path"
            if [ $? -eq 0 ]; then
                optipng -o7 "$dest_path"
                if [ $? -ne 0 ]; then
                    echo "  optipng failed for $filename, ImageMagick's output kept."
                fi
            fi
            ;;
        webp)
            convert "$img_path" -strip -quality "$COMPRESSION_QUALITY%" "$dest_path"
            ;;
        *)
            echo "Skipping unsupported format: $filename"
            continue
            ;;
    esac

    if [ $? -eq 0 ]; then
        echo "  Successfully compressed to: $dest_path"
    else
        echo "  Failed to compress: $filename"
    fi
    echo "---"
done

echo "--- Image Compression Complete! ---"
echo "Compressed images are located in: $DEST_DIR"
