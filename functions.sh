if [ -z "$TUTAUT" ]; then
	TUTAUT=1
	SRC=src
	DEFAULT_MIN_WAIT_CHAR=0
	DEFAULT_MAX_WAIT_CHAR=300
	DEFAULT_WAIT_AFTER_SPACE=0.5
	DEFAULT_WAIT_BEFORE_ENTER=1.0
	DEFAULT_WAIT_AFTER_COMMAND=2.0
	DEFAULT_ERRORS_PERCENT=5
	DO_PAUSE=1
	DEFAULT_PAUSE=3
	MIN_WAIT_CHAR=$DEFAULT_MIN_WAIT_CHAR
	MAX_WAIT_CHAR=$DEFAULT_MAX_WAIT_CHAR
	WAIT_AFTER_SPACE=$DEFAULT_WAIT_AFTER_SPACE
	WAIT_BEFORE_ENTER=$DEFAULT_WAIT_BEFORE_ENTER
	WAIT_AFTER_COMMAND=$DEFAULT_WAIT_AFTER_COMMAND
	ERRORS_PERCENT=$DEFAULT_ERRORS_PERCENT
	OPERATOR=
	declare -A OPERATORS
	WINDOW_TYPE=tmux
	XTERM_SMALL_FONT=
fi
BACKSPACES="\\h\\h\\h\\h\\h\\h\\h\\h\\h\\h"
BACKSPACES_NOT_ESCAPED=""
FILE_INFO=/tmp/tutaut.info
FILE_DEBUG=/tmp/tutaut.debug

if which sox 2>/dev/null
then
	SOX=$(which sox)
fi

stty -icanon min 1
COMMAND_KEY_STEP=" "

function now()
{
	TIME_NOW=$(date +%s%N)
	TIME_START=${TIME_START:-$TIME_NOW}
	TIME_ELAPSED=$((TIME_NOW-TIME_START))
}

function info()
{
	now
	echo "$*" 1>&2
	echo "$TIME_ELAPSED:info:$*" >>$FILE_INFO
}

function debug()
{
	if [ -n "$DEBUG" ]
	then
		now
		echo "$*" 1>&2
		echo "$TIME_ELAPSED:$*" >>$FILE_DEBUG
	fi
}

work_begin()
{
	TIME_START=
	now
	echo "$TIME_ELAPSED:begin:" >$FILE_INFO
}

work_end()
{
	echo "$TIME_ELAPSED:end:" >>$FILE_INFO
}

function operator()
{
	OPERATOR=$1
	if [ -z ${OPERATORS[$OPERATOR]} ]; then
		FOUND_SESSION=$(tmux list-sessions | cut -d":" -f1 | grep $OPERATOR)
		if [ -z ${FOUND_SESSION} ]; then
			launch_terminal_on_new_session
			FIRST_FREE_SESSION=$(tmux list-sessions | cut -d":" -f1 | grep "^[0-9]" | sort -n | head -1)
			debug "renaming tmux session $FIRST_FREE_SESSION to $OPERATOR"
			tmux rename-session -t$FIRST_FREE_SESSION $OPERATOR
			tmux_set_option destroy-unattached on
		else
			launch_terminal_on_existing_session $OPERATOR
		fi
		OPERATORS[$OPERATOR]=1
	fi
	debug "switch to operator $OPERATOR"
	now
	echo "$TIME_ELAPSED:operator:$OPERATOR" >>$FILE_INFO
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
	if [ -n "$XTERM_SMALL_FONT" ]
	then
		XTERM_OPT_NAME="-name XTermNoTTF"
	fi
	xterm $XTERM_OPT_NAME -si -sk -sb -sl 10000 -rightbar $SHELL_TERMINAL &
}

function speed_up()
{
	if [ -z "$FIXED_SPEED" ];then
		MIN_WAIT_CHAR=$DEFAULT_MIN_WAIT_CHAR
		MAX_WAIT_CHAR=0
		WAIT_AFTER_SPACE=0
		WAIT_BEFORE_ENTER=0
		WAIT_AFTER_COMMAND=0.2
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
		ERRORS_PERCENT=$DEFAULT_ERRORS_PERCENT
		DO_PAUSE=1
	fi
}

function wait_after_space()
{
	#debug "wait after space"
	sleep $WAIT_AFTER_SPACE
}

function wait_before_enter()
{
	#debug "wait before enter"
	sleep $WAIT_BEFORE_ENTER
}

function wait_after_command()
{
	#debug "wait after command"
	sleep $WAIT_AFTER_COMMAND
}

function wait_before_char()
{
	while [ -n "$STOPPED" -a "${STEP_ON:-0}" -lt 1 ]; do
		command_check
	done
	[ -n "$STEP_ON" ] && STEP_ON=$((STEP_ON-1))
	TRY_1_ON_10=$((RANDOM%100))
	if [ $TRY_1_ON_10 -ge 70 ]; then
		AMOUNT=$((MIN_WAIT_CHAR+RANDOM))
		[ $AMOUNT -gt $MAX_WAIT_CHAR ] && AMOUNT=$MAX_WAIT_CHAR
		MS=$((AMOUNT%1000))
		sleep 0.$MS
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

function sound_tap()
{
	if [ -n "$SOX" ];then
		play -n synth brownnoise synth sine mix synth 0.002 sine amod 30 2>/dev/null&
	fi
}

function to_operator()
{
	command_check
	CH="$1"
	if [ $MAX_WAIT_CHAR -eq 0 ];then
		BUFFER+="$CH"
	else
		wait_before_char
		#sound_tap
		to_operator_direct "$CH"
	fi
}

function to_operator_direct()
{
	CH="$1"
	if [ -n "$OPERATOR" ]; then
		if [ "${CH:0:1}" = "\\" ]; then
			#debug "sending control key to operator"
			CONTROL=${CH:1:1}
			case $CONTROL in 
				n) tmux send -t$OPERATOR "
";;
				h) tmux send -t$OPERATOR "";;
				*) debug "ERROR unknown \\$CONTROL control key";;
			esac
		else
			tmux send -t$OPERATOR -- "$CH"
		fi
	else
		echo -ne "$CH"
	fi
}

function send_flush()
{
	#debug "flush: $BUFFER"
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
				LEN_MISTAKE_DOUBLE=$((LEN_MISTAKE*2))
				CORRECTION=${BACKSPACES:0:$LEN_MISTAKE_DOUBLE}
			else
				MISTAKE=" "
				CORRECTION="\\h"
			fi
			debug "Adding error $POS $LEN1 $LEN2 $MISTAKE $CORRECTION"
			ALL_NEW="${ALL:0:$LEN1}${MISTAKE}${CORRECTION}${ALL:$POS2:$LEN2}"
			#ALL_NEW="${ALL:0:$LEN1}a\\h${ALL:$POS2:$LEN2}"
			ALL="$ALL_NEW"
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
		elif [ "${CH:0:1}" = "\\" ]; then
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
	read -t 0.00001 COMMAND
	if [ -n "$COMMAND" ]; then
		command_exec "$COMMAND"
	fi
}

function command_exec()
{
	debug "Executing command: $COMMAND"
	case "$COMMAND" in
	s) STOPPED=1; debug "Stopped";;
	S) unset STOPPED; debug "Restarted";;
	[0-9]) COMMAND_NUM=$COMMAND$COMMAND_NUM; debug "Num: $COMMAND_NUM";;
	+) STEP_ON=${COMMAND_NUM:-1}; debug "Step on: $STEP_ON";;
	esac
}

function pause()
{
	if [ -n "$DO_PAUSE" ]
	then
		debug "Waiting for $1..."
		TMOUT=${1:-$DEFAULT_PAUSE}
		read PAUSE
		TMOUT=
	fi
}

function git_init()
{
	send_command git init --bare
}

function git_clone()
{
	send_command git clone "$@"
}

function git_add()
{
	send_command git add "$@"
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

function git_push()
{
	send_command git push
}

function git_commit()
{
	COMMENT="$*"
	COMMENT=${COMMENT:-no comment}
	send_command git commit -m "\"$COMMENT from op $OPERATOR\""
}

function git_push()
{
	send_command git push
}

function git_diff()
{
	send_command git diff
}

function git_log()
{
	send_command "git log --graph --oneline | cat"
}

function vi_open()
{
	FILE=${1:-$SRC}
	send_command vi $FILE
	send 1G
}

function vi_search()
{
	send_command "/$1"
}

function vi_add_line()
{
	send "o$*"
}

function vi_delete_line()
{
	send "dd"
}

function vi_change_line()
{
	send "^C$*"
}

function vi_go_line()
{
	send_command "$1G"
}

function vi_up()
{
	send_command "k"
}

function vi_down()
{
	send_command "j"
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
