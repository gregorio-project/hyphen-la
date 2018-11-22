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

## Generation of hyphenation patterns for classical Latin

1. Create a list `index_verborum` of about 2000 Latin words without inflected
forms and without hyphenations, but containing information about the inflection
class and hyphens in compound words and with special orthographic conventions.
Orthographic variants can easily be created later. The exact format of the word
list is described below.

2. Run the script `flexura.lua` on this list, which creates all possible
inflected forms, for example *laudō, laudās, laudat, ..., laudābō, ...,
laudāvī, ..., laudātus, laudāta, laudātum, ...* from input `laudō`. These forms
are stored in `index_formarum`.

3. Run the script `divisio.lua` on the output of step 2 to hyphenate all the
forms according to the basic rules. This is easy as the input list uses *i* and
*u* only as vowels. This yields *lau-dō, lau-dās, ...*.

4. Create orthographic variants by means of the script `variatio.lua`: `vī-vō`
→ *vi-vo, vī-vō, ui-uo, uī-uō*; `jūs-tus` → *jus-tus, jūs-tus, jūs-tŭs,
ius-tus, iūs-tus, iūs-tŭs*; `cæ-lum` → *cæ-lum, cǣ-lum, cæ-lŭm, cǣ-lŭm,
cae-lum, ca͞e-lum, cae-lŭm, ca͞e-lŭm*. It is crucial to do this after the
hyphenation.

5. Handle special cases like homographs.

6. Create patterns using patgen.

7. Check the patterns using test files in the
[tests/nonliturgical](../../tests/nonliturgical) directory. Every error can be
corrected by putting the erroneously hyphenated word in the input list.

## Format of the word list `index_verborum`

Every line of the word list may contain up to four fields divided by commas.

The **first field** contains a Latin word as written in a dictionary (normally,
the first person present indicative active for verbs, the nominative singular
for nouns, the nominative singular masculine for adjectives).

The **second field** contains the word type as described below. This field is
empty for uninflectable words.

The **third field** contains the first person perfect indicative active for
active verbs and the nominative singular masculine of the perfect passive
participle for deponent verbs, but only if this form is irregular. For some
nouns, it contains the genitive or the accusative and for some adjectives the
feminine form or the genitve, as described below.

The **fourth field** contains the supine for active verbs, but only if this
form is irregular.

### Orthographic conventions

The orthographic conventions for the word list guarantee that all hyphenation
points can be found correctly and that all other orthographic variants can be
generated automatically.

- Mark long single vowels (but no digraphs and diphthongs) with macrons:
  `sēditiō`, `ædificō`; do not mark short vowels.
- Write *j* for every semivocalic *i*: `jam`, `jaciō`, `Gājus`, `jējūnium`.
- Use *u* and *v* according to the modern conventions: `vērus`, `laudāvī`,
  `Ūrania`.
- Write *æ* and *œ* for the diphthongs *ae* and *oe*: `cælum`, `tragœdia`.
- Use hyphens to mark compound words: `ab-scindō`, `ob-œdiō`, `anim-ad-vertō`,
  `long-ævus`.
- Only use lowercase letters except at the beginning of proper nouns and their
  derivatives.

### Possible word types

#### Verbs
- `1` – verb of the first conjugation
- `2` – verb of the second conjugation
- `3` – verb of the third conjugation
- `3M` – verb of the mixed third conjugation
- `4` – verb of the fourth conjugation

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

#### Nouns

- `D1` – masculine/feminine noun of the first declension
- `D2` – masculine/feminine noun of the second declension; if the nominative
  ends in *-r*, the third field contains the genitive.
- `D2N` – neuter noun of the second declension
- `D3` – masculine/feminine noun of the third declension; the third field
  contains the genitive; the genitive is left out for nouns ending in
  *-dō/-dinis*, *gō/-ginis*, *-ēns/-entis*, *-iō/-iōnis*, *-is/-is*,
  *-or/-ōris*, *-tās/-tātis*; the third field contains the accusative if this
  ends in *-im*.
- `D3N` – neuter noun of the third declension; the third field contains the
  genitive; the genitive is left out for nouns endings in *-men/-minis*.
- `D4` – masculine/feminine noun of the fourth declension
- `D4N` – neuter noun of the fourth declension
- `D5` – masculine/feminine noun of the fifth declension

Examples:

	pēcunia,D1
	angustiæ,D1
	lectus,D2
	ager,D2,agrī
	vir,D2,virī
	dōnum,D2N
	arma,D2N
	canis,D3
	carō,D3,carnis
	turris,D3,turrim
	agmen,D3N
	animal,D3N,animālis
	currus,D4
	cornū,D4N
	diēs,D5

#### Adjectives und declinable numerals

Adjectives are either comparable (e.g. *longus, longior, longissimus*) or
incomparable (e.g. *ūnicus*). Declinable numerals and incomparable adjectives are
similar, but numerals do not have adverbs.

- `AC3`/`AI3` – comparable/incomparable adjective with three endings; if the
  masculine form does not end in *-us*, the third field contains the feminine
  form.
- `AC2`/`AI2` – comparable/incomparable adjective with two endings
- `AC1`/`AI1` – comparable/incomparable adjective with one ending; if the
  nominative does not end in *-āns* or *-ēns*, the third field contains the
  genitive.
- `N` – declinable numeral (cardinal, ordinal, or distributive)

Examples:

	longus,AC3
	ācer,AC3,ācris
	ūnicus,AI3
	brevis,AC2
	prior,AC2
	prūdēns,AC1
	vetus,AC1,veteris
	ūnus,N
	prīmus,N
	bīnī,N

## Scripts

### `flexura.lua`

This script generates all inflected forms of the Latin words in the input list.
The script is still under development. Currently, only the present stem forms
of Latin verbs, declensed noun forms, declensed adjective forms (including
comparatives, superlatives and adverbs), and declensed numeral forms are
generated.

#### Usage
	lua5.3 flexura.lua [< inputfile] [> outputfile]

The input file must have the word list format described above. If no input
file is given, the standard input (terminal) is used for input; the input is
terminated by `CTRL+D` in this case.

The output contains vertical bars where *au* or *eu* is not a diphthong and
where *u* is a full vowel after *ng* or *s* before another vowel: *me|us*,
*su|us*.

#### Irregular forms

The following irregular forms are taken into account:

##### Verbs

- the short *a* in *dare* and its compounds
- the imperatives *dīc*, *dūc*, *fac* of *dīcere*, *dūcere*, *facere* and their
  compounds
- the imperative *calface* of *calefacere*

##### Nouns

- the genitive plural forms *deābus* and *fīliābus* (besides *deīs* and
  *fīliīs*) of *dea* and *fīlia*
- the plural forms *diī/dī* (besides *deī*) and *diīs/dīs* (besides *deīs*) of
  *deus*
- the ablative form *vespere* (besides *vesperō*) of *vesper*
- the accusative form *vulgum/volgum* of the neuter noun *vulgus/volgus*
- the plural form *loca* (besides *locī*) of *locus*
- the defective forms of *vīs* (plural *vīrēs*)
- the genitive plural form *boum* (besides *bovum*) and the dative/ablative
  plural forms *bōbus* and *būbus* of *bōs*
- the genitve plural form *vāsōrum* and the dative/ablative plural form *vāsīs*
  of *vās*
- the dative/ablative plural form ending in *-ubus* of *arcus*, *artus*, and
  *tribus*
- the declensed forms of *domus*

##### Adjectives and pronouns

- the comparatives *jūnior* (besides *juvenior*), *melior*, *mājor*, *pējor*,
  *plūs*, *vetustior* of *juvenis*, *bonus*, *māgnus*, *malus*, *multus*,
  *vetus*
- the superlatives *citimus*, *dēterrimus*, *extrēmus*, *īnfimus/īmus*,
  *maximus*, *optimus*, *pessimus*, *plūrimus/plūrumus*, *postrēmus/postumus*,
  *proximus*, *suprēmus*, *veterrimus* of *citer*, *dēterior*, *exter/exterus*,
  *īnferus*, *māgnus*, *bonus*, *malus*, *multus*, *posterus*, *propior*,
  *superus*, *vetus*
- the adverbs *audācter* (besides *audāciter*), *bene*, *cito*, *difficulter*,
  *magis/mage*, *parum*, *rārenter*, *sollerter* of *audāx*, *bonus*, *citus*,
  *difficilis*, *māgnus*, *parvus*, *rārus*, *sollers*
- the vocative masculine *mī* of *meus*

### `divisio.lua`

This script hyphenates the words in the input list according to the basic
hyphenation rules for classical Latin. It is intended to help to prepare a
*patgen* input.

#### Usage
	lua5.3 divisio.lua [options] [< inputfile] [> outputfile]

The input file has to contain a list of words separated by line breaks. If no
input file is given, the standard input (terminal) is used for input; the input
is terminated by `CTRL+D` in this case.

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
are replaced by *ae* and *oe*: `æ·di-fi-cā-re` (*ædi-fi-cā-re* or
*ae-di-fi-cā-re*), `ob-œ·dī-re` (*ob-œdī-re* or *ob-oe-dī-re*), `su·æ` (*suæ*
or *su-ae*).

#### Options
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

#### Hyphenation rules used
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
  followed by a vowel and *su* followed by a vowel: `sequī` → `se-quī`,
  `sanguis` → `san-guis`, `suāvis` → `suā-vis`. A vertical bar (U+7C) is
  required if *u* is a vowel after *ng* or *s* before another vowel: `langu|it`
  → `lan-gu-it`, `langu|ērunt` → `lan-gu-ērunt`.
- Single vowel syllables at the beginning or the end of a word are not
  separated: `odium` → `odi-um`, `luō` → `luō`. A single vowel syllable within
  a word is not separated from the preceding syllable: `speciōsus` →
  `spe-ciō-sus`, `tuērī` → `tuē-rī`. An auxiliary hyphen may be required
  because of the morphology of the word: `in-itium` → `in-iti-um`, `ob-œdīre` →
  `ob-œ·dī-re`. This rule is ignored when using the `--chant` option.

### `variatio.lua`

This script creates orthographic variants an already hyphenated word. The input
has to follow the same conventions as the output of `divisio.lua`.

#### Usage
	lua5.3 variatio.lua [options] [< inputfile] [> outputfile]

The input file has to follow the same conventions as the output of
`divisio.lua`. If no input file is given, the standard input (terminal) is used
for input; the input is terminated by `CTRL+D` in this case.

#### Orthographic variants

If no options are given, the following orthographic variants are generated.
Some of them may be suppressed by options as explained below.

1. A variant with *j* and a variant with *i* for words containing *j*:
`jē-jū-nium` → *jē-jū-nium*, *iē-iū-nium*.
2. A variant with *U/v* and a variant with *V/u* for words containing *U/v*:
`vī-vō` → *vī-vō*, *uī-uō*; `Ūra-nia` → *Ūra-nia*, *V̄ra-nia*.
3. A variant with *æ/œ* and a variant with *ae/oe* for words containing
digraphs: `æ·dī-lis` → *ædī-lis*, *ae-dī-lis*; `cœ-tus` → *cœ-tus*, *coe-tus*.

Orthogonally to this, the following variants are created:
1. A variant without diacritical marks: *ci-vi-tas*, *ædi-lis*, *ae-di-lis*,
*lau-dan-dæ*, *lau-dan-dae*, *Um-bria*.
2. For words containing long single vowels: A variant with macrons on all long
single vowels: *cī-vi-tās*, *ædī-lis*, *ae-dī-lis*, *Ūra-nia*, *V̄ra-nia*. As
the Unicode Standard does not provide a macron variant of `V`, the combining
macron (U+304) us used where `V` represents a long vowel.
3. For words containing digraphs: A variant with macrons on all long single
vowels and digraphs: *ǣdī-lis*, *lau-dan-dǣ*. The Unicode Standard provides
macron variants only for `Æ` and `æ` (U+1E2 and U+1E3). The combining macron
(U+304) us used for `Œ` and `œ`.
4. For words containing diphthongs: A variant with macrons on all long single
vowels, digraphs and diphthongs: *a͞e-dī-lis*, *la͞u-dan-dǣ*, *la͞u-dan-da͞e*. The
*combining double macron* (U+35E) is used for diphthongs.
5. For words containing short vowels: A variant with macrons on all long single
vowels and with breves on all short vowels: *cī-vĭ-tās*, *ædī-lĭs*,
*ae-dī-lĭs*, *Ūră-nĭă*, *V̄ră-nĭă*, *Ŭm-brĭă*, *V̆m-brĭă*. The combining breve
(U+306) is used for `V`, `Y`, and `y`.
6. For words containing short vowels and digraphs: A variant with macrons on
all long single vowels and digraphs and with breves on short vowels: *ǣdī-lĭs*,
*lau-dăn-dǣ*.
7. For words containing short vowels and diphthongs: A variant with macrons on
all long single vowels, digraphs, and diphthongs and with breves on short
vowels: *a͞e-dī-lĭs*, *la͞u-dăn-dǣ*, *la͞u-dăn-da͞e*.

#### Options
- `--no-j` – suppress all orthographic variants containing *J* or *j*.
- `--no-v` – suppress all orthographic variants containing *U* or *v*.
- `--no-digraphs` – suppress all orthographic variants containing *Æ*, *æ*,
  *Œ*, or *œ*.
- `--no-macrons` – suppress all orthographic variants containing macrons.
- `--no-breves` – suppress all orthographic variants containing breves.
- `--mixed` – generate variants with all possible combinations of vowels with
  and without diacritical marks, e.g. *ci-vi-tas*, *ci-vi-tās*, *ci-vĭ-tas*,
  *ci-vĭ-tās*, *cī-vi-tas*, *cī-vi-tās*, *cī-vĭ-tas*, *cī-vĭ-tās* from input
  `cī-vi-tās`. Expect very long output when using this option!
