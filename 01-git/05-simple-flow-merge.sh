#!/usr/bin/env bash
. ../tutaut.sh

speed_up
FIXED_SPEED=1 . 03-dev2-add-feature.sh

operator dev1
git_pull
vi_open src1
vi_search feature1
slow_down
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
git_pull
vi_save_and_close
git_push

operator leader
git_pull
git_log
print_file src1
