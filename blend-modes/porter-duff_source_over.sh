#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
#
# Porter-Duff is the intuitive opacity blend-mode.
# It's thus also the default for CSS/SVG.


function porter_duff_source_over_rgba255 () {
  local DEST_R="${1:-0}"; shift
  local DEST_G="${1:-0}"; shift
  local DEST_B="${1:-0}"; shift
  local DEST_A="${1:-0}"; shift
  local SRC_{R,G,B,A}= KEEP=
  while [ "$#" -ge 4 ]; do
    SRC_R="${1:-0}"; shift
    SRC_G="${1:-0}"; shift
    SRC_B="${1:-0}"; shift
    SRC_A="${1:-0}"; shift
    [ "$SRC_A" -ge 1 ] || continue
    ((
      KEEP = 255 - SRC_A ,
      DEST_R = ( ( ( DEST_R * KEEP ) + ( SRC_R * SRC_A ) + 127 ) / 255 ) ,
      DEST_G = ( ( ( DEST_G * KEEP ) + ( SRC_G * SRC_A ) + 127 ) / 255 ) ,
      DEST_B = ( ( ( DEST_B * KEEP ) + ( SRC_B * SRC_A ) + 127 ) / 255 ) ,
      DEST_A = ( ( ( DEST_A * KEEP ) + (   255 * SRC_A ) + 127 ) / 255 ) ,
      1
    ))
  done
  echo "$DEST_R $DEST_G $DEST_B $DEST_A"
}


function porter_duff_source_over_rgba255__test () {
  local F="${FUNCNAME%__*}"
  local BLK='  0   0   0 255' # black
  local SKY=' 64 128 255 255' # skyblue
  local WHT='255 255 255 255' # white
  local FOG='128 128 128  64' # grey, 1/4 opacity
  local ARA=' 32   0  64 128' # arachnid-view tint
  local OUT=( $(
    $F $BLK
    $F $SKY
    $F $FOG
    $F $WHT $ARA
    $F $BLK $FOG        # 32  32  32  255 255 255 #
    $F $SKY $FOG        # 80  128 223 255 255 255 #
    $F $FOG $FOG        # 128 128 128 112 112 112 #
    $F $WHT $ARA $ARA
    $F $BLK $FOG $FOG   # 56  56  56  255 255 255 #
    $F $SKY $FOG $FOG   # 92  128 199 255 255 255 #
    $F $FOG $FOG $FOG   # 128 128 128 148 148 148 #
    $F $WHT $ARA $ARA $ARA
    ) )
  local COLS=$(( 2 * 4 ))
  local N_OUT="${#OUT[@]}"
  local SAVE="tmp.$FUNCNAME.ppm"
  ( printf -- '%s\n' P3 "$COLS $(( N_OUT / 2 / COLS ))" 255
    printf -- '%- 3u %- 3u %- 3u % 3u\n' ${OUT[@]} |
      sed -re 's!.{4}$!&&&!' # alpha -> grey
  ) | tee -- "$SAVE"
  : >(exec display -interpolate nearest -filter point -resize 5000% -- "$SAVE")
  sleep 0.2s
}








[ "$#" == 0 ] && porter_duff_source_over_rgba255__test ||
  porter_duff_source_over_rgba255 "$@"; exit $?
