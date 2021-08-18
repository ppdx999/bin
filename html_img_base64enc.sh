#! /bin/sh

###############################################################################
#
# html_img_base64enc.sh - base64 encode images in html
#
# USAGE       :  html_img_base64enc.sh file ... 
# DESCRIPTION :  base64 encode images in html like jpg, png and svg.
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
      Usage       :  html_img_base64enc.sh file ... 
      Description :  base64 encode images in html like jpg, png and svg.
USAGE
  exit 1
}

# === Print the usage when "--help" is put ===========================
[ $# -eq 0 ] && print_usage_and_exit
case "$# ${1:-}" in
  '1 -h'|'1 --help'|'1 --version') print_usage_and_exit;;
esac

###############################################################################
# Main Routine 
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

    # --- base64 encode png --------------------------------------------------
    cat "$file"                                                              |
      grep '<img\s\s*src="[^:]*\.png"'                                       |
      sed 's/^.*<img\s\s*src="\(.*png\)".*/\1/g'                             |
      while read -r line                                                     
      do                                                                     
        base64text=$(cat "$line"                                             |
                     base64                                                  |
                     sed 's/\//\\\//g'                                       |
                     sed 's/ //g'                                            |
                     sed -z 's/\n//g')                                       
        sed -i '0,/<img\s\s*src="[^:]*\.png"/ s/<img\s\s*src="[^:]*\.png"/<img src="data:image\/png;base64,'"$base64text"'"/' "$file"
      done 

    # --- base64 encode svg --------------------------------------------------
    cat "$file"                                                              |
    grep '<img\s\s*src="[^:]*\.svg"'                                         |
    sed 's/^.*<img\s\s*src="\(.*\.svg\)".*/\1/g'                             |
    while read -r line                                                       
    do                                                                       
        base64text=$(cat "$line"                                             |
                   base64                                                    |
                   sed 's/\//\\\//g'                                         |
                   sed 's/ //g'                                              |
                   sed -z 's/\n//g')
      sed -i '0,/<img\s\s*src="[^:]*\.svg"/ s/<img\s\s*src="[^:]*\.svg"/<img src="data:image\/svg+xml;base64,'"$base64text"'"/' "$file"
    done

    # --- base64 encode jpg --------------------------------------------------
    cat "$file"                                                              |
    grep '<img\s\s*src="[^:]*\.jpg"'                                         |
    sed 's/^.*<img\s\s*src="\(.*\.jpg\)".*/\1/g'                             |
    while read -r line                                                       
    do                                                                       
        base64text=$(cat "$line"                                             |
                   base64                                                    |
                   sed 's/\//\\\//g'                                         |
                   sed 's/ //g'                                              |
                   sed -z 's/\n//g')
      sed -i '0,/<img\s\s*src="[^:]*\.jpg"/ s/<img\s\s*src="[^:]*\.jpg"/<img src="data:image\/jpg+xml;base64,'"$base64text"'"/' "$file"
    done

done

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
