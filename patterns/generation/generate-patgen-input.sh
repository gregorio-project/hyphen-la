#!/bin/bash

# sort the word list and remove duplicates
sort -u -o index_verborum index_verborum

# generate inflected forms and store them
lua5.3 flexura.lua < index_verborum | sort -u > index_formarum

# hyphenate forms and generate orthographic variants
lua5.3 divisio.lua --suppress-hiatus < index_formarum | \
lua5.3 variatio.lua | \
# The generation of orthographic variants leads to many duplicates, so we have
# to sort the output and remove the duplicates. "LC_ALL=C" is necessary for
# distinguishing the "combining double inverted breve" (U+361) and the
# "combining double macron" (U+35E).
LC_ALL=C sort -u | \
# Another run of sort without "LC_ALL=C" is required for a more natural order.
sort > patgen_input_classical
