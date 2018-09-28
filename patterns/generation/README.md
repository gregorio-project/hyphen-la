# Generation of Latin hyphenation patterns

The patterns for liturgical Latin `hyph.la.liturgical.txt` have been written by
hand. They are improved continously.

The patterns for classical Latin `hyph.la.classical.txt` and the Italian style
patterns for medieval and modern Latin `hyph.la.phonetic.txt` have also been
written by hand, but have been unmaintained for several years.

Because of some deficiencies of the existing patterns, we are going to create
improved patterns for classical Latin. The following workflow is planned:

1. Create a list of about 1000 Latin words without inflected forms and without
hyphenations, but containing information about the inflection class and hyphens
in compound words. In this list, "j", "v", "æ" and "œ" should be used
consequently (this is important for step 3). The list could contain for example
"laudo,1" (first conjugation) and "ab-scindo,3,ab-scidi,ab-scissum" (third
conjugation with perfect and supine), "jam" (no inflected forms).

2. Run a script on this list, which creates all possible inflected forms, for
example "laudo, laudas, laudat, ..., laudabo, ..., laudavi, ..., laudatus,
laudata, laudatum, ...".

3. Run the script `divisio.lua` on the output of 2 to hyphenate all the forms
according to the basic rules. This is easy as the input list uses "i" and "u"
only as vowels. This would yield "lau-do, lau-das, ...".

4. Create orthographic variants: "vi-vo"->"ui-uo", "jam"->"iam",
"cæ-lum"->"cae-lum". It is crucial to do this after the hyphenation. Again,
this can be done by a script.

5. Handle special cases like homographs.

6. Create patterns using patgen.

7. Check the patterns using proofreading files. Every error can be corrected by
putting the erroneously hyphenated word in the input list.

## Scripts

### `divisio.lua`

This script hyphenates the words in the input list according to the basic
hyphenation rules for classical Latin. It is intended to prepare a `patgen`
input.

#### Usage:
	lua5.3 divisio.lua [options] [< inputfile] [> outputfile]

The input file has to contain a list of words separated by line breaks. If no
input file is given, standard input (terminal) is used for input; the input is
terminated by `CTRL+D`.

The input may contain the following characters:
- the 26 lowercase and the 26 uppercase letters of the Latin alphabet
- vowels with macrons: `Ā` (U+100), `ā` (U+101), `Ē` (U+112), `ē` (U+113), `Ī`
  (U+12A), `ī` (U+12B), `Ō` (U+14C), `ō` (U+14D), `Ū` (U+16A), `ū` (U+16B), `Ȳ`
  (U+232), `ȳ` (U+233)
- digraphs: `Æ` (U+C6), `æ` (U+E6), `Œ` (U+152), `œ` (U+153)
- hyphens if needed: `-`

Hyphenation points are marked by hyphens. Sometimes, the output may also
contain a middle dot `·` (U+B7), which marks a hyphenation point that is
illegal as long as digraphs are used, but becomes legal when the digraphs are
replaced by *ae* and *oe*: `æ·di-fi-ca-re`, `ob-œ·di-re`, `su·æ`.

#### Possible options:
- `--chant`: hyphenate even single vowel syllables as needed for chant; this
  will yield hyphenations like *o-ra-re*, *vo-lu-i*, *in-i-ti-um*; the
  `--suppress-hiatus` option is ignored
- `--suppress-hiatus`: never divide consecutive vowels; hyphenations like
  *me-us*, *su-us*, *volu-it* are suppressed
- `--trace-states`: debug option

#### Hyphenation rules used:
- Two vowels are separated: *me-is*, *vi-am*. *y* is considered as a vowel.
  *au* and *eu* are considered as diphthongs; thus they are not separated:
  *laus*, *heus*. An auxiliary hyphen is required to separate *au* or *eu*:
  `me-us`, `aure-us`.
- A single consonant between two vowels is taken to the next syllable:
  *la-tus*, *pu-rus*. An auxiliary hyphen is required if the consonant belongs
  to the preceding syllable because of the morphology of the word: `ab-ire`,
  `in-ire`, `anim-adverto`.
- The last of several consonants between two vowels is taken to the next
  syllable: *cres-cit*, *mag-nus*, *om-nis*, *ves-ter*, *unc-tio*. Muta cum
  liquida, *ch*, *ph*, *rh*, and *th* are not separated: *as-trum*,
  *so-bri-us*. An auxiliary hyphen may be required because of the morphology or
  the Greek origin of the word: `ab-luo`, `ab-stare`, `sce-ptrum`.
- *qu* is considered as a single consonant, as well as *gu* preceded by *n* and
  followed by a vowel: *se-que-re*, *san-guis*. An auxiliary hyphen is required
  if *u* is a vowel after *ng*: `langu-i`, `langu-erunt`.
- Single vowel syllables at the beginning or the end of a word are not
  separated: *odor*, *luo*. A single vowel syllable within a word is not
  separated from the preceding syllable: *spe-cio-sus*, *tue-ri*. An auxiliary
  hyphen may be required because of the morphology of the word: `in-itium`:
  *in-iti-um*. This rule is ignored when using the `--chant` option.
