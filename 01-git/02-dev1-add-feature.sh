#!/usr/bin/env bash
. ../tutaut.sh
speed_up
FIXED_SPEED=1 . 01-init.sh

slow_down
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

operator leader
git_pull
git_log
print_file src1
