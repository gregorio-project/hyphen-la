# Latin hyphenation tests

This directory gathers some tests for a hyphenation algorithm.

## Word lists

The file [listwords.txt](listwords.txt) is a list of words coming from multiple sources listing difficult hyphenations.

The file [orberg.txt](orberg.txt) contains a list of etymological hyphenation points given in Hans Ørberg’s method ([*Lingua Latina* Pars I, 2003, ISBN 8799701650, Index Vocabulorum, p. 313 sqq.](https://books.google.fr/books?id=YyVfH9p9cCIC&printsec=frontcover&hl=fr&source=gbs_ge_summary_r&cad=0#v=onepage&q&f=false)). It does not mark all hyphenation points though.

### wordlist-liturgical.txt

A list of words hyphenated according to the liturgical hyphenation style
reviewed by Claudio Beccari, Solesmes Abbey, and Flavigny Abbey.

### wordlist-liturgical-accents.txt

A list of of accented words (without hyphenations). According to current usage
in Catholic Church books, only words of more than two syllables carry an
accent.

### wordlist-classical.txt

Hyphenations suitable only for classical Latin; these are mainly hyphenations
splitting *gn*, *sc*, *sp*, or *st*, e.g. *hos-pes*, *cas-tra*, *dis-co*,
*ta-bes-cet*, *sus-ci-pe*, *dig-nus*, *ves-ti-gia*.

### wordlist-italian.txt

Hyphenations suitable only for “Italian style” medieval and modern Latin; these
are mainly hyphenations not splitting *gn*, *sc*, *sp*, or *st*, e. g.
*ho-spes*, *ca-stra*, *di-sco*, *ta-be-scet*, *su-sci-pe*, *di-gnus*,
*ve-sti-gia*.

### wordlist-classical-italian.txt

Hyphenations suitable for the classical and the Italian hyphenation style,
e. g.  *uni-cus*, *au-dio*, *in-imi-cus*, *crea-re*, *cor-po-reus*, *an-nus*,
*sanc-tus*, *ab-sto*.

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

## Automatic testing

The script `test.py` in the `scripts` folder can automatically test the patterns in the `patterns` folder against the list of words in this folder. See the scripts [Readme.md](../scripts/README.md).
