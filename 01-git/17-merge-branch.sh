#!/usr/bin/env bash
. ../tutaut.sh

speed_up
FIXED_SPEED=1 . 16-create-branch.sh

info dev2 implements feature2 directly on aster branch
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

info dev1 switch to master branch
operator dev1
git_checkout master
git_pull
info ... merge the change
git_merge feat1
info ... comment the merge
vi_insert_text "Manual "
vi_save_and_close
info ... pushes the merged data
git_push

info Leader che work done
operator leader
git_pull
git_log
info in log is noticeable the branch used for feature1 changes
print_file src1
pause 5
work_end
