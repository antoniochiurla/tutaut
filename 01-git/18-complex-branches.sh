#!/usr/bin/env bash
. ../functions.sh

speed_up
FIXED_SPEED=1 . 01-init.sh

slow_down
info Leader adds stubs for new features
operator leader
git_pull
vi_open src1
vi_search second
for FEATURE in {1..6};do
	vi_add_line
	vi_add_line
	vi_add_line
	vi_add_line feature$FEATURE
done
vi_save_and_close
git_add src1
git_commit stubs for features 1 to 6
info Leader pushes changes
git_push
FEATURES="0 2 4"
CHANGES="1 2 3 4"

info Developers clone the repository
for DEV in 1 2; do
	operator dev$DEV
	create_dir $BASE/dev$DEV
	change_dir $BASE/dev$DEV
	git_clone $BASE/public/project
	change_dir project
done
info Developers create branches for features
for FEAT in $FEATURES;do
	for DEV in 1 2; do
		operator dev$DEV
		FEATURE=$((FEAT+DEV))
		git_checkout -b feat$FEATURE
		git_push -u origin feat$FEATURE
		git_branch -u origin/feat$FEATURE feat$FEATURE
	done
	speed_up
done
slow_down
for FEAT in $FEATURES;do
	for CHANGE in $CHANGES; do
		for DEV in 1 2; do
			FEATURE=$((FEAT+DEV))
			info dev$DEV change feature$FEATURE time: $CHANGE
			operator dev$DEV
			git_pull
			git_checkout feat$FEATURE
			vi_open src1
			vi_search feature$FEATURE
			vi_change_line feature$FEATURE.$CHANGE
			vi_save_and_close
			git_add src1
			git_commit feature $FEATURE.$CHANGE
			info dev$DEV pushes the change
			git_push
		done
		speed_up
	done
done
slow_down
for FEAT in $FEATURES;do
	for DEV in 1 2; do
		info dev$DEV switch to master branch
		operator dev$DEV
		FEATURE=$((FEAT+DEV))
		git_checkout master
		git_pull
		info dev$DEV merge feature $FEATURE branch in master branch
		git_merge --no-ff feat$FEATURE
		vi_insert_text "Manual "
		vi_save_and_close
		info dev$DEV pushes merged stuff
		git_push
	done
	speed_up
done

slow_down
info Leader check work done
operator leader
git_pull
git_log
print_file src1
