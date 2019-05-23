#!/usr/bin/env bash
. ../functions.sh

speed_up
FIXED_SPEED=1 . 16-create-branch.sh

operator dev2
create_dir $BASE/dev2
change_dir $BASE/dev2
git_clone $BASE/public/project
change_dir project
vi_open src1
vi_search feature2
vi_change_line feature2.1
vi_save_and_close
git_add src1
git_commit feature 2.1
git_push

operator dev1
git_checkout master
git_pull
git_merge feat1
vi_insert_text "Manual "
vi_save_and_close
git_push

operator leader
git_pull
git_log
print_file src1
