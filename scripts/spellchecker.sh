#!/usr/bin/env bash

# MIT License
#
# Copyright (c) 2019 manilarome
# Copyright (c) 2020 Tom Meyers
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# This script tries to find typo's in the repository
# You must call the script from the root of the repository

set -o pipefail

_success="0"
_failed="0"
_total="0"

# make sure we have the dependencies
function check() {

  if [[ ! "$(command -v npm)" ]]; then
    echo "NPM is not installed, installing it now using tos -S npm"
    tos -S npm || exit 1
  fi

  if [[ ! "$(command -v spellchecker)" ]]; then
    echo "We use the spellchecker command to validate spelling"
    echo "Installing it now using npm"
    sudo npm install --global spellchecker-cli || exit 1
  fi
}

function print_status() {
  local width
  width=$(tput cols)
  width=$((width - 2))

  local _success_count=$((_success * width / _total))
  local _failed_count=$((_failed * width / _total))
  # we substract 4 for the [  ] chars
  local _rest_count=$((width - _failed_count - _success_count - 4))

  # green color
  printf "\r[\e[0;32m"
  if [[ "$_success_count" -gt 0 ]]; then
    printf "=%.0s" "$(seq "$_success_count")"
  else
    printf " "
  fi
  # red color
  printf "\e[0;31m"
  if [[ "$_failed_count" -gt 0 ]]; then
    printf "=%.0s" "$(seq "$_failed_count")"
  else
    printf " "
  fi
  printf "\e[0m"
  printf " %.0s" "$(seq "$_rest_count")"
  printf "]"
}

function lint_lua_file() {
  cp "$1" /tmp/lint.lua
  awk '{if( $0 ~ /.*--.*/){print $0}else{print ""}}' /tmp/lint.lua | sed 's/.*--//g' >/tmp/lint.md

  if spellchecker -d spellchecker.dict --files /tmp/lint.md | sed 's;/tmp/lint.md;'"$1"';g'; then
    _success="$((_success + 1))"
  else
    _failed="$((_failed + 1))"
  fi

  print_status

  rm /tmp/lint.lua /tmp/lint.md
}

function lint_lua_comments() {
  # TODO: replace with a native lua spellchecker
  shopt -s globstar
  # first we compute the total
  for i in **/*.lua; do # Whitespace-safe and recursive
    if [[ "$i" != "tde/lib-tde/lib-lua"* && "$i" != "tde/lib-tde/sentry/"* && "$i" != "tests/luaunit.lua" ]]; then
      _total="$((_total + 1))"
    fi
  done

  # now we do the linting
  for i in **/*.lua; do # Whitespace-safe and recursive
    if [[ "$i" != *"lib-tde/lib-lua"* && "$i" != "tde/lib-tde/sentry/"* && "$i" != "tests/luaunit.lua" ]]; then
      lint_lua_file "$i"
    fi
  done
}

function lint() {
  markdown=('README.md' 'SECURITY.md' '**/*.md')

  # shellcheck disable=SC2068
  spellchecker -d spellchecker.dict --files "${markdown[@]}"

  lint_lua_comments
}

check
lint
