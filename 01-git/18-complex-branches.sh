#!/usr/bin/env bash
. ../functions.sh

speed_up
FIXED_SPEED=1 . 01-init.sh

operator leader
git_pull
vi_open src1
vi_search second
vi_add_line
vi_add_line
vi_add_line
vi_add_line feature1
vi_add_line
vi_add_line
vi_add_line
vi_add_line feature2
vi_add_line
vi_add_line
vi_add_line
vi_add_line feature3
vi_add_line
vi_add_line
vi_add_line
vi_add_line feature4
vi_add_line
vi_add_line
vi_add_line
vi_add_line feature5
vi_add_line
vi_add_line
vi_add_line
vi_add_line feature6
vi_save_and_close
git_add src1
git_commit stub for features 1 to 6
git_push
FEATURES="0 2 4"
CHANGES="1 2 3 4"

for DEV in 1 2; do
	operator dev$DEV
	create_dir $BASE/dev$DEV
	change_dir $BASE/dev$DEV
	git_clone $BASE/public/project
	change_dir project
done
for FEAT in $FEATURES;do
	for DEV in 1 2; do
		operator dev$DEV
		FEATURE=$((FEAT+DEV))
		git_checkout -b feat$FEATURE
		git_push -u origin feat$FEATURE
		git_branch -u origin/feat$FEATURE feat$FEATURE
	done
done
for FEAT in $FEATURES;do
	for CHANGE in $CHANGES; do
		for DEV in 1 2; do
			operator dev$DEV
			FEATURE=$((FEAT+DEV))
			git_pull
			git_checkout feat$FEATURE
			vi_open src1
			vi_search feature$FEATURE
			vi_change_line feature$FEATURE.$CHANGE
			vi_save_and_close
			git_add src1
			git_commit feature $FEATURE.$CHANGE
			git_push
		done
	done
done
for FEAT in $FEATURES;do
	for DEV in 1 2; do
		operator dev$DEV
		FEATURE=$((FEAT+DEV))
		git_checkout master
		git_pull
		git_merge --no-ff feat$FEATURE
		vi_insert_text "Manual "
		vi_save_and_close
		git_push
	done
done

operator leader
git_pull
git_log
print_file src1
