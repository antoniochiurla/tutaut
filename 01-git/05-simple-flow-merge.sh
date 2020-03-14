#!/usr/bin/env bash
. ../tutaut.sh

DEBUG=1

speed_up
FIXED_SPEED=1 . 03-dev2-add-feature.sh

view_operator dev1
info "Dev1 aggiorna la sua copia locale del progetto"
git_pull
info "modifica feature1"
vi_open src1
vi_search feature1
slow_down
vi_change_line feature1.1
vi_save_and_close
info "aggiunge all'indice, crea il commit e spedisce"
git_add src1
git_commit feature 1.1
git_push

speed_up
view_operator dev2
info "Dev2 modifica feature2"
vi_open src1
vi_search feature2
slow_down
vi_change_line feature2.1
vi_save_and_close
info "aggiunge all'indice e crea il commit"
git_add src1
git_commit feature 2.1
info "Dev2 aggiorna la copia locale ed il branch in modo merge"
git_pull
vi_save_and_close
info "spedisce le modifiche"
git_push

view_operator leader
info "Leader controlla il lavoro fatto"
git_pull
git_log
print_file src1
pause 5
work_end
