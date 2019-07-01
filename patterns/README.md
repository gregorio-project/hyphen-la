# Latin hyphenation patterns

This directory contains three sets of Latin hyphenation patterns:

- `hyph.la.liturgical.txt` contains the patterns for hyphenation of liturgical
  Latin (used by recent Solesmes books)
- `hyph.la.classical.txt` contains the patterns for classical Latin considering
  etymology
- `hyph.la.modern.txt` contains the patterns for medieval and modern Latin
  considering the Italian pronunciation and Italian typographic rules

See [doc](../doc/) folder for more on the respective hyphenation rules used and how to choose between the three.


## Patterns elaboration

### Strings of characters

The patterns developed on this repository are hyphenation patterns given to the machine concerning a string of characters, in order to mark where a hyphenation is possible in a word, in agreement with the rules of meaning, phonetic and etymology. They are case insensitive.

A dot at the beginning of the pattern indicates that the string applies exclusively to the beginnings of words. A dot at the end of the pattern indicates that the string applies exclusively to the end of the words.

Each pattern described will always apply to words that contain it, unless another higher statement is present.

### Instructions

We give the instructions by numbers, from 0 to 9. 0 being the default value, it is not useful to write it.

Even numbers forbid hyphenation, more or less strongly depending on their value. While the odd numbers force the hyphenation, more or less strongly according to their value.

If the same string is subject to different instructions, the one with the highest number wins.
*E.g.*: `a3e` > `a2e` > `a1e`

### Pattern modification

Correcting the patterns when you notice an error requires to refer to all the patterns that concern the faulty word.

It is best to find the most words that are in accordance with a rule in order to establish a common pattern, and conversely, find all the words that have a string of characters related but which depend on a contrary rule. This will avoid over-multiplying the patterns.


## Format conversion

The patterns are in the patgen format used by TeX. You can download them in other forms on the [webpage](http://gregorio-project.github.io/hyphen-la/), but if you want to convert them yourself:

### libhyphen (LibreOffice, Adobe, etc.)

The patterns can be converted to [libhyphen](https://github.com/hunspell/hyphen) format (from the [Hunspell](https://hunspell.github.io/) sofware), in order to be usable in LibreOffice/OpenOffice, Mozilla products, Adobe products, etc. 

##### Converting to libhyphen format

Run `make` in the main directory to do the conversion. Note that you must have `perl` and `git` in order to do so.

### Javascript

The patterns can be converted to the format used by [Hyphenator](http://mnater.github.io/Hyphenator/) and [hypher](https://github.com/bramstein/hypher) by using the [conversion page from Hyphenator](http://mnater.github.io/Hyphenator/compressor.html), after replacing new lines by space in the pattern files.

## Licence

The patterns used to be under the [LPPL](https://latex-project.org/lppl/), but the author allows their distribution under [MIT](https://opensource.org/licenses/MIT) licence, which is what we do here.
