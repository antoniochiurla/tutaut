#!/usr/bin/env bash
. ../functions.sh

speed_up
FIXED_SPEED=1 . 01-init.sh

operator leader
git_pull
vi_open src1
vi_search second
vi_add_line
vi_add_line
vi_add_line
vi_add_line feature1
vi_add_line
vi_add_line
vi_add_line
vi_add_line feature2
vi_save_and_close
git_add src1
git_commit stub for features 1 and 2
git_push

operator dev1
create_dir $BASE/dev1
change_dir $BASE/dev1
git_clone $BASE/public/project
change_dir project
git_checkout -b feat1
git_push -u origin feat1
git_branch -u origin/feat1 feat1
vi_open src1
vi_search feature1
vi_change_line feature1.1
vi_save_and_close
git_add src1
git_commit feature 1.1
git_push

operator leader
git_pull
git_log
print_file src1
