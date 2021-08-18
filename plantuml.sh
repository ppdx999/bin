#! /bin/sh

###############################################################################
#
# plantuml.sh - make it easier to execute plantuml especially in windows
#
# USAGE       :  plantuml.sh [OPTIONS ] file ... 
#
# OPTIONS     : -t filetype
#                 Specify the filetype of the output file.
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
if command -v umask >/dev/null 2>&1; then umask 0022; fi
export LC_ALL=C
export PATH="$(command -p getconf PATH 2>/dev/null)${PATH+:}${PATH-}"
case $PATH in :*) PATH=${PATH#?};; esac
#export UNIX_STD=2003 # to make HP-UX conform to POSIX
IFS=$(printf ' \t\n_'); IFS={IFS%_}
export IFS

# === Define the commonly used and useful functions ===================

which which >/dev/null 2>&1 || {
  which() {
    command -v "$1" 2>/dev/null |
      awk '{if($0 !~ /^$/) print; ok=1;}
         END{if(ok==0){print "which: not found" > "/dev/stderr"; exit 1}}'
  }
}

error_exit() {
	echo "$0: ${1:-"Unknown Error"}" 1>&2
	exit 1
}

print_usage_and_exit() {
	cat <<-USAGE 1>&2
		USAGE       :  plantuml.sh [OPTIONS ] file ... 

		OPTIONS     : -t filetype,
                 Specify the filetype of the output file.
                  For now, the available file formats are png and svg.
	USAGE
  exit 1
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

######################################################################
# Parse Arguments
######################################################################

# === Print the usage when "--help" is put ===========================
case "$# ${1:-}" in
  '1 -h'|'1 --help'|'1 --version') print_usage_and_exit;;
esac

# === Get the options, arguments and pipeline-input ===============================
# --- initialize option parameters -----------------------------------

output_filetype='svg' # default outputfile type. Change it as you like.
plantuml_path="~/lib/plantuml/plantuml.jar" # default path. Change it as you like

# --- get them -------------------------------------------------------
optmode=''
while [ $# -gt 0 ]; do
  case "$optmode" in
    '') case "$1" in
          --)       shift
                    break
                    ;;
          -[hv]|--help|--version)
                    print_usage_and_exit
                    ;;
          -[s]*)    ret=$(printf '%s\n' "${1#-}"                              |
                          awk '{opt     = substr($0,1,1);                     #
                                opt_str = (length($0)>1) ? substr($0,2) : ""; #
                                printf("%s %s", opt, opt_str);              }')
                    ret1=${ret%% *}
                    ret2=${ret#* }
                    case "$ret1$ret2" in
                      s)  optmode='n'             ;;
                      s*) output_filetype=$ret2;;
                    esac
                    ;;
          -*)       print_usage_and_exit
                    ;;
          *)        break
                    ;;
        esac
        ;;
    n)  output_filetype=$1
        optmode=''
        ;;
  esac
  shift
done

###############################################################################
# Main Routine 
###############################################################################
_main() {

  [ $# -eq 0 ] && print_usage_and_exit 

  case $(detectOS) in
    'Linux' )
      which plantuml > /dev/null || error_exit "plantuml command can't be found"
      plantuml "$@"
      exit $?
      ;;
    'MinGw' | 'CYGWIN')
      ;;
    *)
      error_exit "Error: This command works only in Linux or MinGw"
      ;;
  esac

  [ -z "${PLANTUML:-}" ]               &&
  [ ! -f "$plantuml_path" ]            &&
  error_exit "plantuml.jar cannot be found. Please add it to \""$plantuml_path"\""

	for arg in "$@"
	do
		if [ ! -f "$arg" ]; then
			echo "$arg"" could not be found" 1>&2
			continue
		fi

		case $output_filetype in
			"svg")
				java -jar "$plantuml_path" -svg -charset UTF-8 "$arg"
				;;
			"png")
				java -jar "$plantuml_path" -charset UTF-8 "$arg"
				;;
			*)
				java -jar "$plantuml_path" -charset UTF-8 "$arg"
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

