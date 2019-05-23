#!/usr/bin/env bash
. ../functions.sh

speed_up
FIXED_SPEED=1 . 03-dev2-add-feature.sh

operator dev1
git_pull
vi_open src1
info Changing feature1
vi_search feature1
#slow_down
vi_change_line feature1.1
info Changing feature2 as intruder
vi_search feature2
vi_change_line feature2.intruder
vi_save_and_close
git_add src1
info Commit changes
git_commit feature 1.1 and 2.intruder
vi_open src1
info Changing feature2 as intruder again
vi_search feature2
vi_change_line feature2.intruder.and.again
vi_save_and_close
git_add src1
info Commit last change
git_commit feature 1.1 and 2.intruder and 2.intruder.again
git_push

speed_up
operator dev2
vi_open src1
vi_search feature2
#slow_down
info fixing feature2
vi_change_line feature2.1
vi_save_and_close
git_add src1
info local commit
git_commit feature 2.1
info fetch and pull
git_pull
vi_open src1
info resolve conflict
vi_search HEAD
slow_down
do_suspend
vi_down
vi_down
vi_down
vi_search intruder
info redoing the change upon new source
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
git_add src1
git_merge_continue
info comment the merge
vi_insert_text "Manually "
vi_save_and_close
info push changes
git_push

operator leader
git_pull
git_log
print_file src1
