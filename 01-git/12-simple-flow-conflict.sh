#!/usr/bin/env bash
. ../tutaut.sh

speed_up
FIXED_SPEED=1 . 03-dev2-add-feature.sh

operator dev1
info "Dev1 updates project"
git_pull
info "Dev1 make intruder change to feature2"
vi_open src1
vi_search feature2
vi_change_line feature2.intruder
slow_down
vi_save_and_close
info "add and commit"
git_add src1
git_commit feature 2.intruder
info "pushes"
git_push

operator dev2
info "Dev2 make change feature2"
vi_open src1
vi_search feature2
vi_change_line feature2.1
vi_save_and_close
git_add src1
git_commit feature 2.1
info "Dev2 updates project with rebase option"
git_pull_rebase
info "Dev2 check conflict"
git_am_show_current_patch
info "Dev2 decide how to merge the changes"
vi_open src1
vi_search HEAD
vi_delete_line
vi_down
vi_delete_line
vi_delete_line
vi_delete_line
vi_change_line feature2.1.and.intruder
vi_save_and_close
info "add and continue rebase"
git_add src1
git_rebase_continue
info "pushes"
git_push

operator leader
info "Leader checks work done"
git_pull
git_log
print_file src1
