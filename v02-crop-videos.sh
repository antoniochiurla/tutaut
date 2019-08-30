ffmpeg -y -i 01-skip.mkv -vf "crop=1441:830:1743:35" 02-leader.mkv
ffmpeg -y -i 01-skip.mkv -vf "crop=1441:830:152:930" 02-dev2.mkv
ffmpeg -y -i 01-skip.mkv -vf "crop=1441:830:1743:930" 02-dev1.mkv
