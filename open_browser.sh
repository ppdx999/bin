#! /bin/sh

###############################################################################
#
# open_browser - make it easier to open the browser from the console 
#
# USAGE       :  open_browser file ... 
# 
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

error_exit() {
	echo "$0: ${1:-"Unknown Error"}" 1>&2
	exit 1
}

print_usage_and_exit() {
  cat <<-USAGE 1>&2
		USAGE        :  open_browser file ... 
		Description  :  make it easier to open the browser from the console 
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

cmd_exist() {
	if command -v "$1" &> /dev/null; then
		return 0
	else
		return 1
	fi
}


###############################################################################
# Main Routine 
###############################################################################

_main(){

  # === Print the usage when "--help" is put or no arugument passed ===========
  [ $# -eq 0 ] && print_usage_and_exit
  case "$# ${1:-}" in
    '1 -h'|'1 --help'|'1 --version') print_usage_and_exit;;
  esac

	for arg in "$@"
	do
		if [ ! -f "$arg" ]; then
			echo "$arg"" could not be found" 1&>2
			continue
		fi

		dir=$(dirname "$arg")
		file=$(basename "$arg")

		cd "$dir"
    case "$(detectOS)" in
      'Linux' ) 
          if [ -n "${BROWSER:=}" ]; then
            "$BROWSER" "$PWD"/"$file"
          elif which xdg-open > /dev/null; then
            xdg-open "$PWD"/"$file"
          elif which gnome-open > /dev/null; then
            gnome-open "$PWD"/"$file"
          else
            error_exit "Could not detect the web browser to use."
          fi
        ;;
      'MinGw' )
        start "$PWD"/"$file"
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
