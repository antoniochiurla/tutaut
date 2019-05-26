#!/usr/bin/env bash
. ../tutaut.sh

BASE=/tmp/git-tutorial
rm -rf $BASE

DEBUG=1

operator master
create_dir $BASE
change_dir $BASE
FILENAME=long_name_for_file
PREV_NUM=0
vi_open $FILENAME.$PREV_NUM
vi_change_line content
vi_save_and_close
for NUM in {1..90}
do
	send_command mv $FILENAME.$PREV_NUM $FILENAME.$NUM
	PREV_NUM=$NUM
done
