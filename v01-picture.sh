mv /tmp/tutaut.mkv 00-orig.mkv
ffmpeg -y -ss 15 -i 00-orig.mkv -vframes 1 01-thumbnail.jpg
