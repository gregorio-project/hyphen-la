# Latin hyphenation tests for non-liturgical hyphenation styles

This directory contains some lists of hyphenated words according to two
different Latin hyphenation styles: classical and medieval/modern (i. e.
Italian). All word lists result from splitting and adapting
[wordlist-liturgical.txt](../wordlist-liturgical.txt) in the [tests](../)
directory. The lists have not yet been proofread systematically, so they might
contain some erroneous hyphenations.

### wordlist-classical-only.txt

Hyphenations suitable only for classical Latin; these are mainly hyphenations
splitting *sc*, *sp*, or *st*, e.g. *hos-pes*, *cas-tra*, *dis-co*,
*ta-bes-cet*, *sus-ci-pe*, *dig-nus*, *ves-ti-gia*.

### wordlist-italian-only.txt

Hyphenations suitable only for “Italian style” medieval and modern Latin; these
are mainly hyphenations not splitting *gn*, *sc*, *sp*, or *st*, e. g.
*ho-spes*, *ca-stra*, *di-sco*, *ta-be-scet*, *su-sci-pe*, *di-gnus*,
*ve-sti-gia*.

### wordlist-classical-italian.txt

Hyphenations suitable for both hyphenation styles, e. g. *uni-cus*, *au-dio*,
*in-imi-cus*, *crea-re*, *cor-po-reus*, *an-nus*, *sanc-tus*, *ab-sto*.

### check-wordlists.lua

This script sorts all word lists mentioned above and checks
- if there are any duplicates for any of the two hyphenation variants in the
  word lists or in `wordlist-liturgical.txt`,
- if the same words are taken into account for all three hyphenation variants
  (classical, modern, and liturgical),
- if there are missing or additional words compared to
  `wordlist-liturgical.txt`.

Furthermore, the scripts writes `candidates-*` files in case of missing
hyphenations from `wordlist-liturgical.txt` prepared for the different
hyphenation variants.

#### Usage
	lua5.3 check-wordlists.lua
