#!/usr/bin/env bash
if [ -z "$TUTAUT" ]; then
	PATH_TUTAUT=$(dirname ${BASH_SOURCE[0]})
	echo $PATH_TUTAUT
	TUTAUT=1
	[ -f set_default_values.sh ] && . set_default_values.sh
	DEFAULT_MIN_WAIT_CHAR=0
	DEFAULT_MAX_WAIT_CHAR=300
	DEFAULT_WAIT_AFTER_SPACE=0.5
	DEFAULT_WAIT_BEFORE_ENTER=1.0
	DEFAULT_WAIT_AFTER_COMMAND=2.0
	DEFAULT_WAIT_CHANGE_OPERATOR=3.0
	DEFAULT_WAIT_AFTER_INFO=3.0
	DEFAULT_ERRORS_PERCENT=5
	DO_PAUSE=1
	DEFAULT_PAUSE=3
	NUM_WAIT_COMMAND=1
	MIN_WAIT_CHAR=$DEFAULT_MIN_WAIT_CHAR
	MAX_WAIT_CHAR=$DEFAULT_MAX_WAIT_CHAR
	WAIT_AFTER_SPACE=$DEFAULT_WAIT_AFTER_SPACE
	WAIT_BEFORE_ENTER=$DEFAULT_WAIT_BEFORE_ENTER
	WAIT_AFTER_COMMAND=$DEFAULT_WAIT_AFTER_COMMAND
	WAIT_CHANGE_OPERATOR=$DEFAULT_WAIT_CHANGE_OPERATOR
	WAIT_AFTER_INFO=$DEFAULT_WAIT_AFTER_INFO
	WORK_LEVEL=0
	SOUND_BUTTON_PRESS_MS=24
	SOUND_BUTTONS_PRESS_MS=60
	END_LAST_SOUND=0
	ERRORS_PERCENT=$DEFAULT_ERRORS_PERCENT
	VIDEO_FPS=25
	OPERATOR=
	declare -A OPERATORS
	declare -A OPERATORS_GEOMETRY
	declare -A OPERATORS_SETUP_COMMAND
	WINDOW_TYPE=tmux
	XTERM_SMALL_FONT=
	BACKSPACES="\\h\\h\\h\\h\\h\\h\\h\\h\\h\\h"
	BACKSPACES_NOT_ESCAPED=""
	ID_USER=$(id --user)
	FILE_LOG=/tmp/tutaut${ID_USER}.log
	FILE_DEBUG=/tmp/tutaut${ID_USER}.debug
	FILE_TRACE=/tmp/tutaut${ID_USER}.trace
	echo -n >$FILE_LOG
	echo -n >$FILE_DEBUG
	if which play >/dev/null 2>&1
	then
		SOX_PLAY=$(which play)
	fi
	stty -icanon min 1
	COMMAND_KEY_STEP=" "
	[ -n "$TRACE" ] && exec 2>$FILE_TRACE && set -x
fi


function now()
{
	TIME_NOW=$(date +%s%N)
	TIME_START=${TIME_START:-$TIME_NOW}
	TIME_ELAPSED=$(((TIME_NOW-TIME_START)/1000000))
	FRAME_NUM=$((TIME_ELAPSED*VIDEO_FPS/1000))
	LOG_PREFIX=$TIME_ELAPSED:$FRAME_NUM
}

function log()
{
	typed_log generic $*
}

function typed_log()
{
	TYPE="$1"
	shift
	now
	echo "$LOG_PREFIX:$TYPE:$*" >>$FILE_LOG
}

function info()
{
	now
	echo "$*"
	echo "$LOG_PREFIX:info:$*" >>$FILE_LOG
	sleep $WAIT_AFTER_INFO
}

function debug()
{
	if [ -n "$DEBUG" ]
	then
		now
		echo "$LOG_PREFIX:$*" >>$FILE_DEBUG
	fi
}

unlock_when_hang()
{
	PROC=$1
	while test -d /proc/${PROC}; do
		sleep 1
		echo -ne " " >/proc/${PROC}/fd/0
	done
}

work_begin()
{
	WORK_LEVEL=$((WORK_LEVEL+1))
	if [ -n "$EXEC_ON_WORK_BEGIN" ]; then
		unlock_when_hang $$&
		$EXEC_ON_WORK_BEGIN
	fi
	TIME_START=
	now
	echo "$LOG_PREFIX:begin:$WORK_LEVEL" >$FILE_LOG
	END_LAST_SOUND=0
}

work_end()
{
	echo "$LOG_PREFIX:end:$WORK_LEVEL" >>$FILE_LOG
	WORK_LEVEL=$((WORK_LEVEL-1))
	if [ -n "$EXEC_ON_WORK_END" ]; then
		$EXEC_ON_WORK_END
	fi
}

function operator()
{
	PREV_OPERATOR=$OPERATOR
	OPERATOR=$1
	if [ -z "${OPERATORS[$OPERATOR]}" ]; then
		create_operator
	fi
	if [ "${OPERATOR}" != "$PREV_OPERATOR" ]; then
		debug "switch to operator $OPERATOR"
		now
		echo "$LOG_PREFIX:goto_operator:$OPERATOR" >>$FILE_LOG
		sleep $WAIT_CHANGE_OPERATOR
		now
		echo "$LOG_PREFIX:arrive_to_operator:$OPERATOR" >>$FILE_LOG
	fi
}

function create_operator()
{
	FOUND_SESSION=$(tmux list-sessions 2>/dev/null | cut -d":" -f1 | grep $OPERATOR)
	if [ -z "${FOUND_SESSION}" ]; then
		launch_terminal_on_new_session
		FIRST_FREE_SESSION=$(tmux list-sessions | cut -d":" -f1 | grep "^[0-9]" | sort -n | head -1)
		debug "renaming tmux session $FIRST_FREE_SESSION to $OPERATOR"
		tmux rename-session -t$FIRST_FREE_SESSION $OPERATOR
		tmux_set_option destroy-unattached on
	#else
	#	launch_terminal_on_existing_session $OPERATOR
	fi
	send
	OPERATORS[$OPERATOR]=1
	SETUP_COMMAND=${OPERATORS_SETUP_COMMAND[$OPERATOR]}
	[ -n "$SETUP_COMMAND" ] && send_command "$SETUP_COMMAND"
}

function launch_terminal_on_new_session()
{
	SHELL_TERMINAL=tmux
	launch_terminal
	sleep 0.3
}

function tmux_set_option()
{
	tmux set-option -t$OPERATOR $*
}

function launch_terminal_on_existing_session()
{
	echo "tmux attach-session -t $1" >/tmp/tutaut_tmux_command.sh
	chmod +x /tmp/tutaut_tmux_command.sh
	SHELL_TERMINAL="/tmp/tutaut_tmux_command.sh"
	launch_terminal
	sleep 0.3
	rm /tmp/tutaut_tmux_command.sh
}

function launch_terminal()
{
	if [ -n "${OPERATORS_GEOMETRY[$OPERATOR]}" ]
	then
		XTERM_GEOMETRY=${OPERATORS_GEOMETRY[$OPERATOR]}
	fi
	if [ -n "$XTERM_SMALL_FONT" ]
	then
		XTERM_OPT_NAME="-name XTermNoTTF"
	fi
	xterm $XTERM_OPT_NAME -ah -g $XTERM_GEOMETRY -si -sk -sb -sl 10000 -rightbar $SHELL_TERMINAL &
	debug "Started xterm geometry: $XTERM_GEOMETRY"
}

function decrement_speed()
{
	MAX_WAIT_CHAR=$((MAX_WAIT_CHAR*11/10))
	debug "new MAX_WAIT_CHAR: $MAX_WAIT_CHAR"
}

function increment_speed()
{
	NEW_MAX_WAIT_CHAR=$((MAX_WAIT_CHAR*9/10))
	if [ $NEW_MAX_WAIT_CHAR -eq $MAX_WAIT_CHAR ]; then
		MAX_WAIT_CHAR=$((MAX_WAIT_CHAR-1))
	else
		MAX_WAIT_CHAR=$NEW_MAX_WAIT_CHAR
	fi
	debug "new MAX_WAIT_CHAR: $MAX_WAIT_CHAR"
}

function speed_up()
{
	if [ -z "$FIXED_SPEED" ];then
		MIN_WAIT_CHAR=$DEFAULT_MIN_WAIT_CHAR
		MAX_WAIT_CHAR=0
		WAIT_AFTER_SPACE=0
		WAIT_BEFORE_ENTER=0
		WAIT_AFTER_COMMAND=0.2
		WAIT_CHANGE_OPERATOR=1.0
		WAIT_AFTER_INFO=0.3
		ERRORS_PERCENT=0
		DO_PAUSE=
	fi
}

function slow_down()
{
	if [ -z "$FIXED_SPEED" ];then
		MIN_WAIT_CHAR=$DEFAULT_MIN_WAIT_CHAR
		MAX_WAIT_CHAR=$DEFAULT_MAX_WAIT_CHAR
		WAIT_AFTER_SPACE=$DEFAULT_WAIT_AFTER_SPACE
		WAIT_BEFORE_ENTER=$DEFAULT_WAIT_BEFORE_ENTER
		WAIT_AFTER_COMMAND=$DEFAULT_WAIT_AFTER_COMMAND
		WAIT_CHANGE_OPERATOR=$DEFAULT_WAIT_CHANGE_OPERATOR
		WAIT_AFTER_INFO=$DEFAULT_WAIT_AFTER_INFO
		ERRORS_PERCENT=$DEFAULT_ERRORS_PERCENT
		DO_PAUSE=1
	fi
}

function wait_after_space()
{
	sleep $WAIT_AFTER_SPACE
}

function wait_before_enter()
{
	sleep $WAIT_BEFORE_ENTER
}

function wait_after_command()
{
	sleep $WAIT_AFTER_COMMAND
}

function wait_command_if_stopped()
{
	debug "wait_command_if_stopped: $STOPPED"
	while [ -n "$STOPPED" -a "${STEP_ON:-0}" -lt 1 ]; do
		command_check
	done
}

function wait_before_char()
{
	wait_command_if_stopped
	[ -n "$STEP_ON" ] && debug "Step:$STEP_ON" && STEP_ON=$((STEP_ON-1)) && [ "$STEP_ON" -eq 0 ] && STOPPED=1
	TRY_ON_100=$((RANDOM%100))
	if [ $TRY_ON_100 -ge 40 ]; then
		WAIT_BEFORE_CHAR_AMOUNT=$((MIN_WAIT_CHAR+RANDOM))
		[ $WAIT_BEFORE_CHAR_AMOUNT -gt $MAX_WAIT_CHAR ] && WAIT_BEFORE_CHAR_AMOUNT=$MAX_WAIT_CHAR
		WAIT_BEFORE_CHAR_MS=$((WAIT_BEFORE_CHAR_AMOUNT%1000))
		[ "$WAIT_BEFORE_CHAR_MS" -ne 0 ] && sleep 0.$WAIT_BEFORE_CHAR_MS
	else
		WAIT_BEFORE_CHAR_MS=0
	fi
}

: "
  501  play -n synth brownnoise synth pinknoise mix synth sine amod 0.3 10
  502  play -V -r 48000 -n synth sin 1000 vol -60dB
  504  play -V -r 44100 -n synth 30 sin 20+20000
  505  sox -V -r 44100 -n -n synth 30 sin 0+19000 sin 1000+20000 remix 1,2 spectrogram -o imd-ccif-sweep.png
  509  play -n -c1 synth 3 sine 500
  510  play -n synth brownnoise synth pinknoise mix synth 1 sine amod 0.3 10
  511  play -n synth brownnoise synth pinknoise mix synth 0.2 sine amod 0.3 10
  512  play -n synth brownnoise synth pinknoise mix synth 0.1 sine amod 0.3 10
  513  play -n synth brownnoise synth pinknoise mix synth 0.01 sine amod 0.3 10
  514  play -n synth brownnoise synth pinknoise mix synth 0.01
  515  play -n synth brownnoise synth pinknoise mix synth 0.02
  516  play -n synth brownnoise synth pinknoise mix synth 0.01
  517  play -n synth brownnoise synth pinknoise mix synth 1.01
  518  play -n synth brownnoise synth pinknoise mix synth 1.01 sine amod 0.3 10
  519  play -n synth brownnoise synth pinknoise mix synth 1.01 sine amod 10
  520  play -n synth brownnoise synth pinknoise mix synth 1.01 sine amod 0.3 10
  521  play -n synth brownnoise synth pinknoise mix synth 1.01 sine amod 5
  522  play -n synth brownnoise synth pinknoise mix synth 1.01 sine amod 2
  523  play -n synth brownnoise synth pinknoise mix synth 1.01 sine amod 100
  524  play -n synth brownnoise synth pinknoise mix synth 1.01 sine amod 30
  525  play -n synth brownnoise synth pinknoise mix synth 0.03 sine amod 30
  526  play -n synth brownnoise synth pinknoise mix synth 0.01 sine amod 30
  527  play -n synth brownnoise synth pinknoise mix synth 0.002 sine amod 30
  528  play -n synth brownnoise synth pinknoise mix synth 0.005 sine amod 30
  529  play -n synth sin .1 1 200
  530  play -n synth .1 1 sine 200
  531  play -n synth .1 3 sine 200
  532  play -n synth brownnoise synth pinknoise mix synth 0.005 sine amod 30
  533  play -n synth brownnoise synth pinknoise mix synth 0.005
  534  play -n synth brownnoise synth pinknoise mix synth 0.005 delay 0.5 synth pinknoise synth 0.005
  535  play -n synth brownnoise synth pinknoise synth 0.005 delay 0.5 synth pinknoise synth 0.005
  536  play -n synth brownnoise synth pinknoise synth 0.005 delay 1.5 synth pinknoise synth 0.005
  537  play -n delay 1.5 synth pinknoise synth 0.005
  538  sox -t sl - -t sl - synth $len pinknoise < /dev/zero |  sox -t sl - -t ossdsp /dev/dsp band -n 1200 200 vibro 20 .1
  540  sox -t sl - -t sl - synth $len pinknoise < /dev/zero |  sox -t sl - -t ossdsp /dev/dsp band -n 1200 200 vibro 20 .1
  541  play -n synth 1 pluck E3 pluck C3 repeat 2
  542  play -n synth 1 pluck E3 pluck C3 repeat 1
  543  play -n synth 1 pluck E3 pluck D3 repeat 1
  544  play -n synth 1 pluck E3 pluck C3 repeat 1 channels 1
  545  play -n -c1 synth sin %-12 sin %-9 sin %-5 sin %-2 fade h 0.1 1 0.1
  546  play -n synth -j 3 sin %3 sin %-2 sin %-5 sin %-9                    sin %-14 sin %-21 fade h .01 2 1.5 delay                    1.3 1 .76 .54 .27 remix - fade h 0 2.7 2.5 norm -1
  547  play -n synth pl G2 pl B2 pl D3 pl G3 pl D4 pl G4                    delay 0 .05 .1 .15 .2 .25 remix - fade 0 4 .1 norm -1
  548  play -n synth pinknoise synth 0.005
  549  play -n synth pinknoise
  550  play -n synth pinknoise 0.005 
  551  play -n synth pinknoise synth 0.005 synth pinknoise synth 0.01
  552  play -n synth pinknoise synth 0.005 synth pinknoise synth 0.01 delay 0 0.5
  553  play -n synth pl G2 pl B2 pl D3 pl G3 pl D4 pl G4                    delay 0 .05 .1 .15 .2 .25 remix - fade 0 4 .1 norm -1
  554  play -n synth pl G2 pl B2 pl D3 pl G3 pl D4 pl G4                    delay 0 .05 .1 .15 .2 .25
  555  play -n synth pl G2 pl B2 pl D3 pl G3 pl D4 pl G4                    delay 0 .05 .1 .15 .2 .25 remix - fade 0 2 .1 norm -1
  556  play -n synth pl G2 pl B2 pl D3 pl G3 pl D4 pl G4                    delay 0 .05 .1 .15 .2 .25 remix - fade 0 4 .1
  557  play -n synth pl G2 pl B2                    delay 0 .05 remix - fade 0 4 .1
  558  play -n synth pl G2 pl B2       delay 0 .5 remix - fade 0 4 .1
  559  play -n synth pl G2 pl B2       delay 0 .5 remix - fade 0 2 .1
  560  history | grep "play\|sox"
  561  history | grep "play\|sox" >/tmp/sox_cmd
"

# free sound effects from https://www.fesliyanstudios.com

function sound_button_press()
{
	#return
	if [ -n "$SOX_PLAY" ];then
		now
		debug "for_sound: $TIME_ELAPSED - $END_LAST_SOUND"
		if [ $TIME_ELAPSED -gt $END_LAST_SOUND ]; then
			if [ "$1" -gt 0 ]; then
				PLAY_VOLUME=$1
			else
				PLAY_VOLUME=$((RANDOM%5+3))
			fi
			$SOX_PLAY --volume 0.$PLAY_VOLUME $PATH_TUTAUT/keyboard_button_press.mp3 2>/dev/null&
			now
			END_LAST_SOUND=$((TIME_ELAPSED+SOUND_BUTTON_PRESS_MS))
		fi
	fi
	typed_log keyboard_button $OPERATOR:$2
}

function sound_buttons_press()
{
	#return
	if [ -n "$SOX_PLAY" ];then
		now
		if [ $TIME_ELAPSED -gt $END_LAST_SOUND ]; then
			PLAY_VOLUME=$((RANDOM%5+1))
			$SOX_PLAY --volume 0.$PLAY_VOLUME $PATH_TUTAUT/keyboard_buttons_press.mp3 2>/dev/null&
			END_LAST_SOUND=$((TIME_ELAPSED+SOUND_BUTTONS_PRESS_MS))
		fi
	fi
	typed_log keyboard_buttons "$OPERATOR:$*"
}

function to_operator()
{
	command_check
	CH="$1"
	debug "to_operator: $CH"
	wait_before_char
	if [ "$WAIT_BEFORE_CHAR_MS" -eq 0 -a 1 -eq 2 ];then
		BUFFER+="$CH"
		debug "buffer: $BUFFER"
	else
		send_flush
		to_operator_direct "$CH"
	fi
}

function to_operator_direct()
{
	DIRECT_CH="$1"
	if [ -n "$OPERATOR" ]; then
		if [ "${DIRECT_CH:0:1}" = "\\" ]; then
			CONTROL=${DIRECT_CH:1:1}
			case $CONTROL in 
				n) debug "to_operator_direct newline"
					tmux send -t$OPERATOR "
"
					sound_button_press 9 "\\$CONTROL"
					;;
				\\) debug "to_operator_direct backslash"
					tmux send -t$OPERATOR "\\"
					sound_button_press 9 "\\$CONTROL"
					;;
				h) debug "to_operator_direct backspace"
					tmux send -t$OPERATOR ""
					sound_button_press 9 "\\$CONTROL"
					;;
				*) debug "ERROR unknown \\$CONTROL control key"
					;;
			esac
		else
			debug "to_operator_direct: $DIRECT_CH"
			if [ ${#DIRECT_CH} -gt 2 ]; then
				sound_buttons_press "$DIRECT_CH"
			else
				sound_button_press 0 "$DIRECT_CH"
			fi
			tmux send -t$OPERATOR -- "$DIRECT_CH"
		fi
	else
		echo -ne "$DIRECT_CH"
	fi
}

function send_flush()
{
	debug "send_flush: $BUFFER"
	if [ -n "$BUFFER" ]
	then
		to_operator_direct "$BUFFER"
	fi
	BUFFER=
}

function insert_errors(){
	LEN=${#ALL}
	for ((POS=LEN-1;POS >= 0; POS--));do
		PROB=$((RANDOM%100))
		if [ $PROB -lt $ERRORS_PERCENT ]
		then
			LEN=${#ALL}
			LEN1=$((POS))
			POS2=$POS
			LEN2=$((LEN-POS))
			LEN_MISTAKE=$((RANDOM%4))
			if [ $POS -le $((LEN-LEN_MISTAKE-1)) ]
			then
				POS_PLUS_1=$((POS+1))
				MISTAKE=${ALL:$POS_PLUS_1:$LEN_MISTAKE}
				MISTAKE=${MISTAKE//\\/ }
				LEN_MISTAKE=${#MISTAKE}
				CORRECTION=${BACKSPACES_NOT_ESCAPED:0:$LEN_MISTAKE}
			else
				MISTAKE=" "
				CORRECTION=""
			fi
			ALL_NEW="${ALL:0:$LEN1}${MISTAKE}${CORRECTION}${ALL:$POS2:$LEN2}"
			ALL="$ALL_NEW"
			debug "Adding error $POS $LEN1 $LEN2 $MISTAKE $CORRECTION ALL: $ALL"
			break # one only mistake on single command
		fi
	done
}

function send()
{
	ALL="$@"
	if [ -n "$ALLOW_ERRORS" ]
	then
		insert_errors
	fi
	debug "sending $ALL"
	LEN=${#ALL}
	for ((POS=0;POS < LEN; POS++));do
		CHAR="${ALL:$POS:1}"
		if [ "$CHAR" = "\\" ]; then
			POS=$((POS+1))
			CHAR="${CHAR}${ALL:$POS:1}"
		fi
		to_operator "${CHAR}"
		if [ "$CHAR" = " " ]; then
			wait_after_space
			send_flush
		elif [ "$CHAR" = "/" -o "$CHAR" = "-" -o "$CHAR" = "." -o "$CHAR" = "_" ]; then
			send_flush
		elif [ "$CHAR" = "" -o "$CHAR" = "\\h" ]; then
			send_flush
		elif [ "${CHAR:0:1}" = "\\" ]; then
			send_flush
		fi
	done
	send_flush
}

function send_command()
{
	ALLOW_ERRORS=1
	send "$*"
	ALLOW_ERRORS=
	wait_before_enter
	send "\n"
	wait_after_command
}

function change_dir()
{
	send_command cd $1
}

function create_dir()
{
	send_command mkdir -p $1
}

function clear_screen()
{
	send_command clear
}


function command_check()
{
	COMMAND=
	if [ -n "$STOPPED" ]
	then
		if [ $NUM_WAIT_COMMAND -lt 99999 ]
		then
			NUM_WAIT_COMMAND=$((NUM_WAIT_COMMAND+50))
		else
			NUM_WAIT_COMMAND=99999
		fi
		WAIT_COMMAND=$((NUM_WAIT_COMMAND%100000+100000))
		ARG_READ_TIMEOUT=0.${WAIT_COMMAND:1}
		debug "waiting command $ARG_READ_TIMEOUT"
		read -t ${ARG_READ_TIMEOUT} COMMAND
	else
		read -s -t 0.001 COMMAND
	fi
	if [ -n "$COMMAND" ]; then
		command_exec "$COMMAND"
		NUM_WAIT_COMMAND=1
	fi
}

function command_exec()
{
	debug "Executing command: $COMMAND"
	case "$COMMAND" in
	' ') false;; # ignoring blank, used to unlock read when unexplainable hang
	+) increment_speed; debug "increase speed";;
	-) decrement_speed; debug "decrease speed";;
	f) speed_up; debug "activate speed_up";;
	F) slow_down; debug "activate slow_down";;
	s) STOPPED=1; debug "Stopped";;
	S) unset STOPPED; debug "Restarted";;
	[0-9]) COMMAND_NUM=$COMMAND_NUM$COMMAND; debug "Num: $COMMAND_NUM";;
	o) STEP_ON=${COMMAND_NUM:-1}; COMMAND_NUM= ; debug "Step on: $STEP_ON";;
	esac
}

function do_suspend()
{
	echo "Execution stopped, press S to resume..."
	STOPPED=1
}

function pause()
{
	if [ -n "$DO_PAUSE" ]
	then
		TMOUT=${1:-$DEFAULT_PAUSE}
		debug "Waiting for $TMOUT..."
		read PAUSE
		TMOUT=
	fi
}

function git_init()
{
	send_command git init --bare
}

function git_config()
{
	send_command git config "$@"
}

function git_clone()
{
	send_command git clone "$@"
}

function git_add()
{
	send_command git add "$@"
}

function git_am_show_current_patch()
{
	send_command git am --show-current-patch
}

function git_merge()
{
	send_command git merge $*
}

function git_merge_continue()
{
	send_command git merge --continue
}

function git_rebase_continue()
{
	send_command git rebase --continue
}

function git_pull()
{
	send_command git pull
}

function git_pull_noff()
{
	send_command git pull --no-ff
}

function git_pull_rebase()
{
	send_command git pull --rebase
}

function git_checkout()
{
	send_command git checkout $*
}

function git_push()
{
	send_command git push $*
}

function git_branch()
{
	send_command git branch $*
}

function git_commit()
{
	COMMENT="$*"
	COMMENT=${COMMENT:-no comment}
	send_command git commit -m "\"$COMMENT from op $OPERATOR\""
}

function git_diff()
{
	send_command git diff $*
}

function git_log()
{
	send_command "git log --graph --oneline --decorate=short --all | cat"
}

function git_status()
{
	send_command "git status"
}

function vi_open()
{
	FILE=${1}
	send_command vim $FILE
	send 1G
}

function vi_search()
{
	send_command "/$1"
}

function vi_find_char()
{
	send "f$1"
}

function vi_insert_text()
{
	send "i$*"
}

function vi_add_line()
{
	send "o$*"
}

function vi_append_to_line()
{
	send "A$*"
}

function vi_change_line_from_cursor()
{
	send "C$*"
}

function vi_delete_line()
{
	send "dd"
}

function vi_change_line()
{
	send "S$*"
}

function vi_go_line()
{
	send "$1G"
}

function vi_up()
{
	send "k"
}

function vi_down()
{
	send "j"
}

function vi_save_and_close()
{
	send_command ":wq"
}

function print_file()
{
	send_command "cat $1"
}

now

for SCRIPT in $@
do
	. "$SCRIPT"
done
