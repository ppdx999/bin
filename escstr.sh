#! /bin/sh

###############################################################################
#
# escstr.sh - escape for unicage type of data
#
# USAGE       :  escstr.sh [FILE]... 
# ARGS        :  FILE
#                 escape target file
# DESCRIPTION :
#           escape below chars 
#              | char  | ASCII code | from |  to |  
#              ----------------------------------
#              | \     |   0x5C     | \    | \\  |  
#              | SPACE |  0xAO      |      |  _  |  
#              | TAB   |   0x99     | \t	  | \\t	|  
#              | LF    |   0x0A     | \n   | \\n |  
#              | CR    |   0x0D     | \r   | \\r |  
#              | BEL   |   0x07     | \a   | \\a |  
#              | BS    |   0x08     | \b   | \\b |  
#              | FF    |   0x0C     | \f   | \\f |  
#              | VT    |   0x0B     | \v   | \\v |  
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

# === Define the functions for printing usage and error message ======

print_usage_and_exit() {
  cat <<-USAGE_END 1>&2
  USAGE       :  ${0##*/} [FILE]... 
  ARGS        :  FILE
                  escape target file
  DESCRIPTION :
            escape below chars 
               | char  | ASCII code | from |  to |  
               ----------------------------------
               | \     |   0x5C     | \    | \\  |  
               | SPACE |  0xAO      |      |  _  |  
               | TAB   |   0x99     | \t   | \\t |  
               | LF    |   0x0A     | \n   | \\n |  
               | CR    |   0x0D     | \r   | \\r |  
               | BEL   |   0x07     | \a   | \\a |  
               | BS    |   0x08     | \b   | \\b |  
               | FF    |   0x0C     | \f   | \\f |  
               | VT    |   0x0B     | \v   | \\v |  
USAGE_END
exit 1
}

######################################################################
# Parse Arguments
######################################################################

# === Print the usage when "--help" is put ===========================
case "$# ${1:-}" in
  '1 -h'|'1 --help'|'1 --version') print_usage_and_exit;;
esac

###############################################################################
# Main Routine 
###############################################################################

  awkcode_main_escstr='
    BEGIN{
    s="";
    while(getline l){s=s l "\021";} # Join each line with dummy char \021
    s=substr(s,1,length(s)-1);
    gsub(/\\/ ,"\022",s); # Temporaliy change \ to \022
    gsub(/_/ ,"\\_" ,s);
    gsub(/ / ,"_" ,s);
    gsub(/\t/ ,"\\t" ,s);
    gsub(/\r/ ,"\\r" ,s);
    gsub(/\a/ ,"\\a" ,s);
    gsub(/\b/ ,"\\b" ,s);
    gsub(/\f/ ,"\\f" ,s);
    gsub(/\v/ ,"\\v" ,s);
    #
    gsub(/\022/,"\\\\",s); # Restore \ from \022
    gsub(/\021/,"\\n" ,s); # Restore \n from \021
    print s;
  }'


if [ -p /dev/stdin ]; then
  cat - | awk "$awkcode_main_escstr"
else
  cat "$@" | awk "$awkcode_main_escstr"
fi 
