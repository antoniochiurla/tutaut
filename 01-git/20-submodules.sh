#!/usr/bin/env bash
. ../tutaut.sh

speed_up

BASE=/tmp/git-tutorial-${ID_USER}
rm -rf $BASE


if [ -n "$LEADER_GEOM" ]; then OPERATORS_GEOMETRY[leader]=$LEADER_GEOM; fi
if [ -n "$DEV1_GEOM" ]; then OPERATORS_GEOMETRY[dev1]=$DEV1_GEOM; fi
if [ -n "$DEV2_GEOM" ]; then OPERATORS_GEOMETRY[dev2]=$DEV2_GEOM; fi
if [ -n "$LEADER_SETUP_COMMAND" ]; then OPERATORS_SETUP_COMMAND[leader]=$LEADER_SETUP_COMMAND; fi
if [ -n "$DEV1_SETUP_COMMAND" ]; then OPERATORS_SETUP_COMMAND[dev1]=$DEV1_SETUP_COMMAND; fi
if [ -n "$DEV2_SETUP_COMMAND" ]; then OPERATORS_SETUP_COMMAND[dev2]=$DEV2_SETUP_COMMAND; fi

for OP in leader dev1 dev2
do
	view_operator $OP
	send_command 'alias vim="vim -n"'
	send_command 'BASE='$BASE
       	clear_screen
done


view_operator leader
info "Leader crea il repository centrale"
create_dir \$BASE/public/project
change_dir \$BASE/public/project
git_init
pause
info "Crea la sua copia locale clonando il repository centrale"
create_dir \$BASE/leader
change_dir \$BASE/leader
git_clone \$BASE/public/project
change_dir project
info "Imposta la sua identita'"
git_config user.name "leader"
git_config user.email "leader@tutaut"
create_dir \$BASE/public/library
change_dir \$BASE/public/library
git_init
change_dir \$BASE/leader
git_clone \$BASE/public/library
change_dir library
info "Imposta la sua identita'"
git_config user.name "leader"
git_config user.email "leader@tutaut"

#work_begin

speed_up
#slow_down
info "dev1 adds library source"
view_operator dev1
create_dir $BASE/dev1
change_dir $BASE/dev1
git_clone $BASE/public/library
change_dir library
git_config user.name "dev1"
git_config user.email "dev1@tutaut"
vi_open Library.java
vi_add_line 'package library;'
vi_add_line 'public class Library {'
vi_add_line 'public static String feature1() {'
vi_add_line 'return "Output from feature1";'
vi_add_line '}'
vi_add_line '}'
vi_save_and_close
vi_open .gitignore
vi_add_line Library.class
vi_save_and_close
git_add .gitignore Library.java
git_commit 'library first version'
info "dev1 pushes changes"
git_push

view_operator dev2
create_dir $BASE/dev2
change_dir $BASE/dev2
git_clone $BASE/public/project
change_dir project
git_config user.name "dev2"
git_config user.email "dev2@tutaut"
send_command git config --global protocol.file.allow always
send_command git submodule add $BASE/public/library
sedn_command git submodule init
vi_open .gitmodules
vi_search 'url ='
vi_add_line 'branch = main'
vi_save_and_close
vi_open Main.java
vi_add_line 'import library.Library;'
vi_add_line 'public class Main {'
vi_add_line 'public static void main(String[] argv) {'
vi_add_line 'System.out.println("Executing " + Library.feature1());'
vi_add_line '}'
vi_add_line '}'
vi_save_and_close
vi_open .gitignore
vi_add_line Main.class
vi_save_and_close
git_add .gitmodules .gitignore Main.java
vi_open compile.sh
vi_add_line 'javac library/Library.java Main.java'
vi_save_and_close
vi_open run.sh
vi_add_line 'java Main'
vi_save_and_close
send_command 'chmod +x compile.sh run.sh'
git_add compile.sh run.sh
send_command './compile.sh && ./run.sh'
git_commit 'main first version'
info "dev2 pushes changes"
git_push


info "dev1 adds feature2 to library"
view_operator dev1
send_command 'git checkout -b feature2'
vi_open Library.java
vi_search 'feature1'
vi_down
vi_down
vi_add_line 'public static String feature2() {'
vi_add_line 'return "Output from feature2";'
vi_add_line '}'
vi_save_and_close
git_add Library.java
git_commit 'added feature2'
send_command 'git push --set-upstream origin feature2'


view_operator dev2
git_pull
send_command 'git checkout -b feature2'
vi_open .gitmodules
vi_search 'branch = main'
vi_change_line_from_cursor 'branch = feature2'
vi_save_and_close
send_command 'git submodule update --remote'
git_status
vi_open Main.java
vi_search 'feature1'
vi_add_line 'System.out.println("Executing " + Library.feature2());'
vi_save_and_close
git_add .gitmodules Main.java
git_commit 'used feature2'
send_command 'git push --set-upstream origin feature2'
send_command './compile.sh && ./run.sh'
send_command 'git checkout main'
send_command 'git submodule update --remote'
send_command './compile.sh && ./run.sh'

work_end
