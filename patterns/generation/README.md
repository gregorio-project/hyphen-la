# Generation of Latin hyphenation patterns

The patterns for liturgical Latin `hyph.la.liturgical.txt` have been written by
hand. They are improved continuously.

The patterns for classical Latin `hyph.la.classical.txt` and the Italian style
patterns for medieval and modern Latin `hyph.la.phonetic.txt` have also been
written by hand, but have been unmaintained for several years.

Because of some deficiencies of the existing patterns, we are going to create
improved patterns for classical Latin. The following workflow is planned:

1. Create a list of about 1000 Latin words without inflected forms and without
hyphenations, but containing information about the inflection class and hyphens
in compound words. In this list, *j*, *v*, *æ* and *œ* should be used
consequently (this is important for step 3). The list could contain for example
`laudo,1` (first conjugation) and `ab-scindo,3,ab-scidi,ab-scissum` (third
conjugation with perfect and supine), `jam` (no inflected forms).

2. Run a script on this list, which creates all possible inflected forms, for
example *laudo, laudas, laudat, ..., laudabo, ..., laudavi, ..., laudatus,
laudata, laudatum, ...*.

3. Run the script `divisio.lua` on the output of 2 to hyphenate all the forms
according to the basic rules. This is easy as the input list uses *i* and *u*
only as vowels. This would yield *lau-do, lau-das, ...*.

4. Create orthographic variants: *vi-vo* → *ui-uo*, *jam* → *iam*,
*cæ-lum* → *cae-lum*. It is crucial to do this after the hyphenation. Again,
this can be done by a script.

5. Handle special cases like homographs.

6. Create patterns using patgen.

7. Check the patterns using proofreading files. Every error can be corrected by
putting the erroneously hyphenated word in the input list.

## Scripts

### `divisio.lua`

This script hyphenates the words in the input list according to the basic
hyphenation rules for classical Latin. It is intended to help to prepare a
*patgen* input.

#### Usage:
	lua5.3 divisio.lua [options] [< inputfile] [> outputfile]

The input file has to contain a list of words separated by line breaks. If no
input file is given, the standard input (terminal) is used for input; the input
is terminated by `CTRL+D`.

The input may contain the following characters:
- the 26 lowercase and the 26 uppercase letters of the Latin alphabet
- vowels with macrons: `Ā` (U+100), `ā` (U+101), `Ē` (U+112), `ē` (U+113), `Ī`
  (U+12A), `ī` (U+12B), `Ō` (U+14C), `ō` (U+14D), `Ū` (U+16A), `ū` (U+16B), `Ȳ`
  (U+232), `ȳ` (U+233)
- digraphs: `Æ` (U+C6), `æ` (U+E6), `Œ` (U+152), `œ` (U+153)
- auxiliary symbols as described below: `-`, `|`, and `^`

Hyphenation points are marked by hyphens in the output. Sometimes, the output
may also contain a middle dot `·` (U+B7), which marks a hyphenation point that
is illegal as long as digraphs are used, but becomes legal when the digraphs
are replaced by *ae* and *oe*: `æ·di-fi-cā-re` (*ædi-fi-cā-re* or *ae-di-fi-cā-re*), `ob-œ·dī-re` (*ob-œdī-re* or *ob-oe-dī-re*), `su·æ` (*suæ* or *su-ae*).

#### Possible options:
- `--chant` – hyphenate even single vowel syllables as needed for chant:
  `ōrāre` → `ō-rā-re`, `voluī` → `vo-lu-ī`, `in-itium` → `in-i-ti-um`, `tuērī`
  → `tu-ē-rī`; the `--suppress-hiatus` option is ignored.
- `--greek` – use Greek hyphenation for Greek words; hyphenation points that
  are not in accordance with the Latin rules have to be marked with `^` in the
  input: `sce^ptrum` → `sce-ptrum`, `rhy^thmus` → `rhy-thmus`; the `^`
  character is ignored if this option is not used
- `--suppress-hiatus` – never divide consecutive vowels within a word: `suus` →
  `suus`, `voluit` → `vo-luit`, `me|us` → `meus`; but `dē-esse` → `dē-es-se`
- `--trace-states`: debug option

#### Hyphenation rules used:
- Two vowels are separated: `meīs` → `me-īs`, `viam` → `vi-am`. *y* is
  considered as a vowel. *au* and *eu* are considered as diphthongs; thus they
  are not separated: `laus` → `laus`, `claustra` → `claus-tra`, `heus` →
  `heus`. A vertical bar (U+7C) is required to separate *au* or *eu*: `me|us` →
  `me-us`, `aure|us` → `au-re-us`.
- A single consonant between two vowels is taken to the next syllable: `domus`
  → `do-mus`, `lā-tus` → `lā-tus`. An auxiliary hyphen is required if the
  consonant belongs to the preceding syllable because of the morphology of the
  word: `in-icere` → `in-ice-re`, `sub-īre` → `sub-īre`, `anim-advertō` →
  `anim-ad-ver-tō`.
- The last of several consonants between two vowels is taken to the next
  syllable: `crēscit` → `crēs-cit`, `māgnus` → `māg-nus`, `omnis` → `om-nis`,
  `ves-ter` → `ves-ter`, `ūnctiō` → `ūnc-tiō`. Stop consonants followed by
  liquid consonants (*muta cum liquida*), *ch*, *ph*, *rh*, and *th* are not
  separated: `astrum` → `as-trum`, `sōbrius` → `sō-bri-us`. An auxiliary hyphen
  may be required because of the morphology of the word: `ab-luere` →
  `ab-lue-re`, `ab-stāre` → `ab-stā-re`.
- *qu* is considered as a single consonant, as well as *gu* preceded by *n* and
  followed by a vowel: `sequī` → `se-quī`, `sanguis` → `san-guis`. A vertical
  bar (U+7C) is required if *u* is a vowel after *ng*: `langu|it` →
  `lan-gu-it`, `langu|ērunt` → `lan-gu-ērunt`.
- Single vowel syllables at the beginning or the end of a word are not
  separated: `odium` → `odi-um`, `luō` → `luō`. A single vowel syllable within
  a word is not separated from the preceding syllable: `speciōsus` →
  `spe-ciō-sus`, `tuērī` → `tuē-rī`. An auxiliary hyphen may be required
  because of the morphology of the word: `in-itium` → `in-iti-um`, `ob-œdīre` →
  `ob-œ·dī-re`. This rule is ignored when using the `--chant` option.
