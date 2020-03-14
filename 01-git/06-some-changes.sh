#!/usr/bin/env bash
. ../tutaut.sh

speed_up
FIXED_SPEED=1 . 03-dev2-add-feature.sh

for CHANGE in {2..3}; do
	info "Dev1 esegue la modifica $CHANGE"
	view_operator dev1
	git_pull
	vi_open src1
	vi_search feature1
	vi_change_line feature1.$CHANGE
	vi_save_and_close
	info "aggiunge all'indice, crea il commit e spedisce"
	git_add src1
	git_commit feature 1.$CHANGE
	git_push

	info "Dev2 esegue la modifica $CHANGE"
	view_operator dev2
	vi_open src1
	vi_search feature2
	vi_change_line feature2.$CHANGE
	vi_save_and_close
	info "aggiunge all'indice, crea il commit e spedisce"
	git_add src1
	git_commit feature 2.$CHANGE
	git_pull_rebase
	git_push
done

view_operator leader
info "Leader controlla il lavoro fatto"
git_pull
git_log
print_file src1
pause 5
work_end
