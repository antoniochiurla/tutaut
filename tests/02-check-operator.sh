#!/usr/bin/env bash
. ../tutaut.sh

DEBUG=1
BASE=/tmp/git-tutorial
rm -rf $BASE

for OP in leader dev1 dev2; do operator $OP; clear_screen;done
operator leader
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

operator dev1
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

operator dev2
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

operator leader
git_pull
git_log
print_file src1

operator dev1
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
operator dev2
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
operator leader
git_pull
git_log
print_file src1
