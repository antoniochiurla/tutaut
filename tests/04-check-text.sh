#!/usr/bin/env bash
. ../tutaut.sh

BASE=/tmp/git-tutorial
rm -rf $BASE

DEBUG=1

view_operator master
create_dir $BASE
change_dir $BASE
FILENAME=long_name_for_file
PREV_NUM=0
vi_open $FILENAME.$PREV_NUM
vi_change_line content
vi_save_and_close
for NUM in {1..4}
do
	info "round ${NUM}" "è il giro numero ${NUM}"
	send_command mv $FILENAME.$PREV_NUM $FILENAME.$NUM
	PREV_NUM=$NUM
done
