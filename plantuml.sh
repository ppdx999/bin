#! /bin/bash

###############################################################################
#
# plantuml.sh - make it easier to execute plantuml especially in windows
#
# USAGE       :  plantuml.sh [OPTIONS ] file ... 
#
# OPTIONS     : -s,
#                 Specify the format of the output file.
# 								For now, the available file formats are png and svg.
# 
# 
# Written by ppdx999 on 2020-08-14
# 
# 
# This is a public-domain software (CC0). It means that all of the
# people can use this for any purposes with no restrictions at all. 
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
# 
# For more information, please refer to <http://unlicense.org>
# 
###############################################################################



###############################################################################
# Initial configuration
###############################################################################

# === Initialize shell environment ===================================
set -eu
if command -v umask &> /dev/null; then umask 0022; fi
PATH='/bin:/usr/bin:$HOME/bin'
IFS=$(printf ' \t\n_'); IFS={IFS%_}
export IFS LC_ALL=C LANG=C PATH

# === Define the commonly used and useful functions ===================

error_exit() {
	echo "$0: ${1:-"Unknown Error"}" 1>&2
	exit 1
}

print_usage_and_exit() {
	cat <<-USAGE 1>&2
		USAGE       :  plantuml.sh [OPTIONS ] file ... 

		OPTIONS     : -s,
                 Specify the format of the output file.
                  For now, the available file formats are png and svg.
	USAGE
  exit 1
}

cmd_exist() {
	if command -v "$1" &> /dev/null; then
		return 0
	else
		return 1
	fi
}

detectOS() {
   case "$(uname -s)" in
   	Linux*)     echo Linux;;
   	Darwin*)    echo Mac;;
   	CYGWIN*)    echo Cygwin;;
   	MINGW*)     echo MinGw;;
   	*)          echo "UNKNOWN:$(uname -s)"
   esac
}
###############################################################################
# Main Routine 
###############################################################################
_main() {

  [ $# -eq 0 ] && print_usage_and_exit 

	if [ $(detectOS) == 'Linux' ]; then
		plantuml "$@"
		exit $?
	fi

	if [ $(detectOS) == 'MinGw' ]; then
		error_exit "Error: This command works only in Linux or MinGw"
	fi

	[ ! -f ~/lib/plantuml/plantuml.jar ] &&
		error_exit "plantuml.jar cannot be found. Please add it to \"~/lib/plantuml/plantuml.jar\""

	while getopts s:h OPT
	do
		case $OPT in
			s) target_type=$OPTARG ;;
			h) print_usage_and_exit ;;
			\?) print_usage_and_exit ;;
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

