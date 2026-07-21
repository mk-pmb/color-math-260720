#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function verify_edge_cases () {
  source -- ../test/lib_test_util.sh --lib
  local F='find_inverse_image_for_unary_function '
  $F closest_6x6_rgb_cube_value {-7..0} {33..40} {233..236} 270
  $F closest_grey_ramp_value -16 {-8..-5} {11..14} {250..255}
}


function closest_6x6_rgb_cube_value () {
  local ORIG="$1" STEP=40 FIRST=95
  local HALF_STEP=$(( STEP / 2 ))
  N_STEPS=$(( ( ORIG - FIRST + HALF_STEP ) / STEP ))
  CLOSEST=$(( N_STEPS * STEP + FIRST ))
  echo $CLOSEST
}


function closest_grey_ramp_value () {
  local ORIG="$1" STEP=10 FIRST=8
  local HALF_STEP=$(( STEP / 2 ))
  N_STEPS=$(( ( ORIG - FIRST + HALF_STEP ) / STEP ))
  # We start at the first of n=24 greys, so we can take at most n-1=23 steps.
  [ "$N_STEPS" -le 23 ] || N_STEPS=23
  CLOSEST=$(( N_STEPS * STEP + FIRST ))
  echo $CLOSEST
}


function grey_ramp_value_table () {
  local G=
  for (( G=0; G<256; G++ )); do
    # echo -n "$G:$(closest_grey_ramp_value $G)"$'\t'
    closest_grey_ramp_value $G
  done | uniq -c
}










"$@"; exit $?
