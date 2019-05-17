#!/bin/bash

# use the exit code of the last program to exit non-zero within a pipe
set -o pipefail

if [ "$1" = "--ec" ]
then
   outputFile=patgen_input_classical_ec
else
   outputFile=patgen_input_classical
fi

# delete existing patgen input
rm -f $outputFile

# sort the word list and remove duplicates
if sort -u -o index_verborum index_verborum
then
   # generate inflected forms and store them
   if lua5.3 flexura.lua --enclitics < index_verborum | sort -u > index_formarum
   then
      # hyphenate forms and generate orthographic variants
      lua5.3 divisio.lua --suppress-hiatus < index_formarum | \
      lua5.3 variatio.lua $1 | \
      # "LC_ALL=C" is necessary for a defined order of the "combining double
      # inverted breve" (tie, U+361) and the "combining double macron" (U+35E).
      LC_ALL=C sort | \
      # Another run of sort without "LC_ALL=C" is required for a more natural
      # order.
      sort > $outputFile
   else
      exit
   fi
else
   exit
fi
