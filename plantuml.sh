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

	[ ! -f ~/lib/plantuml/plantuml.jar ] && error_exit "plantuml.jar cannot be found. Please add it to \"~/lib/plantuml/plantuml.jar\""

	while getopts s OPT
	do
		case $OPT in
			s) target_type="svg" ;;
			p) target_type="png" ;;
			\?) error_exit "Error: Unknown option"
		esac
	done
	shift $((OPTIND - 1))

	for arg in "$@"
	do
		if [ ! -f "$arg" ]; then
			echo "$arg"" could not be found" 1>&2
			continue
		fi
		
		case $target_type in
			"svg")
				java -jar ~/lib/plantuml/plantuml.jar -svg -charset UTF-8 "$arg"
				;;
			"png")
				java -jar ~/lib/plantuml/plantuml.jar -charset UTF-8 "$arg"
				;;
			*)
				java -jar ~/lib/plantuml/plantuml.jar -svg -charset UTF-8 "$arg"
				;;
		esac
	done

}

error_exit(){
	echo "$0: ${1:-"Unknown Error"}" 1>&2
	exit 1
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
