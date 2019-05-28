#!/usr/bin/env bash
. ../tutaut.sh

speed_up
FIXED_SPEED=1 .  02-dev1-add-feature.sh

slow_down
operator dev2
info "Dev2 clones the repository"
create_dir $BASE/dev2
change_dir $BASE/dev2
git_clone $BASE/public/project
change_dir project
info "... add feature2 on source file"
vi_open src1
vi_search feature1
vi_add_line
vi_add_line
vi_add_line
vi_add_line feature2
vi_save_and_close
info "... add src1 to index and commit"
git_add src1
git_commit feature 2
info "... pushes changes"
git_push

operator leader
info "Leader checks work done"
git_pull
git_log
print_file src1
