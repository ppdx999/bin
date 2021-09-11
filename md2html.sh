#! /bin/sh

###############################################################################
#
# md2html.sh - Convert markdown to html. need `pandoc`
#
# USAGE       :  md2hmlt.sh FILE 
# DESCRIPTION :  convert markdown to html. Open the converted file in a browser 
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

# === Define the functions for printing usage and error message ======

error_exit() {
  echo "$0: ${1:-"Unknown Error"}" 1>&2
  exit 1
}

print_usage_and_exit() {
  cat <<-USAGE_END 1>&2
  Usage       : ${0##*/} FILE
  DESCRIPTION :  convert markdown to html. Open the converted file in a browser 
USAGE_END
exit 1
}

# === Check requirement  =============================================

which which >/dev/null 2>&1 || {
  which() {
    command -v "$1" 2>/dev/null |
      awk '{if($0 !~ /^$/) print; ok=1;}
         END{if(ok==0){print "which: not found" > "/dev/stderr"; exit 1}}'
  }
}


# === Define the commonly used and useful functions ===================

detectOS() {
  case "$(uname -s)" in
    Linux*)     echo Linux;;
    Darwin*)    echo Mac;;
    CYGWIN*)    echo Cygwin;;
    MINGW*)     echo MinGw;;
    MSYS*)      echo MSYS;;
    *)          echo "UNKNOWN:$(uname -s)"
  esac
}

make_tempfile() {
  (
  dir=${TMPDIR:-}
  [ -d "${TMPDIR:-}" ] || dir='/tmp'
  dir=${dir%/}

  while : ; do
    now=$(date +'%Y%m%d%H%M%S') || return $?
    file="$now-$$"
    set -C
    case "$(uname -s)" in Linux* ) umask 0077 ;; esac
    : > "$dir/$file" 2>/dev/null
    case $? in 0) printf "%s" "$dir/$file"; break;; esac
    file=''
  done
  )
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

case $# in 0) print_usage_and_exit;; esac

{
cat << EOF
<!DOCTYPE html>
<html lang="en">
<head>
     <meta charset="UTF-8">
EOF
echo "    <title>$1</title>"
cat << EOF
<style>     
html {
  font-size: 100%;
  overflow-y: scroll;
  -webkit-text-size-adjust: 100%;
  -ms-text-size-adjust: 100%;
}

body {
  color: #444;
  font-family: Georgia, Palatino, 'Palatino Linotype', Times, 'Times New Roman', serif;
  font-size: 12px;
  line-height: 1.5em;
  padding: 1em;
  margin: auto;
  max-width: 42em;
  background: #fefefe;
}

a {
  color: #0645ad;
  text-decoration: none;
}

a:visited {
  color: #0b0080;
}

a:hover {
  color: #06e;
}

a:active {
  color: #faa700;
}

a:focus {
  outline: thin dotted;
}

a:hover,
a:active {
  outline: 0;
}

::-moz-selection {
  background: rgba(255, 255, 0, 0.3);
  color: #000;
}

::selection {
  background: rgba(255, 255, 0, 0.3);
  color: #000;
}

a::-moz-selection {
  background: rgba(255, 255, 0, 0.3);
  color: #0645ad;
}

a::selection {
  background: rgba(255, 255, 0, 0.3);
  color: #0645ad;
}

p {
  margin: 1em 0;
}

img {
  max-width: 100%;
}

h1,
h2,
h3,
h4,
h5,
h6 {
  font-weight: normal;
  color: #111;
  line-height: 1em;
}

h4,
h5,
h6 {
  font-weight: bold;
}

h1 {
  font-size: 2.5em;
}

h2 {
  font-size: 2em;
}

h3 {
  font-size: 1.5em;
}

h4 {
  font-size: 1.2em;
}

h5 {
  font-size: 1em;
}

h6 {
  font-size: 0.9em;
}

blockquote {
  color: #666666;
  margin: 0;
  padding-left: 3em;
  border-left: 0.5em #eee solid;
}

hr {
  display: block;
  border: 0;
  border-top: 1px solid #aaa;
  border-bottom: 1px solid #eee;
  margin: 1em 0;
  padding: 0;
}

pre,
code,
kbd,
samp {
  color: #000;
  font-family: monospace, monospace;
  _font-family: 'courier new', monospace;
  font-size: 0.98em;
}

pre {
  white-space: pre;
  white-space: pre-wrap;
  word-wrap: break-word;
}

b,
strong {
  font-weight: bold;
}

dfn {
  font-style: italic;
}

ins {
  background: #ff9;
  color: #000;
  text-decoration: none;
}

mark {
  background: #ff0;
  color: #000;
  font-style: italic;
  font-weight: bold;
}

sub,
sup {
  font-size: 75%;
  line-height: 0;
  position: relative;
  vertical-align: baseline;
}

sup {
  top: -0.5em;
}

sub {
  bottom: -0.25em;
}

ul,
ol {
  margin: 1em 0;
  padding: 0 0 0 2em;
}

li p:last-child {
  margin: 0;
}

dd {
  margin: 0 0 0 2em;
}

img {
  border: 0;
  -ms-interpolation-mode: bicubic;
  vertical-align: middle;
}

table {
  border-collapse: collapse;
  border-spacing: 0;
}

td {
  vertical-align: top;
}

@media only screen and (min-width: 480px) {
  body {
    font-size: 14px;
  }
}

@media only screen and (min-width: 768px) {
  body {
    font-size: 16px;
  }
}

@media print {
  * {
    background: transparent !important;
    color: black !important;
    filter: none !important;
    -ms-filter: none !important;
  }

  body {
    font-size: 12pt;
    max-width: 100%;
  }

  a,
  a:visited {
    text-decoration: underline;
  }

  hr {
    height: 1px;
    border: 0;
    border-bottom: 1px solid black;
  }

  a[href]:after {
    content: " (" attr(href) ")";
  }

  abbr[title]:after {
    content: " (" attr(title) ")";
  }

  .ir a:after,
  a[href^="javascript:"]:after,
  a[href^="#"]:after {
    content: "";
  }

  pre,
  blockquote {
    border: 1px solid #999;
    padding-right: 1em;
    page-break-inside: avoid;
  }

  tr,
  img {
    page-break-inside: avoid;
  }

  img {
    max-width: 100% !important;
  }

  @page :left {
    margin: 15mm 20mm 15mm 10mm;
  }

  @page :right {
    margin: 15mm 10mm 15mm 20mm;
  }

  p,
  h2,
  h3 {
    orphans: 3;
    widows: 3;
  }

  h2,
  h3 {
    page-break-after: avoid;
  }
}
</style>
</head>
<body>
EOF

pandoc -f markdown -t html "$1"

cat <<-EOF
</body>
</html>
EOF
} > "${1%.*}.html"

case "$(detectOS)" in
  'Linux' ) 
      if [ -n "${BROWSER:=}" ]; then
        "$BROWSER" "${1%.*}.html"
      elif which xdg-open > /dev/null; then
        xdg-open "${1%.*}.html"
      elif which gnome-open > /dev/null; then
        gnome-open "${1%.*}.html"
      else
        error_exit "Could not detect the web browser to use."
      fi
    ;;
  'MinGw' | 'Sygwin' | 'MSYS' )
    start "${1%.*}.html"
    ;;
  'Mac' )
    open "${1%.*}.html"
    ;;
esac

sleep 2
