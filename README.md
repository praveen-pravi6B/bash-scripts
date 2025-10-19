# Bash Scripts

This repository is a collection of personal bash scripts for various tasks.

## Scripts

### `compress_images.sh`

This script compresses images in a specified directory and saves them to a destination directory.

**Usage:**

```bash
./compress_images.sh <source_directory> <destination_directory>
```

**Dependencies:**

*   `imagemagick`
*   `jpegoptim`
*   `optipng`

### `jpg2png.sh`

This script converts all `.jpg` and `.jpeg` images in a directory to `.png` format.

**Usage:**

```bash
./jpg2png.sh <directory_path>
```

**Dependencies:**

*   `imagemagick`

### `tgupload.sh`

This script uploads files from a specified folder to a Telegram chat.

**Usage:**

```bash
./tgupload.sh -p <folder_path> -c <chat_id> [-t <message_thread_id>] [-d]
```

**Arguments:**

*   `-p <folder_path>`: Path to the folder containing files to upload.
*   `-c <chat_id>`: Chat ID of the Telegram group.
*   `-t <message_thread_id>`: (Optional) Message thread ID for the topic.
*   `-d`: (Optional) Send all files as documents.

**Dependencies:**

*   `curl`

### `videoToImg.sh`

This script converts a video to a sequence of images using `ffmpeg`.

**Usage:**

```bash
./videoToImg.sh -i <input_video_path> -f <frames_per_second>
```

**Arguments:**

*   `-i <input_video_path>`: Path to the input video file.
*   `-f <frames_per_second>`: The number of frames to extract per second.

**Dependencies:**

*   `ffmpeg`

## Environment Variables

Some scripts in this repository may require API keys, tokens, or other credentials to function. To manage these securely, this project uses a `.env` file.

1.  **Create a `.env` file:** Copy the `env.sample` file to a new file named `.env`.
    ```bash
    cp env.sample .env
    ```
2.  **Add your credentials:** Open the `.env` file and replace the placeholder values with your actual credentials.

**Note:** The `.env` file is included in `.gitignore` and should **never** be committed to the repository.

## Contributing

Feel free to fork this repository and add your own scripts. Pull requests are welcome.

If your script requires any keys, tokens, or other credentials, please:

1.  Add the necessary environment variable(s) to the `env.sample` file with a placeholder value (e.g., `YOUR_API_KEY`).
2.  Update your script to read the variable from the `.env` file.
3.  Ensure you do not commit your own `.env` file.
