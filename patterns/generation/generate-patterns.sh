#!/bin/bash

PATGEN=patgen

# generate input from "index_verborum"
./generate-patgen-input.sh

# patgen parameters for seven runs
hyph_start_finish[1]='1 1'
hyph_start_finish[2]='2 2'
hyph_start_finish[3]='3 3'
hyph_start_finish[4]='4 4'
hyph_start_finish[5]='5 5'
hyph_start_finish[6]='6 6'
# hyph_start_finish[7]='7 7'

pat_start_finish[1]='1 3'
pat_start_finish[2]='2 4'
pat_start_finish[3]='3 5'
pat_start_finish[4]='4 6'
pat_start_finish[5]='5 11'
pat_start_finish[6]='6 11'
# pat_start_finish[7]='7 11'

good_bad_thres[1]='1 1 1'
good_bad_thres[2]='1 2 1'
good_bad_thres[3]='1 1 1'
good_bad_thres[4]='1 3 1'
good_bad_thres[5]='1 1 1'
good_bad_thres[6]='1 4 1'
# good_bad_thres[7]='1 1 1'

# delete log file
rm -f patterns_classical.log

# create empty pattern file for first run
touch patterns_classical.0

for i in 1 2 3 4 5 6; do
  # create patterns of level i
  printf "%s\n%s\n%s\n%s" "${hyph_start_finish[$i]}" "${pat_start_finish[$i]}" "${good_bad_thres[$i]}" "y" \
  | $PATGEN patgen_input_classical patterns_classical.$(($i-1)) patterns_classical.$i patgen_translate_classical \
  | tee -a patterns_classical.log
done

# delete empty pattern file
rm patterns_classical.0
