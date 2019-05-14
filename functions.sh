if [ -z "$TUTAUT" ]; then
	TUTAUT=1
	SRC=src
	DEFAULT_MIN_WAIT_CHAR=0
	DEFAULT_MAX_WAIT_CHAR=300
	DEFAULT_WAIT_AFTER_SPACE=0.5
	DEFAULT_WAIT_BEFORE_ENTER=1.0
	DEFAULT_WAIT_AFTER_COMMAND=2.0
	DEFAULT_ERRORS_PERCENT=10
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

function info()
{
	echo "$*" 1>&2
}

function debug()
{
	if [ -n "$DEBUG" ]
	then
		echo "$*" 1>&2
	fi
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
	AMOUNT=$((MIN_WAIT_CHAR+RANDOM))
	[ $AMOUNT -gt $MAX_WAIT_CHAR ] && AMOUNT=$MAX_WAIT_CHAR
	MS=$((AMOUNT%1000))
	sleep 0.$MS
}

function to_operator()
{
	CH="$1"
	if [ $MAX_WAIT_CHAR -eq 0 ];then
		BUFFER+="$CH"
	else
		TRY_1_ON_10=$((RANDOM%100))
		if [ $TRY_1_ON_10 -ge 70 ]; then
			wait_before_char
		fi
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
