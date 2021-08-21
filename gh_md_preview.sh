#! /bin/sh

###############################################################################
#
# gh_md_preview.sh - Make it easy to preview README.md in github
#
# USAGE       :  gh_md_preview.sh FILE 
# DESCRIPTION :  convert markdown to html with github like css and
#                open the converted file in a browser 
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
  DESCRIPTION :  convert markdown to html with github like css and
                 open the converted file in a browser 
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

tmp=$(make_tempfile).html

{
cat << EOF
<!DOCTYPE html>
<html lang="en">
<head>
     <meta charset="UTF-8">
     <title></title>
<style>     
body .octicon {
  display: inline-block;
  fill: currentColor;
  vertical-align: text-bottom;
}

body .anchor {
  float: left;
  line-height: 1;
  margin-left: -20px;
  padding-right: 4px;
}

body .anchor:focus {
  outline: none;
}

body h1 .octicon-link,
body h2 .octicon-link,
body h3 .octicon-link,
body h4 .octicon-link,
body h5 .octicon-link,
body h6 .octicon-link {
  color: #1b1f23;
  vertical-align: middle;
  visibility: hidden;
}

body h1:hover .anchor,
body h2:hover .anchor,
body h3:hover .anchor,
body h4:hover .anchor,
body h5:hover .anchor,
body h6:hover .anchor {
  text-decoration: none;
}

body h1:hover .anchor .octicon-link,
body h2:hover .anchor .octicon-link,
body h3:hover .anchor .octicon-link,
body h4:hover .anchor .octicon-link,
body h5:hover .anchor .octicon-link,
body h6:hover .anchor .octicon-link {
  visibility: visible;
}

body h1:hover .anchor .octicon-link:before,
body h2:hover .anchor .octicon-link:before,
body h3:hover .anchor .octicon-link:before,
body h4:hover .anchor .octicon-link:before,
body h5:hover .anchor .octicon-link:before,
body h6:hover .anchor .octicon-link:before {
  width: 16px;
  height: 16px;
  content: ' ';
  display: inline-block;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16' version='1.1' width='16' height='16' aria-hidden='true'%3E%3Cpath fill-rule='evenodd' d='M4 9h1v1H4c-1.5 0-3-1.69-3-3.5S2.55 3 4 3h4c1.45 0 3 1.69 3 3.5 0 1.41-.91 2.72-2 3.25V8.59c.58-.45 1-1.27 1-2.09C10 5.22 8.98 4 8 4H4c-.98 0-2 1.22-2 2.5S3 9 4 9zm9-3h-1v1h1c1 0 2 1.22 2 2.5S13.98 12 13 12H9c-.98 0-2-1.22-2-2.5 0-.83.42-1.64 1-2.09V6.25c-1.09.53-2 1.84-2 3.25C6 11.31 7.55 13 9 13h4c1.45 0 3-1.69 3-3.5S14.5 6 13 6z'%3E%3C/path%3E%3C/svg%3E");
}body {
  -ms-text-size-adjust: 100%;
  -webkit-text-size-adjust: 100%;
  line-height: 1.5;
  color: #24292e;
  font-family: -apple-system,BlinkMacSystemFont,Segoe UI,Helvetica,Arial,sans-serif,Apple Color Emoji,Segoe UI Emoji;
  font-size: 16px;
  line-height: 1.5;
  word-wrap: break-word;
}

body details {
  display: block;
}

body summary {
  display: list-item;
}

body a {
  background-color: initial;
}

body a:active,
body a:hover {
  outline-width: 0;
}

body strong {
  font-weight: inherit;
  font-weight: bolder;
}

body h1 {
  font-size: 2em;
  margin: .67em 0;
}

body img {
  border-style: none;
}

body code,
body kbd,
body pre {
  font-family: monospace,monospace;
  font-size: 1em;
}

body hr {
  box-sizing: initial;
  height: 0;
  overflow: visible;
}

body input {
  font: inherit;
  margin: 0;
}

body input {
  overflow: visible;
}

body [type=checkbox] {
  box-sizing: border-box;
  padding: 0;
}

body * {
  box-sizing: border-box;
}

body input {
  font-family: inherit;
  font-size: inherit;
  line-height: inherit;
}

body a {
  color: #0366d6;
  text-decoration: none;
}

body a:hover {
  text-decoration: underline;
}

body strong {
  font-weight: 600;
}

body hr {
  height: 0;
  margin: 15px 0;
  overflow: hidden;
  background: transparent;
  border: 0;
  border-bottom: 1px solid #dfe2e5;
}

body hr:after,
body hr:before {
  display: table;
  content: "";
}

body hr:after {
  clear: both;
}

body table {
  border-spacing: 0;
  border-collapse: collapse;
}

body td,
body th {
  padding: 0;
}

body details summary {
  cursor: pointer;
}

body kbd {
  display: inline-block;
  padding: 3px 5px;
  font: 11px SFMono-Regular,Consolas,Liberation Mono,Menlo,monospace;
  line-height: 10px;
  color: #444d56;
  vertical-align: middle;
  background-color: #fafbfc;
  border: 1px solid #d1d5da;
  border-radius: 3px;
  box-shadow: inset 0 -1px 0 #d1d5da;
}

body h1,
body h2,
body h3,
body h4,
body h5,
body h6 {
  margin-top: 0;
  margin-bottom: 0;
}

body h1 {
  font-size: 32px;
}

body h1,
body h2 {
  font-weight: 600;
}

body h2 {
  font-size: 24px;
}

body h3 {
  font-size: 20px;
}

body h3,
body h4 {
  font-weight: 600;
}

body h4 {
  font-size: 16px;
}

body h5 {
  font-size: 14px;
}

body h5,
body h6 {
  font-weight: 600;
}

body h6 {
  font-size: 12px;
}

body p {
  margin-top: 0;
  margin-bottom: 10px;
}

body blockquote {
  margin: 0;
}

body ol,
body ul {
  padding-left: 0;
  margin-top: 0;
  margin-bottom: 0;
}

body ol ol,
body ul ol {
  list-style-type: lower-roman;
}

body ol ol ol,
body ol ul ol,
body ul ol ol,
body ul ul ol {
  list-style-type: lower-alpha;
}

body dd {
  margin-left: 0;
}

body code,
body pre {
  font-family: SFMono-Regular,Consolas,Liberation Mono,Menlo,monospace;
  font-size: 12px;
}

body pre {
  margin-top: 0;
  margin-bottom: 0;
}

body input::-webkit-inner-spin-button,
body input::-webkit-outer-spin-button {
  margin: 0;
  -webkit-appearance: none;
  appearance: none;
}

body :checked+.radio-label {
  position: relative;
  z-index: 1;
  border-color: #0366d6;
}

body .border {
  border: 1px solid #e1e4e8!important;
}

body .border-0 {
  border: 0!important;
}

body .border-bottom {
  border-bottom: 1px solid #e1e4e8!important;
}

body .rounded-1 {
  border-radius: 3px!important;
}

body .bg-white {
  background-color: #fff!important;
}

body .bg-gray-light {
  background-color: #fafbfc!important;
}

body .text-gray-light {
  color: #6a737d!important;
}

body .mb-0 {
  margin-bottom: 0!important;
}

body .my-2 {
  margin-top: 8px!important;
  margin-bottom: 8px!important;
}

body .pl-0 {
  padding-left: 0!important;
}

body .py-0 {
  padding-top: 0!important;
  padding-bottom: 0!important;
}

body .pl-1 {
  padding-left: 4px!important;
}

body .pl-2 {
  padding-left: 8px!important;
}

body .py-2 {
  padding-top: 8px!important;
  padding-bottom: 8px!important;
}

body .pl-3,
body .px-3 {
  padding-left: 16px!important;
}

body .px-3 {
  padding-right: 16px!important;
}

body .pl-4 {
  padding-left: 24px!important;
}

body .pl-5 {
  padding-left: 32px!important;
}

body .pl-6 {
  padding-left: 40px!important;
}

body .f6 {
  font-size: 12px!important;
}

body .lh-condensed {
  line-height: 1.25!important;
}

body .text-bold {
  font-weight: 600!important;
}

body .pl-c {
  color: #6a737d;
}

body .pl-c1,
body .pl-s .pl-v {
  color: #005cc5;
}

body .pl-e,
body .pl-en {
  color: #6f42c1;
}

body .pl-s .pl-s1,
body .pl-smi {
  color: #24292e;
}

body .pl-ent {
  color: #22863a;
}

body .pl-k {
  color: #d73a49;
}

body .pl-pds,
body .pl-s,
body .pl-s .pl-pse .pl-s1,
body .pl-sr,
body .pl-sr .pl-cce,
body .pl-sr .pl-sra,
body .pl-sr .pl-sre {
  color: #032f62;
}

body .pl-smw,
body .pl-v {
  color: #e36209;
}

body .pl-bu {
  color: #b31d28;
}

body .pl-ii {
  color: #fafbfc;
  background-color: #b31d28;
}

body .pl-c2 {
  color: #fafbfc;
  background-color: #d73a49;
}

body .pl-c2:before {
  content: "^M";
}

body .pl-sr .pl-cce {
  font-weight: 700;
  color: #22863a;
}

body .pl-ml {
  color: #735c0f;
}

body .pl-mh,
body .pl-mh .pl-en,
body .pl-ms {
  font-weight: 700;
  color: #005cc5;
}

body .pl-mi {
  font-style: italic;
  color: #24292e;
}

body .pl-mb {
  font-weight: 700;
  color: #24292e;
}

body .pl-md {
  color: #b31d28;
  background-color: #ffeef0;
}

body .pl-mi1 {
  color: #22863a;
  background-color: #f0fff4;
}

body .pl-mc {
  color: #e36209;
  background-color: #ffebda;
}

body .pl-mi2 {
  color: #f6f8fa;
  background-color: #005cc5;
}

body .pl-mdr {
  font-weight: 700;
  color: #6f42c1;
}

body .pl-ba {
  color: #586069;
}

body .pl-sg {
  color: #959da5;
}

body .pl-corl {
  text-decoration: underline;
  color: #032f62;
}

body .mb-0 {
  margin-bottom: 0!important;
}

body .my-2 {
  margin-bottom: 8px!important;
}

body .my-2 {
  margin-top: 8px!important;
}

body .pl-0 {
  padding-left: 0!important;
}

body .py-0 {
  padding-top: 0!important;
  padding-bottom: 0!important;
}

body .pl-1 {
  padding-left: 4px!important;
}

body .pl-2 {
  padding-left: 8px!important;
}

body .py-2 {
  padding-top: 8px!important;
  padding-bottom: 8px!important;
}

body .pl-3 {
  padding-left: 16px!important;
}

body .pl-4 {
  padding-left: 24px!important;
}

body .pl-5 {
  padding-left: 32px!important;
}

body .pl-6 {
  padding-left: 40px!important;
}

body .pl-7 {
  padding-left: 48px!important;
}

body .pl-8 {
  padding-left: 64px!important;
}

body .pl-9 {
  padding-left: 80px!important;
}

body .pl-10 {
  padding-left: 96px!important;
}

body .pl-11 {
  padding-left: 112px!important;
}

body .pl-12 {
  padding-left: 128px!important;
}

body hr {
  border-bottom-color: #eee;
}

body kbd {
  display: inline-block;
  padding: 3px 5px;
  font: 11px SFMono-Regular,Consolas,Liberation Mono,Menlo,monospace;
  line-height: 10px;
  color: #444d56;
  vertical-align: middle;
  background-color: #fafbfc;
  border: 1px solid #d1d5da;
  border-radius: 3px;
  box-shadow: inset 0 -1px 0 #d1d5da;
}

body:after,
body:before {
  display: table;
  content: "";
}

body:after {
  clear: both;
}

body>:first-child {
  margin-top: 0!important;
}

body>:last-child {
  margin-bottom: 0!important;
}

body a:not([href]) {
  color: inherit;
  text-decoration: none;
}

body blockquote,
body details,
body dl,
body ol,
body p,
body pre,
body table,
body ul {
  margin-top: 0;
  margin-bottom: 16px;
}

body hr {
  height: .25em;
  padding: 0;
  margin: 24px 0;
  background-color: #e1e4e8;
  border: 0;
}

body blockquote {
  padding: 0 1em;
  color: #6a737d;
  border-left: .25em solid #dfe2e5;
}

body blockquote>:first-child {
  margin-top: 0;
}

body blockquote>:last-child {
  margin-bottom: 0;
}

body h1,
body h2,
body h3,
body h4,
body h5,
body h6 {
  margin-top: 24px;
  margin-bottom: 16px;
  font-weight: 600;
  line-height: 1.25;
}

body h1 {
  font-size: 2em;
}

body h1,
body h2 {
  padding-bottom: .3em;
  border-bottom: 1px solid #eaecef;
}

body h2 {
  font-size: 1.5em;
}

body h3 {
  font-size: 1.25em;
}

body h4 {
  font-size: 1em;
}

body h5 {
  font-size: .875em;
}

body h6 {
  font-size: .85em;
  color: #6a737d;
}

body ol,
body ul {
  padding-left: 2em;
}

body ol ol,
body ol ul,
body ul ol,
body ul ul {
  margin-top: 0;
  margin-bottom: 0;
}

body li {
  word-wrap: break-all;
}

body li>p {
  margin-top: 16px;
}

body li+li {
  margin-top: .25em;
}

body dl {
  padding: 0;
}

body dl dt {
  padding: 0;
  margin-top: 16px;
  font-size: 1em;
  font-style: italic;
  font-weight: 600;
}

body dl dd {
  padding: 0 16px;
  margin-bottom: 16px;
}

body table {
  display: block;
  width: 100%;
  overflow: auto;
}

body table th {
  font-weight: 600;
}

body table td,
body table th {
  padding: 6px 13px;
  border: 1px solid #dfe2e5;
}

body table tr {
  background-color: #fff;
  border-top: 1px solid #c6cbd1;
}

body table tr:nth-child(2n) {
  background-color: #f6f8fa;
}

body img {
  max-width: 100%;
  box-sizing: initial;
  background-color: #fff;
}

body img[align=right] {
  padding-left: 20px;
}

body img[align=left] {
  padding-right: 20px;
}

body code {
  padding: .2em .4em;
  margin: 0;
  font-size: 85%;
  background-color: rgba(27,31,35,.05);
  border-radius: 3px;
}

body pre {
  word-wrap: normal;
}

body pre>code {
  padding: 0;
  margin: 0;
  font-size: 100%;
  word-break: normal;
  white-space: pre;
  background: transparent;
  border: 0;
}

body .highlight {
  margin-bottom: 16px;
}

body .highlight pre {
  margin-bottom: 0;
  word-break: normal;
}

body .highlight pre,
body pre {
  padding: 16px;
  overflow: auto;
  font-size: 85%;
  line-height: 1.45;
  background-color: #f6f8fa;
  border-radius: 3px;
}

body pre code {
  display: inline;
  max-width: auto;
  padding: 0;
  margin: 0;
  overflow: visible;
  line-height: inherit;
  word-wrap: normal;
  background-color: initial;
  border: 0;
}

body .commit-tease-sha {
  display: inline-block;
  font-family: SFMono-Regular,Consolas,Liberation Mono,Menlo,monospace;
  font-size: 90%;
  color: #444d56;
}

body .full-commit .btn-outline:not(:disabled):hover {
  color: #005cc5;
  border-color: #005cc5;
}

body .blob-wrapper {
  overflow-x: auto;
  overflow-y: hidden;
}

body .blob-wrapper-embedded {
  max-height: 240px;
  overflow-y: auto;
}

body .blob-num {
  width: 1%;
  min-width: 50px;
  padding-right: 10px;
  padding-left: 10px;
  font-family: SFMono-Regular,Consolas,Liberation Mono,Menlo,monospace;
  font-size: 12px;
  line-height: 20px;
  color: rgba(27,31,35,.3);
  text-align: right;
  white-space: nowrap;
  vertical-align: top;
  cursor: pointer;
  -webkit-user-select: none;
  -moz-user-select: none;
  -ms-user-select: none;
  user-select: none;
}

body .blob-num:hover {
  color: rgba(27,31,35,.6);
}

body .blob-num:before {
  content: attr(data-line-number);
}

body .blob-code {
  position: relative;
  padding-right: 10px;
  padding-left: 10px;
  line-height: 20px;
  vertical-align: top;
}

body .blob-code-inner {
  overflow: visible;
  font-family: SFMono-Regular,Consolas,Liberation Mono,Menlo,monospace;
  font-size: 12px;
  color: #24292e;
  word-wrap: normal;
  white-space: pre;
}

body .pl-token.active,
body .pl-token:hover {
  cursor: pointer;
  background: #ffea7f;
}

body .tab-size[data-tab-size="1"] {
  -moz-tab-size: 1;
  tab-size: 1;
}

body .tab-size[data-tab-size="2"] {
  -moz-tab-size: 2;
  tab-size: 2;
}

body .tab-size[data-tab-size="3"] {
  -moz-tab-size: 3;
  tab-size: 3;
}

body .tab-size[data-tab-size="4"] {
  -moz-tab-size: 4;
  tab-size: 4;
}

body .tab-size[data-tab-size="5"] {
  -moz-tab-size: 5;
  tab-size: 5;
}

body .tab-size[data-tab-size="6"] {
  -moz-tab-size: 6;
  tab-size: 6;
}

body .tab-size[data-tab-size="7"] {
  -moz-tab-size: 7;
  tab-size: 7;
}

body .tab-size[data-tab-size="8"] {
  -moz-tab-size: 8;
  tab-size: 8;
}

body .tab-size[data-tab-size="9"] {
  -moz-tab-size: 9;
  tab-size: 9;
}

body .tab-size[data-tab-size="10"] {
  -moz-tab-size: 10;
  tab-size: 10;
}

body .tab-size[data-tab-size="11"] {
  -moz-tab-size: 11;
  tab-size: 11;
}

body .tab-size[data-tab-size="12"] {
  -moz-tab-size: 12;
  tab-size: 12;
}

body .task-list-item {
  list-style-type: none;
}

body .task-list-item+.task-list-item {
  margin-top: 3px;
}

body .task-list-item input {
  margin: 0 .2em .25em -1.6em;
  vertical-align: middle;
}
</style>
</head>
<body>
EOF

pandoc -f markdown -t html $1

cat <<-EOF
</body>
</html>
EOF
} > $tmp


case "$(detectOS)" in
  'Linux' ) 
      if [ -n "${BROWSER:=}" ]; then
        "$BROWSER" "$tmp"
      elif which xdg-open > /dev/null; then
        xdg-open "$tmp"
      elif which gnome-open > /dev/null; then
        gnome-open "$tmp"
      else
        error_exit "Could not detect the web browser to use."
      fi
    ;;
  'MinGw' | 'Sygwin' )
    start "$tmp"
    ;;
esac

sleep 2

rm "$tmp"
