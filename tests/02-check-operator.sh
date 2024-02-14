#!/usr/bin/env bash
. ../tutaut.sh

DEBUG=1
BASE=/tmp/git-tutorial-${ID_USER}
rm -rf $BASE

if [ -n "$LEADER_GEOM" ]; then OPERATORS_GEOMETRY[leader]=$LEADER_GEOM; fi
if [ -n "$DEV1_GEOM" ]; then OPERATORS_GEOMETRY[dev1]=$DEV1_GEOM; fi
if [ -n "$DEV2_GEOM" ]; then OPERATORS_GEOMETRY[dev2]=$DEV2_GEOM; fi
if [ -n "$LEADER_SETUP_COMMAND" ]; then OPERATORS_SETUP_COMMAND[leader]=$LEADER_SETUP_COMMAND; fi
if [ -n "$DEV1_SETUP_COMMAND" ]; then OPERATORS_SETUP_COMMAND[dev1]=$DEV1_SETUP_COMMAND; fi
if [ -n "$DEV2_SETUP_COMMAND" ]; then OPERATORS_SETUP_COMMAND[dev2]=$DEV2_SETUP_COMMAND; fi

for OP in leader dev1 dev2; do view_operator $OP; clear_screen;done
view_operator leader
create_dir $BASE/public/project
change_dir $BASE/public/project
git_init
create_dir $BASE/leader
change_dir $BASE/leader
git_clone $BASE/public/project
change_dir project
vi_open src1
vi_change_line Initial content first line
vi_add_line Initial content second line
vi_save_and_close
git_add src1
git_commit
git_push

view_operator dev1
create_dir $BASE/dev1
change_dir $BASE/dev1
git_clone $BASE/public/project
change_dir project
vi_open src1
vi_search second
vi_add_line
vi_add_line
vi_add_line
vi_add_line feature1
vi_save_and_close
git_add src1
git_commit feature 1
git_push

view_operator dev2
create_dir $BASE/dev2
change_dir $BASE/dev2
git_clone $BASE/public/project
change_dir project
vi_open src1
vi_search feature1
vi_add_line
vi_add_line
vi_add_line
vi_add_line feature2
vi_save_and_close
git_add src1
git_commit feature 2
git_push

view_operator leader
git_pull
git_log
print_file src1

view_operator dev1
git_pull
vi_open src1
vi_search feature1
#slow_down
vi_change_line feature1.1
vi_save_and_close
git_add src1
git_commit feature 1.1
git_push

speed_up
view_operator dev2
vi_open src1
vi_search feature2
slow_down
vi_change_line feature2.1
vi_save_and_close
git_add src1
git_commit feature 2.1
git_pull_rebase
git_push

MAX_WAIT_CHAR=0
view_operator leader
git_pull
git_log
print_file src1
