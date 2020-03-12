X_SIZE=805
Y_SIZE=462
SIZE="${X_SIZE}:${Y_SIZE}"
X1=1100
Y1=21
X2=75
Y2=526

X_PLUS=0
Y_PLUS=0

set -x

X_SIZE=$((X_SIZE+X_PLUS*2))
Y_SIZE=$((Y_SIZE+Y_PLUS*2))
X1=$((X1-X_PLUS))
Y1=$((Y1-Y_PLUS))
X2=$((X2-X_PLUS))
Y2=$((Y2-Y_PLUS))

LEADER="1101:21"
DEV1="1101:525"
DEV2="75:525"

LEADER="${X_SIZE}:${Y_SIZE}:${X1}:${Y1}"
DEV1="${X_SIZE}:${Y_SIZE}:${X1}:${Y2}"
DEV2="${X_SIZE}:${Y_SIZE}:${X2}:${Y2}"

ffmpeg -y -ss 15 -i 00-orig.mkv -vframes 1 -vf "crop=${LEADER}" 02-leader.jpg \
	-vf "crop=${DEV1}" 02-dev1.jpg \
	-vf "crop=${DEV2}" 02-dev2.jpg
ffmpeg -y -i 00-orig.mkv -vf "crop=${LEADER}" 02-leader.mkv \
	-vf "crop=${DEV1}" 02-dev1.mkv \
	-vf "crop=${DEV2}" 02-dev2.mkv
exit
ffmpeg -y -i 01-skip.mkv -vf "crop=1441:830:1743:35" 02-leader.mkv
ffmpeg -y -i 01-skip.mkv -vf "crop=1441:830:1743:930" 02-dev1.mkv
ffmpeg -y -i 01-skip.mkv -vf "crop=1441:830:152:930" 02-dev2.mkv
