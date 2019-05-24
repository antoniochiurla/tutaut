#!/usr/bin/env bash
. ../tutaut.sh

speed_up
FIXED_SPEED=1 .  02-dev1-add-feature.sh

slow_down
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
