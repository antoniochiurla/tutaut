#!/usr/bin/env bash
. ../tutaut.sh

speed_up
FIXED_SPEED=1 . 03-dev2-add-feature.sh

for CHANGE in {1..1}; do
	slow_down
	for SUBCHANGE in {1..3}; do
		operator dev1
		info "Dev1 aggiorna la copia locale"
		git_pull_noff
		vi_save_and_close
		info "Dev1 esegue la modifica $CHANGE.$SUBCHANGE"
		vi_open src1
		vi_search feature1
		vi_find_char 1
		vi_change_line_from_cursor 1.$CHANGE.$SUBCHANGE
		pause
		vi_save_and_close
		info "aggiunge all'indice e crea il commit"
		git_add src1
		git_commit feature 1 change $CHANGE.$SUBCHANGE
		#vi_save_and_close
		info "spedisce le modifiche"
		git_push
		pause
		operator leader
		info "Leader aggiorna la copia locale"
		git_pull
		pause
		info "Leader esegue la modifica $CHANGE.$SUBCHANGE.x"
		vi_open src1
		vi_search feature1
		vi_append_to_line .x
		pause
		vi_save_and_close
		info "aggiunge all'indice e crea il commit"
		git_add src1
		git_commit feature 1 change $CHANGE.$SUBCHANGE.x
		#vi_save_and_close
		info "spedisce le modifiche"
		git_push
		pause
		operator dev2
		#info "Dev2 aggiorna la copia locale"
		#git_pull
		#pause
		#vi_save_and_close
		info "Dev2 esegue la modifica $CHANGE.$SUBCHANGE"
		vi_open src1
		vi_search feature2
		vi_find_char 2
		vi_change_line_from_cursor 2.$CHANGE.$SUBCHANGE
		vi_save_and_close
		info "aggiunge all'indice e crea il commit"
		git_add src1
		git_commit feature 2 change $CHANGE.$SUBCHANGE
	done

	operator dev2
	info "Dev2 aggiorna la copia locale prima di spedire le modifiche"
	git_pull
	vi_save_and_close
	info "Dev2 spedisce le modifiche"
	git_push
done

info "Leader controlla la lista delle modifiche"
operator leader
git_pull
git_log
print_file src1
pause 5
work_end
