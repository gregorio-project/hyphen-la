#!/bin/bash

PATGEN=patgen

if [ "$1" = "--ec" -o "$2" = "--ec" ]
then
   inputFile=patgen_input_classical_ec
   translateFile=patgen_translate_classical_ec
   outputFile=patterns_classical_ec
   logFile=patgen_classical_ec.log
else
   inputFile=patgen_input_classical
   translateFile=patgen_translate_classical
   outputFile=patterns_classical
   logFile=patgen_classical.log
fi

parameterFile=patterns_classical_parameters

# delete log file
rm -f $logFile

# patgen parameters for seven runs
hyph_start_finish[1]='1 1'
hyph_start_finish[2]='2 2'
hyph_start_finish[3]='3 3'
hyph_start_finish[4]='4 4'
hyph_start_finish[5]='5 5'
hyph_start_finish[6]='6 6'
hyph_start_finish[7]='7 7'

pat_start_finish[1]='1 3'
pat_start_finish[2]='2 4'
pat_start_finish[3]='3 5'
pat_start_finish[4]='4 6'
pat_start_finish[5]='5 11'
pat_start_finish[6]='6 11'
pat_start_finish[7]='7 11'

good_bad_thres[1]='1 2 1'
good_bad_thres[2]='1 5 1'
good_bad_thres[3]='1 6 1'
good_bad_thres[4]='1 7 1'
good_bad_thres[5]='1 7 1'
good_bad_thres[6]='1 8 1'
good_bad_thres[7]='1 9 1'

# generate input from "index_verborum"
if [ "$1" = "--ec" -o "$2" = "--ec" ]
then
   ./generate-patgen-input.sh --ec
else
   ./generate-patgen-input.sh
fi

if [ $? -eq 0 ]
then
   if [ "$1" = "-i" -o "$2" = "-i" ]
   then
      lua5.3 generate-initial-patterns.lua > initial_patterns
      cp initial_patterns $outputFile.3
   else
      # create empty pattern file for first run
      touch $outputFile.0
   fi

   # remove file with patgen parameters and old patterns files
   rm -f $parameterFile
   rm -f $outputFile.1
   rm -f $outputFile.2

   for i in 1 2 3 4 5 6 7; do
      # delete "pattmp" file
      rm -f pattmp.$i

      if [ $i -gt 3 -o \( "$1" != "-i" -a "$2" != "-i" \) ]
      then
         # create patterns of level i
         printf "%s\n%s\n%s\n%s" "${hyph_start_finish[$i]}" "${pat_start_finish[$i]}" "${good_bad_thres[$i]}" "y" \
         | $PATGEN $inputFile $outputFile.$(($i-1)) $outputFile.$i $translateFile \
         | tee -a $logFile
         printf "%%   %s | %s | %s\n" "${hyph_start_finish[$i]}" "${pat_start_finish[$i]}" "${good_bad_thres[$i]}" \
         >> $parameterFile
      fi
   done

   # delete empty pattern file
   rm -f $outputFile.0
else
   exit
fi
