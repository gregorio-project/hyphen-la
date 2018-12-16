#!/bin/bash

# sort the word list and remove duplicates
sort -u -o index_verborum index_verborum

# generate inflected forms and store them
lua5.3 flexura.lua < index_verborum | sort -u > index_formarum

# hyphenate forms and generate orthographic variants
lua5.3 divisio.lua --suppress-hiatus < index_formarum | \
lua5.3 variatio.lua | \
sort > patgen_input_classical
