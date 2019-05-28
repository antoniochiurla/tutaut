#!/usr/bin/env bash
. ../tutaut.sh

DEBUG=1
speed_up
FIXED_SPEED=1 . 03-dev2-add-feature.sh

operator dev1
info "Dev1 updates his local repository and branch"
git_pull
info "changes feature1"
vi_open src1
vi_search feature1
slow_down
vi_change_line feature1.1
vi_save_and_close
info "add, commit and pushes"
git_add src1
git_commit feature 1.1
git_push

speed_up
operator dev2
info "changes feature1"
vi_open src1
vi_search feature2
slow_down
vi_change_line feature2.1
vi_save_and_close
info "add and commit"
git_add src1
git_commit feature 2.1
info "Dev2 updates his local repository and branch using rebase"
git_pull_rebase
info "pushes changes"
git_push

operator leader
info "Leader checks work done"
git_pull
git_log
print_file src1
