# Latin hyphenation tests for non-liturgical hyphenation styles

This directory contains some lists of hyphenated words according to different
Latin hyphenation styles. All word lists result from splitting and adapting
[wordlist-liturgical.txt](../wordlist-liturgical.txt) in the [tests](../)
directory. The categorization is not yet finished.

## wordlist-liturgical-only.txt

Hyphenations suitable only for liturgical Latin, i.e. hyphenations with single
vowel syllables and hiatus, e.g. *u-ni-cus*, *au-di-o*, *in-i-mi-cus*,
*cre-a-re*, *cor-po-re-us*; also accented forms like *tran-sé-re-re*.

## wordlist-liturgical-classical.txt

Hyphenations suitable for liturgical and classical Latin. These are mainly
hyphenations splitting *sc*, *sp*, or *st*, e.g. *hos-pes*, *cas-tra*,
*dis-co*.

## wordlist-liturgical-italian.txt

Hyphenations suitable for liturgical Latin and “Italian style” medieval and
modern Latin. These are mainly hyphenations not splitting *sc* before *e*, *i*,
*y*, *æ*, and *œ* or not splitting *gn*, e.g. *ta-be-scet*, *su-sci-pe*,
*di-gnus*.

## wordlist-classical-only.txt

Hyphenations suitable only for classical Latin, e.g. *ta-bes-cet*, *sus-ci-pe*,
*dig-nus*, *ves-ti-gia*.

## wordlist-classical-italian.txt

Hyphenations suitable for classical Latin and “Italian style” medieval and
modern Latin, e.g. *uni-cus*, *au-dio*, *in-imi-cus*, *crea-re*, *cor-po-reus*.

## wordlist-italian-only.txt

Hyphenations suitable only for “Italian style” medieval and modern Latin, e.g.
*ho-spes*, *ca-stra*, *di-sco*.

## wordlist-all-styles.txt

Hyphenations suitable for all three styles, e.g. *an-nus*, *sanc-tus*, *ab-sto*.

## check-wordlists.lua

The script sorts all word lists mentioned above and checks
- if there are any duplicates for one of the three hyphenation variants in the
  word lists or in `wordlist-liturgical.txt`,
- if the same words are taken into account for all three hyphenation variants,
- if there are missing or additional words compared to
  `wordlist-liturgical.txt`,
- if the hyphenations for the liturgical variants are identical to those of
  `wordlist-liturgical.txt`.
