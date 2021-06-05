#! /bin/bash
#
# @(#) hoge.sh ver.1.0.0 2008.04.24
#
# Usage:
#   $0 ...
# 
# Description:
#   Opne file in chrome browser. 
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
		if [ ! -f "$arg" ]; then
			echo "$arg"" could not be found" 1&>2
			continue
		fi

		dir=$(dirname "$arg")
		file=$(basename "$arg")

		if [ "$(expr substr $(uname -s) 1 10)" == 'MINGW64_NT' ]; then
			cd "$dir"
			start chrome "$PWD"/"$file"
		fi
	done

}

if [ -p /dev/stdin ]; then
		# Take the entire standard output as input
		#_main "$(cat -)"

		# Receive line-by-line input
		while read -r line
		do
				_main $line 
		done
else
		_main "$@"
fi 
