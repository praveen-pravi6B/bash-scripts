#!/bin/bash

# Check if a directory was provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <directory_path>"
  exit 1
fi

directory="$1"

# Check if the directory exists
if [ ! -d "$directory" ]; then
  echo "Error: Directory '$directory' not found."
  exit 1
fi

# Loop through all files in the directory with a .jpg or .jpeg extension
for file in "$directory"/*.jpg "$directory"/*.jpeg; do
  # Check if the file exists (important for when there are no files with that extension)
  if [ -f "$file" ]; then
    # Get the base name of the file without its extension
    filename_no_ext=$(basename "$file" .jpg)
    # If the file has .jpeg extension, handle that case
    if [ "$filename_no_ext" = "$(basename "$file" .jpeg)" ]; then
        filename_no_ext=$(basename "$file" .jpeg)
    fi

    output_file="$directory/$filename_no_ext.png"

    # Convert the file
    convert "$file" "$output_file"
    echo "Converted '$file' to '$output_file'."
  fi
done

echo "Conversion complete."
