export DEBUG=1
export LEADER_GEOM=80x24+1741+0
export DEV1_GEOM=80x24+1741+895
export DEV2_GEOM=80x24+150+895
export EXEC_ON_WORK_BEGIN=custom_work_begin
export EXEC_ON_WORK_END=custom_work_end
export LEADER_SETUP_COMMAND='cd /tmp
PS1="[leader@lmachine \\W]$ "'
export DEV1_SETUP_COMMAND='cd /tmp
PS1="[dev1@d1machine \\W]$ "'
export DEV2_SETUP_COMMAND='cd /tmp
PS1="[dev2@d2machine \\W]$ "'

function custom_work_begin() {
	if [ "$WORK_LEVEL" -eq 1 ]
	then
		start_screen_record
	fi
}
function custom_work_end() {
	if [ "$WORK_LEVEL" -eq 1 ]
	then
		stop_screen_record
	fi
}
function start_screen_record() {
	AUDIO_ID="$(pacmd list-sources | grep -PB 1 "analog.*monitor>" | head -n 1 | perl -pe 's/.* //g')"
	ffmpeg -y -video_size 3200x1800 -framerate 25 -f x11grab -i :0.0 -f pulse -ac 2 -i $AUDIO_ID /tmp/tutaut.mkv >/dev/null 2>&1 &
	trap stop_screen_record EXIT
}
function stop_screen_record() {
	pkill ffmpeg
}
