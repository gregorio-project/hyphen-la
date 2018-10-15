# Generation of Latin hyphenation patterns

The patterns for liturgical Latin `hyph.la.liturgical.txt` have been written by
hand. They are improved continuously.

The patterns for classical Latin `hyph.la.classical.txt` and the Italian style
patterns for medieval and modern Latin `hyph.la.phonetic.txt` have also been
written by hand, but have been unmaintained for several years.

Because of some deficiencies of the existing patterns, we are going to create
improved patterns for classical Latin. The new patterns shall support marks for
long and short vowels (macrons and breves, e.g. *lĭnguă Lătīnă*) as long and
short vowels are important for classical Latin. The following workflow is
planned:

1. Create a list of about 1000 Latin words without inflected forms and without
hyphenations, but containing information about the inflection class and hyphens
in compound words and with special orthographic conventions. Orthographic
variants can easily be created later. The exact format of the word list is
described below.

2. Run the script `flexura.lua` on this list, which creates all possible
inflected forms, for example *laudō, laudās, laudat, ..., laudābō, ...,
laudāvī, ..., laudātus, laudāta, laudātum, ...* from input `laudō`.

3. Run the script `divisio.lua` on the output of step 2 to hyphenate all the
forms according to the basic rules. This is easy as the input list uses *i* and
*u* only as vowels. This yields *lau-dō, lau-dās, ...*.

4. Create orthographic variants: `vī-vō` → *vī-vō, vī-vo, vi-vō, vi-vo, uī-uō,
uī-uo, ui-uō, ui-uo*; `jūs-tus` → *jūs-tus, jūs-tŭs, jus-tŭs, jus-tus, iūs-tus,
iūs-tŭs, ius-tŭs, ius-tus*; `cæ-lum` → *cæ-lum, cǣ-lum, cæ-lŭm, cǣ-lŭm,
cae-lum, cae-lŭm*. It is crucial to do this after the hyphenation. Again, this
can be done by a script.

5. Handle special cases like homographs.

6. Create patterns using patgen.

7. Check the patterns using proofreading files. Every error can be corrected by
putting the erroneously hyphenated word in the input list.

## Format of the word list

Every line of the word list may contain up to four fields divided by commas.

The **first field** contains a Latin word as written in a dictionary (normally
nominative singular for nouns, nominative singular masculine for adjectives,
first person present indicative active for verbs).

The **second field** contains the word type as described below. This field is
empty for uninflectable words.

The **third field** contains the first person perfect indicative active for
active verbs and the nominative singular masculine of the perfect passive
participle for deponent verbs, but only if this form is irregular.

The **fourth field** contains the supine for active verbs, but only if this
form is irregular.

### Orthographic conventions

The orthographic conventions for the word list guarantee that all hyphenation
points can be found correctly and that all other orthographic variants can be
generated automatically.

- mark long single vowels (but no digraphs and diphthongs) with macrons:
  `sēditiō`, `ædificō`; do not mark short vowels
- write *j* for every semivocalic *i*: `jam`, `jaciō`, `mājor`
- use *u* and *v* according to the modern conventions: `vērus`, `laudāvī`,
  `Ūrania`
- write *æ* and *œ* for the diphthongs *ae* and *oe*: `cælum`, `tragœdia`
- use hyphens to mark compound words: `ab-scindō`, `ob-œdīō`, `anim-ad-vertō`,
  `long-ævus`
- use lowercase letters; proper nouns and their derivatives may begin with an
  uppercase letter

### Possible word types

#### Adjectives

- `AC3`/`AI3` – comparable/incomparable adjectives with three endings; the
  first field contains the masculine form; when the masculine form does not end
  in *-us*, the third field contains the feminine form.
- `AC2`/`AI2` – comparable/incomparable adjectives with two endings; the first
  field contains the masculine/feminine form.
- `AC1`/`AI1` – comparable/incomparable adjectives with one ending; the first
  field contains the nominative; when the nominative does not end in *-āns* or
  *-ēns*, the third field contains the genitive.

Examples:
    longus,AC3
	 ācer,AC3,ācris
	 ūnicus,AI3
	 brevis,AC2
	 prior,AC2
	 prūdēns,AC1
	 vetus,AC1,veteris

#### Verbs
- `1` – verb of the first conjugation; the first field has to end in `ō` or
  `or` (for deponent verbs).
- `2` – verb of the second conjugation; the first field has to end in `eō` or
  `eor` (for deponent verbs).
- `3` – verb of the third conjugation; the first field has to end in `ō` or
  `or` (for deponent verbs).
- `3M` – verb of the mixed third conjugation; the first field has to end in
  `iō` or `ior` (for deponent verbs).
- `4` – verb of the fourth conjugation; the first field has to end in `iō` or
  `ior` (for deponent verbs).

Examples:
	laudō,1
	moneō,2,monuī,monitum
	mittō,3,mīsī,missum
	capiō,3M,cēpī,captum
	audiō,4
	hortor,1
	vereor,2,veritus
	ūtor,3,ūsus
	patior,3M,passus
	partior,4
	ab-scindō,3,ab-scidī,ab-scissus
	ex-audiō,4

## Scripts

### `flexura.lua`

This script generates all inflected forms of the Latin words in the input list,
as long as these forms are regular. The script is still under development.
Currently, only declensed adjective forms (including comparatives, superlatives
and adverbs) and the present stem forms of Latin verbs are generated.

#### Usage:
	lua5.3 flexura.lua [< inputfile] [> outputfile]

The input file must have the word list format described above. If no input
file is given, the standard input (terminal) is used for input; the input is
terminated by `CTRL+D`.

#### Irregular forms:

The following irregular forms are taken into account:
- the comparatives and superlatives of *bonus*, *māgnus*, *malus*, *multus*,
  *vetus*
- the adverbs *audācter* (beside *audāciter*), *bene*, *difficulter*,
  *magis/mage*, *parum*, *postrēmō*, *rārenter*, *sollerter* of *audāx*,
  *bonus*, *difficilis*, *māgnus*, *parvus*, *posterus*, *rārus*, *sollers*
- the short *a* in *dare* and its compounds
- the imperatives *dīc*, *dūc*, *fac* of *dīcere*, *dūcere*, *facere* and their
  compounds
- the imperative *calface* of *calefacere*

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
  character is ignored if this option is not used.
- `--suppress-hiatus` – never divide consecutive vowels within a word: `suus` →
  `suus`, `voluit` → `vo-luit`, `me|us` → `meus`; but `dē-esse` → `dē-es-se`
- `--trace-states` – debug option

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
  `vester` → `ves-ter`, `ūnctiō` → `ūnc-tiō`. Stop consonants followed by
  liquid consonants (*muta cum liquida*), *ch*, *ph*, *rh*, and *th* are not
  separated: `astrum` → `as-trum`, `sōbrius` → `sō-bri-us`. An auxiliary hyphen
  may be required because of the morphology of the word: `ab-luere` →
  `ab-lue-re`, `ab-stāre` → `ab-stā-re`.
- *qu* is considered as a single consonant, as well as *gu* preceded by *n* and
  followed by a vowel: `sequī` → `se-quī`, `sanguis` → `san-guis`. A vertical
  bar (U+7C) is required if *u* is a vowel after *ng* before another vowel:
  `langu|it` → `lan-gu-it`, `langu|ērunt` → `lan-gu-ērunt`.
- Single vowel syllables at the beginning or the end of a word are not
  separated: `odium` → `odi-um`, `luō` → `luō`. A single vowel syllable within
  a word is not separated from the preceding syllable: `speciōsus` →
  `spe-ciō-sus`, `tuērī` → `tuē-rī`. An auxiliary hyphen may be required
  because of the morphology of the word: `in-itium` → `in-iti-um`, `ob-œdīre` →
  `ob-œ·dī-re`. This rule is ignored when using the `--chant` option.
