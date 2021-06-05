#! /bin/bash
#
# @(#) hoge.sh ver.1.0.0 2008.04.24
#
# Usage:
#   $0 [-a] [-b] [-f filename] arg1 ...
# 
# Description:
#   hogehogehoge
# 
# Options:
#   -a    aaaaaaaaaa
#   -b    bbbbbbbbbb
#   -f    ffffffffff
#	
###############################################################################

_main(){

	for arg in "$@"
	do
		if [ -z "$arg" ]; then
			echo "$arg"" could not be found" 1>&2
			continue
		fi

		dir=$(dirname "$arg")
		file=$(basename "$arg")

		cd "$dir"

		cat "$file"| grep '<img\s\s*src="[^:]*\.png"' | sed 's/^.*<img\s\s*src="\(.*png\)".*/\1/g' | while read -r line
		do
			base64text=$(cat $line | base64 | sed 's/\//\\\//g' | sed 's/ //g' | sed -z 's/\n//g')
			sed -i '0,/<img\s\s*src="[^:]*\.png"/ s/<img\s\s*src="[^:]*\.png"/<img src="data:image\/png;base64,'$base64text'"/' "$file"
		done

		cat "$file"| grep '<img\s\s*src="[^:]*\.svg"' | sed 's/^.*<img\s\s*src="\(.*\.svg\)".*/\1/g' | while read -r line
		do
			base64text=$(cat $line | base64 | sed 's/\//\\\//g' | sed 's/ //g' | sed -z 's/\n//g')
			sed -i '0,/<img\s\s*src="[^:]*\.svg"/ s/<img\s\s*src="[^:]*\.svg"/<img src="data:image\/svg+xml;base64,'$base64text'"/' "$file"
		done
	done

}

arg_checks(){
	[ $# -eq 0 ] && [ ! -p /dev/stdin ] &&  error_exit "Arg Error: no argument passed" 
	#[ -d "$1" ] &&  error_exit "Error: ""$1"" doesn't exist or isn't directory" 
}

init(){
	:
	# Debug mode
	#		-v : Prints shell input lines as they are read
	#		-x : Print command traces before executing command
	#set -xv

	# Error Handling
	#		-e : when error happen, exit
	#		-o pipefail : even if error happen on the pipeline, exit
	#set -e -o pipefail

	#prevent_malcious_env_var
}

cmd_exist(){
	if command -v "$1" &> /dev/null; then
		return 0
	else
		return 1
	fi
}

prevent_malcious_env_var(){
	set -u # If undefined variable appear, stop and exit
	#umaks 0022
	PATH=/bin:/usr/bin:$HOME/bin
	IFS=$(printf ' \t\n_'); IFS={IFS%_}
	export IFS LC_ALL=C LANG=C PATH
}

error_exit(){
	echo "$0: ${1:-"Unknown Error"}" 1>&2
	exit 1
}

make_tempfile() {
	#--------------------------------------------------
	#Usage:
	#	make_tempfile [prefix] [suffix] [dir_path]
	#--------------------------------------------------
	(
	now=$(date +'%Y%m%d%H%M%S') || return $?
	file="${3:-${TMPDIR:-/tmp}}/${1:-}$now-$$${2:-}"
	if [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
		umask 0077
	fi
	set -C
	: > "$file" || return $?
	echo "$file"
	)
}

make_tempdir() {
	#--------------------------------------------------
	#Usage:
	#	make_tempdir [prefix] [suffix] [dir_path]
	#--------------------------------------------------
	(
	now=$(date +'%Y%m%d%H%M%S') || return $?
	file="${3:-${TMPDIR:-/tmp}}/${1:-}$now-$$${2:-}"
	if [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
		umask 0077
	fi
	mkdir "$file" || return $?
	echo "$file"
	)
}

if [ -p /dev/stdin ]; then
		# Take the entire standard output as input
		#_main "$(cat -)"

		# Receive line-by-line input
		while read line
		do
				_main $line
		done
else
		_main "$@"
fi 
