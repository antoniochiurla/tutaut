#!/usr/bin/env bash
. ../tutaut.sh

BASE=/tmp/git-tutorial
rm -rf $BASE

for OP in leader dev1 dev2; do operator $OP; clear_screen;done

work_begin

operator leader
info "Operator creates the central repository"
create_dir $BASE/public/project
change_dir $BASE/public/project
git_init
pause
info "Then create his own local repository cloning the central"
create_dir $BASE/leader
change_dir $BASE/leader
git_clone $BASE/public/project
change_dir project
pause
info "Then creates first file to project"
vi_open src1
vi_change_line Initial content first line
vi_add_line Initial content second line
vi_save_and_close
pause
info "Finally add the file to the index..."
git_add src1
pause
info "... record changes to the repository invoking commit"
git_commit
pause
info "... update remote refs invoking push"
git_push
pause
info "Show actual log"
git_log
pause 5
work_end
