#!/usr/bin/env bash
. ../tutaut.sh

speed_up
FIXED_SPEED=1 . 03-dev2-add-feature.sh

for CHANGE in {1..1}; do
	slow_down
	for SUBCHANGE in {1..3}; do
		operator dev1
		info "Dev1 updates project"
		git_pull_noff
		vi_save_and_close
		info "Dev1 make change $CHANGE.$SUBCHANGE"
		vi_open src1
		vi_search feature1
		vi_change_line feature1.$CHANGE.$SUBCHANGE
		vi_save_and_close
		info "add and commit"
		git_add src1
		git_commit feature 1 change $CHANGE.$SUBCHANGE
		pause
		#vi_save_and_close
		info "pushes"
		git_push
		pause
		operator leader
		info "Leader updates project"
		git_pull
		pause
		info "Leader make change $CHANGE.$SUBCHANGE.x"
		vi_open src1
		vi_search feature1
		vi_change_line feature1.$CHANGE.$SUBCHANGE.x
		vi_save_and_close
		info "add and commit"
		git_add src1
		git_commit feature 1 change $CHANGE.$SUBCHANGE.x
		vi_save_and_close
		info "pushes"
		git_push
		pause
		operator dev2
		info "Dev2 updates project"
		git_pull
		pause
		vi_save_and_close
		info "Dev2 make change $CHANGE.$SUBCHANGE"
		vi_open src1
		vi_search feature2
		vi_change_line feature2.$CHANGE.$SUBCHANGE
		vi_save_and_close
		info "add and commit"
		git_add src1
		git_commit feature 2 change $CHANGE.$SUBCHANGE
	done

	operator dev2
	info "Dev2 updates project before push"
	git_pull
	vi_save_and_close
	info "Dev2 pushes"
	git_push
done

info "Leader checks work done"
operator leader
git_pull
git_log
print_file src1
pause 5
work_end
