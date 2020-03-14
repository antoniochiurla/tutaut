#!/usr/bin/env bash
. ../tutaut.sh

speed_up
FIXED_SPEED=1 . 03-dev2-add-feature.sh

for CHANGE in {2..3}; do
	view_operator dev1
	git_pull
	for SUBCHANGE in {1..4}; do
		info "Dev1 esegue la modifica $CHANGE.$SUBCHANGE"
		view_operator dev1
		vi_open src1
		vi_search feature1
		vi_change_line feature1.$CHANGE.$SUBCHANGE
		vi_save_and_close
		info "aggiunge all'indice, crea il commit e spedisce"
		git_add src1
		git_commit feature 1.$CHANGE.$SUBCHANGE
		info "aggiorna la copia locale"
		git_pull
		vi_save_and_close
		info "spedisce le modifiche"
		git_push
	done

	view_operator dev2
	info "Dev2 esegue la modifica $CHANGE"
	vi_open src1
	vi_search feature2
	vi_change_line feature2.$CHANGE
	vi_save_and_close
	info "aggiunge all'indice e crea il commit"
	git_add src1
	git_commit feature 2.$CHANGE
	info "aggiorna la copia locale prima di spedire le modifiche"
	git_pull
	vi_save_and_close
	info "spedisce le modifiche"
	git_push
done

info "Leader controlla la lista delle modifiche"
view_operator leader
git_pull
git_log
print_file src1
pause 5
work_end
