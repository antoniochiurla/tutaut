#!/usr/bin/env bash
. ../functions.sh

speed_up
FIXED_SPEED=1 . 03-dev2-add-feature.sh

FIXED_SPEED=1
for CHANGE in {1..1}; do
	speed_up
	operator dev1
	git_pull
	operator dev2
	git_pull
	#slow_down
	for SUBCHANGE in {1..3}; do
		operator dev1
		git_pull
		vi_open src1
		vi_search feature1
		vi_change_line feature1.$CHANGE.$SUBCHANGE
		vi_save_and_close
		git_add src1
		git_commit feature 1 change $CHANGE.$SUBCHANGE
		pause
		#vi_save_and_close
		git_push
		pause
		operator leader
		git_pull
		pause
		vi_open src1
		vi_search feature1
		vi_change_line feature1.$CHANGE.$SUBCHANGE.x
		vi_save_and_close
		git_add src1
		git_commit feature 1 change $CHANGE.$SUBCHANGE.x
		#vi_save_and_close
		git_push
		pause
		operator dev2
		git_pull_rebase
		pause
		#vi_save_and_close
		vi_open src1
		vi_search feature2
		vi_change_line feature2.$CHANGE.$SUBCHANGE
		vi_save_and_close
		git_add src1
		git_commit feature 2 change $CHANGE.$SUBCHANGE
	done

	operator dev2
	git_pull
	#vi_save_and_close
	git_push
done

operator leader
git_pull
git_log
print_file src1
