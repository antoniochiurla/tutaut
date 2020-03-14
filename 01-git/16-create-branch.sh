#!/usr/bin/env bash
. ../tutaut.sh

speed_up
FIXED_SPEED=1 . 01-init.sh

info Leader create stubs for features
view_operator leader
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
git_commit stubs for features 1 and 2
git_push

info dev1 clone repository
view_operator dev1
create_dir $BASE/dev1
change_dir $BASE/dev1
git_clone $BASE/public/project
change_dir project
info dev1 creates new feat1 branch...
git_checkout -b feat1
info ... pushes it on remote
git_push -u origin feat1
info ... configure remote new branch as upstream for the local one
git_branch -u origin/feat1 feat1
info ... implements new feature
vi_open src1
vi_search feature1
vi_change_line feature1.1
vi_save_and_close
git_add src1
git_commit feature 1.1
info ... push changes
git_push

view_operator leader
git_pull
info Leader check the log
git_log
info the work is stored on origin/feat1 branch
info the master branch is untouched
print_file src1
pause 5
work_end
