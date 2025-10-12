#!/bin/bash

# A simple bash script to convert a video to a sequence of images using ffmpeg.
# Usage: ./video2frames.sh -i <input_video_path> -f <frames_per_second>

# Initialize variables
INPUT_VIDEO=""
FPS=""

# Parse command line arguments
while getopts "i:f:" opt; do
  case ${opt} in
    i )
      INPUT_VIDEO=$OPTARG
      ;;
    f )
      FPS=$OPTARG
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      exit 1
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      exit 1
      ;;
  esac
done

# Check if input video and fps are provided
if [[ -z "$INPUT_VIDEO" || -z "$FPS" ]]; then
    echo "Usage: $0 -i <input_video_path> -f <frames_per_second>"
    exit 1
fi

# Check if the input file exists
if [[ ! -f "$INPUT_VIDEO" ]]; then
    echo "Error: Input video file not found at '$INPUT_VIDEO'"
    exit 1
fi

# Get the directory of the input video and its name without extension
INPUT_DIR=$(dirname "$INPUT_VIDEO")
VIDEO_NAME=$(basename "$INPUT_VIDEO" | cut -d. -f1)

# Create the output directory within the same directory as the input video
OUTPUT_DIR="${INPUT_DIR}/${VIDEO_NAME}_frames"
mkdir -p "$OUTPUT_DIR"

# Check if the output directory was created successfully
if [[ ! -d "$OUTPUT_DIR" ]]; then
    echo "Error: Could not create output directory at '$OUTPUT_DIR'"
    exit 1
fi

echo "Converting '$INPUT_VIDEO' to frames..."

# Use ffmpeg to convert the video to frames
# The -r flag sets the frame rate for extraction
# The -q:v 2 flag sets a high quality for the output images
# The 'output_%04d.png' pattern names files sequentially (e.g., output_0001.png)
ffmpeg -i "$INPUT_VIDEO" -r "$FPS" -q:v 2 "$OUTPUT_DIR/output_%04d.png"

echo "Conversion complete! Frames saved to '$OUTPUT_DIR/'"
