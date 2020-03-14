#!/usr/bin/env bash
. ../tutaut.sh

speed_up
FIXED_SPEED=1 .  02-dev1-add-feature.sh

slow_down
view_operator dev2
info "Dev2 clona il progetto"
create_dir $BASE/dev2
change_dir $BASE/dev2
git_clone $BASE/public/project
change_dir project
git_config user.name "dev2"
git_config user.email "dev2@tutaut"
info "... aggiunge feature2 nel file src1"
vi_open src1
vi_search feature1
vi_add_line
vi_add_line
vi_add_line
vi_add_line feature2
vi_save_and_close
info "... aggiunge il file src1 all'indice e crea un commit"
git_add src1
git_commit feature 2
info "... spedisce le modifiche"
git_push

view_operator leader
info "Leader controlla il lavoro fatto"
git_pull
git_log
print_file src1
pause 5
work_end
