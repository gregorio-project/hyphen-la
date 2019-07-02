# Scripts helping to generate Latin hyphenation patterns

## `flexura.lua`

This script generates all inflected forms of the Latin words in the input list.
This includes the conjugated forms of the Latin verbs, their infinitives and
participles, the declensed forms of nouns, adjectives (including comparatives,
superlatives and adverbs), pronouns and numerals.

### Usage
	lua5.3 flexura.lua [option] [< inputfile] [> outputfile]

The input file must have the word list format described in the [README
file](README.md). If no input file is given, the standard input (terminal) is
used for input; the input is terminated by `CTRL+D` in this case.

The output contains vertical bars where *au* or *eu* is not a diphthong and
where *u* is a full vowel after *ng* or *s* before another vowel: *me|us*,
*su|us*. This is important to be able to find all syllable boundaries.

The word boundary in the compounds of *jacĕre* is replaced by a tilde:
*in~jiciō*. This is because the following *j* needs a special handling when
orthographical variants are generated; the *j* has to be omitted rather than
replaced by *i* in words like *in-jiciō*.

### Options
- `--enclitics` – generate a variant with the enclitics *-ne*, *-que*, and
  *-ve* for all forms except uninflectable words

### Irregular forms

The following irregular forms are taken into account:

#### Verbs

- the short *a* in *dare* and its compounds
- the imperatives *dīc*, *dūc*, *fac* of *dīcere*, *dūcere*, *facere* and their
  compounds
- the imperative *calface* of *calefacere*
- the forms of the following irregular verbs (word type `VI` or `VIintr`):
  *ajō*, *eō* and compounds, *ferō* and compounds, *fīō*, *in-quam*, *malō*,
  *nōlō*, *possum*, *quæsō*, *sum* and compounds, *volō*
- the form *ad-juerō* (beside *ad-jūverō*) of *ad-juvāre*
- the form *con-jēxit* (beside *con-jēcerit*) of *con-jicere*
- the form *super-escit* (beside *super-erit*) of *super-esse*
- the form *vesperēscit* (beside *vesperāscit*) of *vesperāscere*

#### Nouns

- the ablative plural forms *deābus*, *famulābus*, and *fīliābus* (beside
  *deīs*, *famulīs*, and *fīliīs*) of *dea*, *famula*, and *fīlia*
- the plural forms *diī/dī* (beside *deī*) and *diīs/dīs* (beside *deīs*) of
  *deus*
- the ablative form *vespere* (beside *vesperō*) of *vesper*
- the accusative form *vulgum/volgum* of the neuter noun *vulgus/volgus*
- the plural forms *loca* and *joca* (beside *locī* and *jocī*) of *locus* and
  *jocus*
- the defective forms of *vīs* (plural *vīrēs*)
- the genitive plural form *boum* (beside *bovum*) and the dative/ablative
  plural forms *bōbus* and *būbus* of *bōs*
- the genitve plural form *vāsōrum* and the dative/ablative plural form *vāsīs*
  of *vās*
- the dative/ablative plural form ending in *-ubus* of *arcus*, *artus*, and
  *tribus*
- the declensed forms of *domus*
- the declensed forms of *holus-ātrum/holeris-ātrī*,
  *jūs-jūrandum/jūris-jūrandī*, *māter-familiās/matris-familiās*,
  *olus-ātrum/oleris-ātrī*, *pater-familiās/patris-familiās*,
  *rēs-pūblica/reī-pūblicæ*, *rōs-marīnus/rōris-marīnī*,
  *trēs-virī/trium-virōrum*

#### Adjectives and pronouns

- the comparatives *jūnior* (beside *juvenior*), *melior*, *mājor*, *minor*,
  *pējor*, *plūs*, *vetustior* of *juvenis*, *bonus*, *māgnus*, *parvus*,
  *malus*, *multus*, *vetus*
- the superlatives *citimus*, *dēterrimus*, *dextumus/dextimus*, *extrēmus*,
  *īnfimus/īmus*, *maximus*, *minimus*, *optimus*, *permaximus*, *pessimus*,
  *plūrimus/plūrumus*, *postrēmus/postumus*, *proximus*, *suprēmus*,
  *veterrimus* of *citer*, *dēterior*, *dexter*, *exter/exterus*, *īnferus*,
  *māgnus*, *parvus*, *bonus*, *permagnus*, *malus*, *multus*, *posterus*,
  *propior*, *superus*, *vetus*
- the adverbs *audācter* (beside *audāciter*), *bene*, *cito*, *difficulter*,
  *magis/mage*, *parum*, *rārenter*, *sollerter* of *audāx*, *bonus*, *citus*,
  *difficilis*, *māgnus*, *parvus*, *rārus*, *sollers*
- the vocative masculine *mī* of *meus*

## `divisio.lua`

This script hyphenates the words in the input list according to the basic
hyphenation rules for classical Latin. It is intended to help to prepare a
*patgen* input.

### Usage
	lua5.3 divisio.lua [options] [< inputfile] [> outputfile]

The input file has to follow the same conventions as the output of
`flexura.lua`. If no input file is given, the standard input (terminal) is used
for input; the input is terminated by `CTRL+D` in this case.

The input may contain the following characters:
- the 26 lowercase and the 26 uppercase letters of the Latin alphabet
- vowels with macrons: `Ā` (U+100), `ā` (U+101), `Ē` (U+112), `ē` (U+113), `Ī`
  (U+12A), `ī` (U+12B), `Ō` (U+14C), `ō` (U+14D), `Ū` (U+16A), `ū` (U+16B), `Ȳ`
  (U+232), `ȳ` (U+233)
- digraphs: `Æ` (U+C6), `æ` (U+E6), `Œ` (U+152), `œ` (U+153)
- auxiliary symbols as described below: `-`, `~`, `|`, and `^`

The output will contain five types of syllable boundary markers:
- a hyphen `-` for a regular hyphenation point
- a baseline dot `.` for a syllable boundary that is not a hyphenation point
- a middle dot `·` (U+B7) for a hyphenation point that is illegal as long as
  digraphs are used, but becomes legal when the digraphs are replaced by *ae*
  and *oe*: `æ·di-fi-cā-re` (*ædi-fi-cā-re* or *ae-di-fi-cā-re*), `ob-œ·dī-re`
  (*ob-œdī-re* or *ob-oe-dī-re*), `su·æ` (*suæ* or *su-ae*); furthermore, the
  middle dot is used after `ji` where the *j* is omitted in the classical
  spelling: `in~ji·ci.ō`
- a tilde `~` for a hyphenation point before `ji` where the *j* is omitted in
  the classical spelling: `in~ji·ci.ō`
- an underscore `_` for a syllable boundary that is not a hyphenation point
  before `ji` where the *j* is omitted in the classical spelling: `ē_ji·ci.ō`

### Options
- `--chant` – hyphenate even single vowel syllables as needed for chant:
  `ōrāre` → `ō-rā-re`, `voluī` → `vo-lu-ī`, `in-itium` → `in-i-ti-um`, `tuērī`
  → `tu-ē-rī`; the `--suppress-hiatus` option is ignored.
- `--greek` – use Greek hyphenation for Greek words; hyphenation points that
  are not in accordance with the Latin rules have to be marked with `^` in the
  input: `sce^ptrum` → `sce-ptrum`, `rhy^thmus` → `rhy-thmus`; the `^`
  character is ignored if this option is not used.
- `--suppress-hiatus` – never divide consecutive vowels within a word: `su|us`
  → `su.us`, `voluit` → `vo-lu.it`, `me|us` → `me.us`; but `dē-esse` →
  `dē-es-se`
- `--trace-states` – debug option

### Hyphenation rules used
- Two vowels are separated: `meīs` → `me-īs`, `viam` → `vi-am`. *y* is
  considered as a vowel. *au* and *eu* are considered as diphthongs; thus they
  are not separated: `laus` → `laus`, `claustra` → `claus-tra`, `heus` →
  `heus`. A vertical bar (U+7C) is required to separate *au* or *eu*: `me|us` →
  `me-us`, `aure|us` → `au-re-us`.
- A single consonant between two vowels is taken to the next syllable: `domus`
  → `do-mus`, `lā-tus` → `lā-tus`. An auxiliary hyphen is required if the
  consonant belongs to the preceding syllable because of the morphology of the
  word: `sub-īre` → `sub-īre`, `anim-advertō` → `anim-ad-ver-tō`.
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
  → `lan-gu-it`, `langu|ērunt` → `lan-gu.ē-runt`.
- Single vowel syllables at the beginning or the end of a word are not
  separated: `odium` → `o.di-um`, `luō` → `lu.ō`. A single vowel syllable
  within a word is not separated from the preceding syllable: `speciōsus` →
  `spe-ci.ō-sus`, `tuērī` → `tu.ē-rī`. An auxiliary hyphen may be required
  because of the morphology of the word: `in-itium` → `in-i.ti-um`, `ob-œdīre`
  → `ob-œ·dī-re`. This rule is ignored when using the `--chant` option.

## `variatio.lua`

This script creates orthographic variants of already hyphenated words. It also
removes incompatible hyphenation points in homographs.

### Usage
	lua5.3 variatio.lua [options] [< inputfile] [> outputfile]

The input file has to follow the same conventions as the output of
`divisio.lua`. If no input file is given, the standard input (terminal) is used
for input; the input is terminated by `CTRL+D` in this case. A protocol about
suppressed hyphenation points is written to `variatio.log`.

### Orthographic variants

If no options are given, the following orthographic variants are generated.
Some of them may be suppressed by options as explained below.

1. For words with at least two syllables: A variant with and a variant without
accent: `ag-men` → *ag-men*, *ág-men*; `a.mī-cus` → *amī-cus*, *amī́-cus*;
`im-pe-tus` → *im-pe-tus*, *ím-pe-tus*. The *combining acute accent* (U+301) is
used for vowels already having another diacritical mark (e. g. a macron).
2. A variant with *j* and a variant with *i* for words containing *j*:
`jē-jū-ni.um` → *jē-jū-nium*, *iē-iū-nium*.
3. A variant with *U/v* and a variant with *V/u* for words containing *U/v*:
`vī-vō` → *vī-vō*, *uī-uō*; `Ūra-nia` → *Ūra-nia*, *V̄ra-nia*.
4. A variant with *æ/œ* and a variant with *ae/oe* for words containing
digraphs: `æ·dī-lis` → *ædī-lis*, *ae-dī-lis*; `cœ-tus` → *cœ-tus*, *coe-tus*.

Orthogonally to this, the following variants are created:
1. A variant without diacritical marks: *ci-vi-tas*, *ædi-lis*, *ae-di-lis*,
*lau-dan-dæ*, *lau-dan-dae*, *ob-œdi-re*, *ob-oe-di-re*, *Um-bria*.
2. For words containing diphthongs: A variant with ties on all diphthongs:
*a͡e-di-lis*, *la͡u-dan-dæ*, *la͡u-dan-da͡e*, ob-o͡e-di-re. The *combining double
inverted breve* (U+361) is used.
3. For words containing long single vowels: A variant with macrons on all long
single vowels: *cī-vi-tās*, *ædī-lis*, *ae-dī-lis*, *ob-œdī-re*, *ob-oe-dī-re*,
*Ūra-nia*, *V̄ra-nia*. As the Unicode Standard does not provide a macron variant
of `V`, the *combining macron* (U+304) us used where `V` represents a long
vowel.
4. For words containing long single vowels and diphthongs: A variant with
macrons on all long single vowels and ties on all diphthongs: *a͡e-dī-lis*,
*ob-o͡e-dī-re*.
5. For words containing digraphs: A variant with macrons on all long single
vowels and digraphs: *ǣdī-lis*, *lau-dan-dǣ*, *ob-œ̄dī-re*. The Unicode Standard
provides macron variants only for `Æ` and `æ` (U+1E2 and U+1E3). The *combining
macron* (U+304) us used for `Œ` and `œ`.
6. For words containing diphthongs: A variant with macrons on all long single
vowels, digraphs and diphthongs: *a͞e-dī-lis*, *la͞u-dan-dǣ*, *la͞u-dan-da͞e*,
*ob-o͞e-dī-re*. The *combining double macron* (U+35E) is used for diphthongs.
7. For words containing short vowels: A variant with macrons on all long single
vowels and with breves on all short vowels: *cī-vĭ-tās*, *ædī-lĭs*,
*ae-dī-lĭs*, *ŏb-œdī-rĕ*, *ŏb-oe-dī-rĕ*, *Ūră-nĭă*, *V̄ră-nĭă*, *Ŭm-brĭă*,
*V̆m-brĭă*. The *combining breve* (U+306) is used for `V`, `Y`, and `y`.
8. For words containing short vowels and diphthongs: A variant with macrons on
all long single vowels, with breves on all short vowels, and with ties on all
diphthongs: *a͡e-dī-lĭs*, *la͡u-dăn-dæ*, *la͡u-dăn-da͡e*, *ŏb-o͡e-dī-rĕ*.
9. For words containing short vowels and digraphs: A variant with macrons on
all long single vowels and digraphs and with breves on short vowels: *ǣdī-lĭs*,
*lau-dăn-dǣ*, *ŏb-œ̄dī-rĕ*.
10. For words containing short vowels and diphthongs: A variant with macrons on
all long single vowels, digraphs, and diphthongs and with breves on short
vowels: *a͞e-dī-lĭs*, *la͞u-dăn-dǣ*, *la͞u-dăn-da͞e*, *ŏb-o͞e-dī-rĕ*.

### Options
- `--no-j` – suppress all orthographic variants containing *J* or *j*.
- `--no-v` – suppress all orthographic variants containing *U* or *v*.
- `--no-digraphs` – suppress all orthographic variants containing *Æ*, *æ*,
  *Œ*, or *œ*.
- `--no-accents` – suppress all orthographic variants containing accents.
- `--no-macrons` – suppress all orthographic variants containing macrons.
- `--no-breves` – suppress all orthographic variants containing breves.
- `--no-ties` – suppress all orthographic variants containing ties.
- `--mixed` – generate variants with all possible combinations of vowels with
  and without diacritical marks, e. g. *ci-vi-tas*, *ci-vi-tās*, *ci-vĭ-tas*,
  *ci-vĭ-tās*, *cī-vi-tas*, *cī-vi-tās*, *cī-vĭ-tas*, *cī-vĭ-tās* from input
  `cī-vi-tās`. Expect very long output when using this option!
- `--mixed-breves` – generate variants with all possible combinations of short
  vowels with and without breves, e. g. *co-rō-na*, *co-rō-nă*, *cŏ-rō-na*,
  *cŏ-rō-nă* from input `co-rō-na`.
- `--roman-numerals` – output Roman numerals with more than one character up to
  3000.

## `generate-patgen-input.sh`

This script generates a list of hyphenated words as needed by *patgen*.

### Usage
	./generate-patgen-input.sh [option]

The generated file is named `patgen_input_classical`. Use this as *dictionary
file* for *patgen*.

### Options
- `--ec` – suppress all orthographic variants not supported by the EC (T1) font
  encoding

## `generate-patterns.sh`

This script generates hyphenation patterns for classical Latin by means of
*patgen*.

### Usage
	./generate-patterns.sh [option]

The script invokes the `generate-patgen-input.sh` script first. It then runs
*patgen* seven times using `patgen_translate_classical` as *translate file* and
writes the resulting patterns to the files `patterns_classical.[1-7]`. The
*patgen* log data is written to `patgen_classical.log`.

### Options
- `--ec` – generate patterns compatible with the EC (T1) font encoding

## `publish-patterns.sh`

This scripts publishes the patterns generated by `generate-patterns.sh` in the
`patterns` directory and TeX versions of these patterns in the `patterns/tex`
directory.

### Usage
	./publish-patterns.sh
