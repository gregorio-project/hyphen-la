# Latin hyphenation tests

This directory gathers some interesting tests for an hyphenation algorithm.

## Word lists

The file [listwords.txt](listwords.txt) is a list of words come from multiple sources listing difficult hyphenations.

The files `wordlist-x-y.txt` are lists of hyphenated words reviewed by Claudio Beccari, Solesmes Abbey and Flavigny Abbey. According to current usage in Catholic Church books, only words of more than two syllables carry the accent in the dedicated files.

The file [orberg.txt](orberg.txt) contains a list of etymological hyphenation points given in Hans Ørberg's method. It does not mark all hyphenation points though.

## Automatic testing

The script `test.py` can automatically test the patterns in the `patterns` folder against the list of words in this folder. It uses [pyphen](http://pyphen.org/) to do so. Note that `pyphen` requires the patterns in the `libhyphen` format, so you must build them before running the tests.
