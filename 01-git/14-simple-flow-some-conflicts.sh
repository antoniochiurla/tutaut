#!/usr/bin/env bash
. ../functions.sh

speed_up
FIXED_SPEED=1 . 03-dev2-add-feature.sh

operator dev1
git_pull
vi_open src1
vi_search feature1
vi_change_line feature1.1
vi_search feature2
vi_change_line feature2.intruder
#slow_down
vi_save_and_close
git_add src1
git_commit feature 1.1 and 2.intruder
vi_open src1
vi_search feature2
vi_change_line feature2.intruder.and.again
slow_down
vi_save_and_close
git_add src1
git_commit feature 1.1 and 2.intruder and 2.intruder.again
git_push

speed_up
operator dev2
vi_open src1
vi_search feature2
vi_change_line feature2.1
vi_save_and_close
git_add src1
git_commit feature 2.1
slow_down
git_pull_rebase
git_am_show_current_patch
vi_open src1
vi_search HEAD
vi_delete_line
vi_down
vi_delete_line
vi_delete_line
vi_delete_line
vi_search intruder
vi_insert_text 1.
vi_save_and_close
git_add src1
git_rebase_continue
git_push

operator leader
git_pull
git_log
print_file src1
