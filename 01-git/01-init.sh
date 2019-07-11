#!/usr/bin/env bash
. ../tutaut.sh

BASE=/tmp/git-tutorial-${ID_USER}
rm -rf $BASE


if [ -n "$LEADER_GEOM" ]; then OPERATORS_GEOMETRY[leader]=$LEADER_GEOM; fi
if [ -n "$DEV1_GEOM" ]; then OPERATORS_GEOMETRY[dev1]=$DEV1_GEOM; fi
if [ -n "$DEV2_GEOM" ]; then OPERATORS_GEOMETRY[dev2]=$DEV2_GEOM; fi
if [ -n "$LEADER_SETUP_COMMAND" ]; then OPERATORS_SETUP_COMMAND[leader]=$LEADER_SETUP_COMMAND; fi
if [ -n "$DEV1_SETUP_COMMAND" ]; then OPERATORS_SETUP_COMMAND[dev1]=$DEV1_SETUP_COMMAND; fi
if [ -n "$DEV2_SETUP_COMMAND" ]; then OPERATORS_SETUP_COMMAND[dev2]=$DEV2_SETUP_COMMAND; fi

speed_up
for OP in leader dev1 dev2; do operator $OP; clear_screen;done
slow_down

work_begin

operator leader
info "Leader creates the central repository"
create_dir $BASE/public/project
change_dir $BASE/public/project
git_init
pause
info "Creates his own local repository cloning the central"
create_dir $BASE/leader
change_dir $BASE/leader
git_clone $BASE/public/project
change_dir project
info "Set up his name for identity"
git_config user.name "leader"
git_config user.email "leader@tutaut"
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
