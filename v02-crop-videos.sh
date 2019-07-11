ffmpeg -y -i 01-skip.mkv -vf "crop=1436:828:1740:36" 02-leader.mkv
ffmpeg -y -i 01-skip.mkv -vf "crop=1436:828:155:933" 02-dev2.mkv
ffmpeg -y -i 01-skip.mkv -vf "crop=1436:828:1740:932" 02-dev1.mkv
