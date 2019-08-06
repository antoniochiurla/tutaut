#!/usr/bin/env bash
. ../tutaut.sh

speed_up
FIXED_SPEED=1 . 03-dev2-add-feature.sh

for CHANGE in {2..3}; do
	info "Dev1 make change $CHANGE"
	operator dev1
	git_pull
	vi_open src1
	vi_search feature1
	vi_change_line feature1.$CHANGE
	vi_save_and_close
	info "add, commit and pushes"
	git_add src1
	git_commit feature 1.$CHANGE
	git_push

	info "Dev1 make change $CHANGE"
	operator dev2
	vi_open src1
	vi_search feature2
	vi_change_line feature2.$CHANGE
	vi_save_and_close
	info "add, commit and pushes"
	git_add src1
	git_commit feature 2.$CHANGE
	git_pull_rebase
	git_push
done

operator leader
info "Leader checks work done"
git_pull
git_log
print_file src1
pause 5
work_end
