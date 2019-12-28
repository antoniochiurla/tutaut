#!/usr/bin/env bash
. ../tutaut.sh
speed_up
FIXED_SPEED=1 . 01-init.sh

slow_down
operator dev1
info "Dev1 clones the repository"
create_dir $BASE/dev1
change_dir $BASE/dev1
git_clone $BASE/public/project
change_dir project
git_config user.name "dev1"
git_config user.email "dev1@tutaut"
info "... add feature1 on source file"
vi_open src1
vi_search second
vi_add_line
vi_add_line
vi_add_line
vi_add_line feature1
vi_save_and_close
info "... add src1 to index and commit"
git_add src1
git_commit feature 1
info "... pushes changes"
git_push

operator leader
info "Leader checks work done"
git_pull
git_log
print_file src1
pause 5
work_end
