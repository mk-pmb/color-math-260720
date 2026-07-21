#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function find_inverse_image_for_unary_function () {
  local F="$1"; shift
  local CRNT= PREV=
  if [ -n "$F" ]; then
    # printf -- '\x1B[7m%s\x1B[0m' "$F:"
    echo -n "$F:"
    while [ "$#" -ge 1 ]; do
      CRNT="$($F $1)"
      if [ "$CRNT" == "$PREV" ]; then
        printf -- '\t=\v%s' "$1"
      else
        printf -- '\t%s\v%s' "$CRNT" "$1"
        PREV="$CRNT"
      fi
      shift
    done | LANG=C sed -rf <(echo '
      s~\t=\v~,~g
      # s~\t(\S+)\v~\t\x1B[7m\1\x1B[0m <- {~g
      s~\t(\S+)\v~\t\1◀{~g
      s~\t|$~}  ~g
      s~^\}~~
      ')
    echo
    return 0
  fi
}










[ "$1" != --lib ] || return 0; "$@"; exit $?
