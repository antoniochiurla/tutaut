#!/usr/bin/env bash
. ../tutaut.sh

BASE=/tmp/git-tutorial
rm -rf $BASE

#MAX_WAIT_CHAR=0
DEBUG=1

operator master
create_dir $BASE/public/project
change_dir $BASE/public/project
operator master2
create_dir $BASE/public/project
change_dir $BASE/public/project
operator master3
create_dir $BASE/public/project
change_dir $BASE/public/project
vi_open src1
vi_add_line Initial content first line
vi_add_line Initial content second line
vi_save_and_close
vi_open src1
vi_search second
vi_add_line feature1
vi_save_and_close
vi_open src1
vi_search feature1
vi_add_line feature2
vi_save_and_close
MAX_WAIT_CHAR=500
vi_open src1
vi_search feature1
vi_change_line feature1.1
vi_save_and_close
MAX_WAIT_CHAR=500
print_file src1
