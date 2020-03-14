#!/usr/bin/env bash
. ../tutaut.sh

speed_up
FIXED_SPEED=1 . 03-dev2-add-feature.sh

for CHANGE in {2..2}; do
	for SUBCHANGE in {1..3}; do
		info "Dev1 esegue la modifica $CHANGE.$SUBCHANGE"
		view_operator dev1
		git_pull
		vi_open src1
		vi_search feature1
		vi_change_line feature1.$CHANGE.$SUBCHANGE
		vi_save_and_close
		info "aggiunge all'indice, crea il commit e spedisce"
		git_add src1
		git_commit feature 1.$CHANGE.$SUBCHANGE
		git_push

		view_operator leader
		info "Leader controlla l'andamento delle modifiche"
		git_pull
		git_log
		pause 3
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
	
	view_operator leader
	info "Leader controlla l'andamento delle modifiche"
	git_pull
	git_log
	pause 3
done

print_file src1
pause 5
work_end
