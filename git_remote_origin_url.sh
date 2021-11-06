#! /bin/sh

###############################################################################
#
# NAME - DESCRIPTION
#
# USAGE       :  name.sh [options] [hoge] 
# ARGS        :
# OPTIONS     :
# DESCRIPTION :
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
unset -f unalias
\unalias -a
unset -f command
if command -v umask >/dev/null 2>&1; then umask 0022; fi
export LC_ALL=C
export PATH="$(command -p getconf PATH 2>/dev/null)${PATH+:}${PATH-}"
case $PATH in :*) PATH=${PATH#?};; esac
#export UNIX_STD=2003 # to make HP-UX conform to POSIX
IFS=$(printf ' \t\n_'); IFS={IFS%_}
export IFS

# === Define the functions for printing usage and error message ======

error_exit() {
  echo "$0: ${1:-"Unknown Error"}" 1>&2
  exit 1
}

print_usage_and_exit() {
  cat <<-USAGE_END 1>&2
  Usage       : ${0##*/} [options] [XML_file]
  Description :
  Requirement :
USAGE_END
exit 1
}

which which >/dev/null 2>&1 || {
  which() {
    command -v "$1" 2>/dev/null |
      awk '{if($0 !~ /^$/) print; ok=1;}
         END{if(ok==0){print "which: not found" > "/dev/stderr"; exit 1}}'
  }
}

###############################################################################
# Main Routine 
###############################################################################

case "$(git config --global user.name)" in "") git config --global user.name "ppdx999" ;; esac
case "$(git config --global user.email)" in "") git config --global user.email "ppdx999@gmail.com" ;; esac
git config --global core.editor vim

rep_name=$(pwd | xargs basename)
case "$(git config remote.origin.url)" in
  https:* )
    git remote set-url origin "git@github.com:$(git config user.name)/$rep_name.git"
    ;;
  *) ;;
esac

