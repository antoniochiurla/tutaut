#!/usr/bin/env bash
. ../tutaut.sh

speed_up
FIXED_SPEED=1 . 03-dev2-add-feature.sh

for CHANGE in {2..3}; do
	operator dev1
	git_pull
	for SUBCHANGE in {1..4}; do
		info "Dev1 make change $CHANGE.$SUBCHANGE"
		operator dev1
		vi_open src1
		vi_search feature1
		vi_change_line feature1.$CHANGE.$SUBCHANGE
		vi_save_and_close
		info "add and commit"
		git_add src1
		git_commit feature 1.$CHANGE.$SUBCHANGE
		info "pull changes"
		git_pull
		vi_save_and_close
		info "pushes"
		git_push
	done

	operator dev2
	info "Dev2 make change $CHANGE"
	vi_open src1
	vi_search feature2
	vi_change_line feature2.$CHANGE
	vi_save_and_close
	info "add and commit"
	git_add src1
	git_commit feature 2.$CHANGE
	info "pull changes before push"
	git_pull
	vi_save_and_close
	info "pushes"
	git_push
done

info "Leader checks work done"
operator leader
git_pull
git_log
print_file src1
pause 5
work_end
