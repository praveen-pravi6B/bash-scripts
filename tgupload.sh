#!/bin/bash

# --- Load Environment Variables ---
ENV_FILE="./.env"

# Check if the .env file exists before sourcing
if [ -f "$ENV_FILE" ]; then
    echo "Loading environment variables from $ENV_FILE"
    source "$ENV_FILE"
else
    echo "ERROR: $ENV_FILE not found. Exiting."
    exit 1
fi

# Default values
FOLDER_PATH=""
CHAT_ID=""
MESSAGE_THREAD_ID=""
BOT_TOKEN=$TG_UPLOAD_BOT_TOKEN # ***REPLACE WITH YOUR ACTUAL BOT TOKEN***
SEND_AS_DOCUMENT=false

# Function to display usage
usage() {
    echo "Usage: $0 -p <folder_path> -c <chat_id> [-t <message_thread_id>] [-d]"
    echo "  -p <folder_path>      : Path to the folder containing files to upload."
    echo "  -c <chat_id>          : Chat ID of the Telegram group."
    echo "  -t <message_thread_id>: (Optional) Message thread ID for the topic."
    echo "  -d                    : (Optional) Send all files as documents."
    exit 1
}

# Parse command-line arguments
while getopts "p:c:t:d" opt; do
    case ${opt} in
        p)
            FOLDER_PATH="$OPTARG"
            ;;
        c)
            CHAT_ID="$OPTARG"
            ;;
        t)
            MESSAGE_THREAD_ID="$OPTARG"
            ;;
        d)
            SEND_AS_DOCUMENT=true
            ;;
        *)
            usage
            ;;
    esac
done

# Check if essential arguments are provided
if [[ -z "$FOLDER_PATH" || -z "$CHAT_ID" ]]; then
    echo "Error: -p (folder path) and -c (chat ID) are required."
    usage
fi

# Check if the folder exists
if [[ ! -d "$FOLDER_PATH" ]]; then
    echo "Error: Folder '$FOLDER_PATH' not found."
    exit 1
fi

echo "Starting file upload from: $FOLDER_PATH"
echo "Target Chat ID: $CHAT_ID"
[[ -n "$MESSAGE_THREAD_ID" ]] && echo "Message Thread ID: $MESSAGE_THREAD_ID"
if [[ "$SEND_AS_DOCUMENT" = true ]]; then
    echo "Sending all files as documents."
fi

# Loop through files in the specified folder
for file in "$FOLDER_PATH"/*; do
    if [[ -f "$file" ]]; then
        FILENAME=$(basename "$file")
        MIME_TYPE=$(file -b --mime-type "$file")

        echo "Processing file: $FILENAME (MIME Type: $MIME_TYPE)"

        API_URL="https://api.telegram.org/bot${BOT_TOKEN}"
        CURL_COMMAND="curl -s -X POST"
        
        # Add common curl options
        CURL_COMMAND+=" -F chat_id=\"$CHAT_ID\""
        [[ -n "$MESSAGE_THREAD_ID" ]] && CURL_COMMAND+=" -F message_thread_id=\"$MESSAGE_THREAD_ID\""

        # Determine upload method based on MIME type or -d flag
        if [[ "$SEND_AS_DOCUMENT" = true ]]; then
            echo "Sending as document (forced)..."
            CURL_COMMAND+=" -F document=@\"$file\" ${API_URL}/sendDocument"
        elif [[ "$MIME_TYPE" == image/* ]]; then
            echo "Sending as photo..."
            CURL_COMMAND+=" -F photo=@\"$file\" ${API_URL}/sendPhoto"
        elif [[ "$MIME_TYPE" == video/* ]]; then
            echo "Sending as video..."
            CURL_COMMAND+=" -F video=@\"$file\" ${API_URL}/sendVideo"
        else
            echo "Sending as document..."
            CURL_COMMAND+=" -F document=@\"$file\" ${API_URL}/sendDocument"
        fi

        # Execute the curl command
        eval "$CURL_COMMAND"
        echo "" # Add a newline for better readability after each upload

        # Basic error checking (you can enhance this)
        if [[ $? -eq 0 ]]; then
            echo "Successfully sent $FILENAME"
        else
            echo "Failed to send $FILENAME"
        fi
    fi
done

echo "Upload process complete."
