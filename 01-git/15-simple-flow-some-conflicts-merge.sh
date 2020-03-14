#!/usr/bin/env bash
. ../tutaut.sh

speed_up
FIXED_SPEED=1 . 03-dev2-add-feature.sh

view_operator dev1
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
vi_open src1
info "Dev1 make intruder again change to feature2"
vi_search feature2
vi_change_line feature2.intruder.and.again
vi_save_and_close
info "add and commit"
git_add src1
git_commit feature 2.intruder.again
git_push

view_operator dev2
info "Dev2 make change feature2"
vi_open src1
vi_search feature2
vi_change_line feature2.1
vi_save_and_close
git_add src1
git_commit feature 2.1
info "Dev2 updates project with defaut merge option"
git_pull
info "Dev2 decide how to merge the changes"
vi_open src1
vi_search HEAD
do_suspend
vi_down
vi_down
vi_down
vi_search intruder
vi_insert_text 1.
vi_down
vi_delete_line
vi_up
vi_up
vi_up
vi_delete_line
vi_delete_line
vi_delete_line
vi_save_and_close
info "add and continue merge completing merge comment"
git_add src1
git_merge_continue
vi_insert_text "Manually "
vi_save_and_close
info "pushes"
git_push

view_operator leader
info "Leader checks work done"
git_pull
git_log
print_file src1
pause 5
work_end
