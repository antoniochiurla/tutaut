#!/usr/bin/env bash
. ../tutaut.sh

speed_up
FIXED_SPEED=1 . 03-dev2-add-feature.sh

for CHANGE in {2..3}; do
	operator dev1
	git_pull
	vi_open src1
	vi_search feature1
	vi_change_line feature1.$CHANGE
	vi_save_and_close
	git_add src1
	git_commit feature 1.$CHANGE
	git_push

	operator dev2
	vi_open src1
	vi_search feature2
	vi_change_line feature2.$CHANGE
	vi_save_and_close
	git_add src1
	git_commit feature 2.$CHANGE
	git_pull_rebase
	git_push
done

operator leader
git_pull
git_log
print_file src1
