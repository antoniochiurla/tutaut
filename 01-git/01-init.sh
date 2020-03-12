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
for OP in leader dev1 dev2
do
	operator $OP
	send_command 'alias vim="vim -n"'
       	clear_screen
done
slow_down

work_begin

operator leader
info "Leader crea il repository centrale"
create_dir $BASE/public/project
change_dir $BASE/public/project
git_init
pause
info "Crea la sua copia locale clonando il repository centrale"
create_dir $BASE/leader
change_dir $BASE/leader
git_clone $BASE/public/project
change_dir project
info "Imposta la sua identita'"
git_config user.name "leader"
git_config user.email "leader@tutaut"
pause
info "Quindi crea il primo file nel progetto"
vi_open src1
vi_change_line Initial content first line
vi_add_line Initial content second line
vi_save_and_close
pause
info "Aggiunge il file all'indice..."
git_add src1
pause
info "... crea un commit con le modifiche aggiunte all'indice"
git_commit
pause
info "... spedisce le modifiche al repository centrale"
git_push
pause
info "Controlla le operazioni fatte"
git_log
pause
info "Controlla lo stato del progetto"
git_status
pause 5
work_end
