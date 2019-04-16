# Generation of Latin hyphenation patterns

The patterns for liturgical Latin `hyph.la.liturgical.txt` have been written by
hand. They are improved continuously.

The patterns for classical Latin `hyph.la.classical.txt` and the Italian style
patterns for medieval and modern Latin `hyph.la.phonetic.txt` have also been
written by hand, but have been unmaintained for several years.

Because of some deficiencies of the existing patterns, we are going to create
improved patterns for classical Latin. The new patterns shall support marks for
long and short vowels (macrons and breves, e. g. *lĭnguă Lătīnă*) as long and
short vowels are important for classical Latin. The following workflow is
planned:

## Generation of hyphenation patterns for classical Latin

1. We maintain a list `index_verborum` of about 6500 Latin words without
inflected forms and without hyphenations, but containing information about the
inflection class and hyphens in compound words and with special orthographic
conventions. The exact format of the word list is described below.

2. Run the script `flexura.lua` on this list, which creates all possible
inflected forms, for example *laudō, laudās, laudat, …, laudābō, …, laudāvī, …,
laudātus, laudāta, laudātum, …* from input `laudō`. These forms are stored in
`index_formarum`.

3. Run the script `divisio.lua` on the output of step 2 to hyphenate all the
forms according to the basic rules. This is easy as the input list uses *i* and
*u* only as vowels. This yields *lau-dō, lau-dās, …*

4. Create orthographic variants by means of the script `variatio.lua`: `vī-vō`
→ *vi-vo, vī-vō, ui-uo, uī-uō*; `jūs-tus` → *jus-tus, jūs-tus, jūs-tŭs,
ius-tus, iūs-tus, iūs-tŭs*; `cæ-lum` → *cæ-lum, cǣ-lum, cæ-lŭm, cǣ-lŭm,
cae-lum, ca͞e-lum, cae-lŭm, ca͞e-lŭm*. It is crucial to do this after the
hyphenation. The script also removes incompatible hyphenation points in
homographs.

5. Create patterns using *patgen*. The shell script `generate-patgen-input.sh`
generates a list of hyphenated words as needed by *patgen* by means of the word
list and the scripts mentioned above.

6. Check the patterns using test files in the
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
  Also use *j* in the compounds of *jacĕre*: `ab-jiciō` (classical spelling:
  *abiciō*).
- Use *u* and *v* according to the modern conventions: `vērus`, `avārus`,
  `Ūrania`.
- Write *æ* and *œ* for the diphthongs *ae* and *oe*: `cælum`, `tragœdia`.
- Use hyphens to mark compound words: `ab-scindō`, `ē-jiciō`, `ob-œdiō`,
  `anim-ad-vertō`, `long-ævus`. Do not use hyphens if a prefix is assimilated
  to the following element of the compound or if a prefix is extended by an
  epenthesis (*d* or *s*): `abstrahō`, `assimils`, `afferō`, `difficilis`,
  `occidō`, `sustulī`, `complūrēs`, `redhibeō`.  However, a hyphen is
  necessary, when the second element begins with a vowel or with *fl* or *fr*
  or when *neg* is followed by *l*: `com-edō`, `red-emptiō`, `neg-ōtium`,
  `ef-flō`, `neg-legō`.
- Use an accented vowel (or a *combining acute accent* U+301 for vowels with
  macron) if an uninflectable word with at least two syllables has its accent
  on the last syllable: `ab-hínc`, `ad-hū́c`. Note: In other cases, the accent
  is generated automatically by the scripts.
- *au* and *eu* are considered as diphthongs. Use a vertical bar, when *au* or
  *eu* is no diphthong (e. g. `le|unculus`).
- *au* and *eu* are not considered as diphthongs when the *u* is part of an
  inflection ending for nouns, adjectives, and pronouns of the second
  declension (e. g. *deus*, *meus*). Use a *combining double inverted breve*
  (U+361) when *eu* is a diphthong in second declension words ending in *-eus*,
  e. g. `Erechthe͡us`.
- Only use lowercase letters except at the beginning of proper nouns and their
  derivatives.

### Possible word types

#### Verbs

- `1` – verb of the first conjugation
- `1intr` – intransitive verb of the first conjugation
- `2` – verb of the second conjugation
- `2intr` – intransitive verb of the second conjugation
- `3` – verb of the third conjugation
- `3intr` – intransitive verb of the third conjugation
- `3M` – verb of the mixed third conjugation
- `3Mintr` – intransitive verb of the mixed third conjugation
- `4` – verb of the fourth conjugation
- `4intr` – verb of the fourth conjugation
- `VP` – verb with perfect forms only
- `VI` – irregular verb
- `VIintr` – intransitive irregular verb (*eō* and some of its compounds)

Intransitive verbs are treated separately because they only have impersonal
passive forms. Deponent verbs, impersonal verbs, and irregular verbs having no
passive forms at all are not marked as intransitive.

Examples:

	laudō,1
	ambulō,1intr
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
	meminī,VP
	volō,VI,voluī
	eō,VIintr,iī,itum

#### Nouns

- `D1` – masculine/feminine noun of the first declension (ending in *-a*, *-æ*,
  *-ē*, *-ēs*, or *-ās*)
- `D2` – masculine/feminine noun of the second declension (ending in *-us*,
  *-r*, *-ī*, *-os*, or *-e͡us*); if the nominative ends in *-r*, the third
  field contains the genitive.
- `D2N` – neuter noun of the second declension (ending in *-um*, *-us*, *-a*,
  *-on*, or *-os*)
- `D3` – masculine/feminine noun of the third declension; the third field
  contains the genitive; the genitive is left out for nouns ending in
  *-ēns/-entis*, *-is/-is*, *-dō/-dinis*, *gō/-ginis*, *-iō/-iōnis*,
  *-ō/-ōnis*, *-or/-ōris*, *-tās/-tātis*, *-trīx/-trīcis*; the third field
  contains the accusative if this ends in *-im*.
- `D3N` – neuter noun of the third declension; the third field contains the
  genitive; the genitive is left out for nouns ending in *-men/-minis*.
- `D3gr` – Greek noun of the third declension (only for plural forms ending in
  *-es*); the third field contains the genitive
- `D4` – masculine/feminine noun of the fourth declension (ending in *-us* or
  *-ūs*)
- `D4N` – neuter noun of the fourth declension (ending in *-ū*)
- `D5` – masculine/feminine noun of the fifth declension (ending in *-ēs*)

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

#### Adjectives, pronouns, and declinable numerals

Adjectives are either comparable (e. g. *longus, longior, longissimus*) or
incomparable (e. g. *ūnicus*). Pronouns, declinable numerals, and incomparable
adjectives are similar, but pronouns and numerals do not have adverbs.

- `AC3`/`AI3` – comparable/incomparable adjective with three endings; if the
  masculine form does not end in *-us*, the third field contains the feminine
  form.
- `AC2`/`AI2` – comparable/incomparable adjective with two endings
- `AC1`/`AI1` – comparable/incomparable adjective with one ending; if the
  nominative does not end in *-āns* or *-ēns*, the third field contains the
  genitive.
- `P` – pronoun
- `N` – declinable numeral (cardinal, ordinal, or distributive)

Examples:

	longus,AC3
	ācer,AC3,ācris
	ūnicus,AI3
	brevis,AC2
	prior,AC2
	prūdēns,AC1
	vetus,AC1,veteris
	ego,P
	ille,P
	ūnus,N
	prīmus,N
	bīnī,N

## Scripts

### `flexura.lua`

This script generates all inflected forms of the Latin words in the input list.
This includes the conjugated forms of the Latin verbs, their infinitives and
participles, the declensed forms of nouns, adjectives (including comparatives,
superlatives and adverbs), pronouns and numerals.

#### Usage
	lua5.3 flexura.lua [option] [< inputfile] [> outputfile]

The input file must have the word list format described above. If no input
file is given, the standard input (terminal) is used for input; the input is
terminated by `CTRL+D` in this case.

The output contains vertical bars where *au* or *eu* is not a diphthong and
where *u* is a full vowel after *ng* or *s* before another vowel: *me|us*,
*su|us*. This is important to be able to find all syllable boundaries.

The word boundary in the compounds of *jacĕre* is replaced by a tilde:
*in~jiciō*. This is because the following *j* needs a special handling when
orthographical variants are generated; the *j* has to be omitted rather than
replaced by *i* in words like *in-jiciō*.

#### Options
- `--enclitics` – generate a variant with the enclitic *-que* for all forms
  except uninflectable words

#### Irregular forms

The following irregular forms are taken into account:

##### Verbs

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

##### Nouns

- the genitive plural forms *deābus* and *fīliābus* (beside *deīs* and
  *fīliīs*) of *dea* and *fīlia*
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

##### Adjectives and pronouns

- the comparatives *jūnior* (beside *juvenior*), *melior*, *mājor*, *minor*,
  *pējor*, *plūs*, *vetustior* of *juvenis*, *bonus*, *māgnus*, *parvus*,
  *malus*, *multus*, *vetus*
- the superlatives *citimus*, *dēterrimus*, *dextumus/dextimus*, *extrēmus*,
  *īnfimus/īmus*, *maximus*, *minimus*, *optimus*, *pessimus*,
  *plūrimus/plūrumus*, *postrēmus/postumus*, *proximus*, *suprēmus*,
  *veterrimus* of *citer*, *dēterior*, *dexter*, *exter/exterus*, *īnferus*,
  *māgnus*, *parvus*, *bonus*, *malus*, *multus*, *posterus*, *propior*,
  *superus*, *vetus*
- the adverbs *audācter* (beside *audāciter*), *bene*, *cito*, *difficulter*,
  *magis/mage*, *parum*, *rārenter*, *sollerter* of *audāx*, *bonus*, *citus*,
  *difficilis*, *māgnus*, *parvus*, *rārus*, *sollers*
- the vocative masculine *mī* of *meus*

### `divisio.lua`

This script hyphenates the words in the input list according to the basic
hyphenation rules for classical Latin. It is intended to help to prepare a
*patgen* input.

#### Usage
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

#### Options
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

#### Hyphenation rules used
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

### `variatio.lua`

This script creates orthographic variants of already hyphenated words. It also
removes incompatible hyphenation points in homographs.

#### Usage
	lua5.3 variatio.lua [options] [< inputfile] [> outputfile]

The input file has to follow the same conventions as the output of
`divisio.lua`. If no input file is given, the standard input (terminal) is used
for input; the input is terminated by `CTRL+D` in this case. A protocol about
suppressed hyphenation points is written to `variatio.log`.

#### Orthographic variants

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

#### Options
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

### `generate-patgen-input.sh`

This script generates a list of hyphenated words as needed by *patgen*.

#### Usage
	./generate-patgen-input.sh [option]

The generated file is named `patgen_input_classical`. Use this as *dictionary
file* for *patgen*.

#### Options
- `--ec` – suppress all orthographic variants not supported by the EC (T1) font
  encoding

### `generate-patterns.sh`

This script generates hyphenation patterns for classical Latin by means of
*patgen*.

#### Usage
	./generate-patterns.sh [option]

The script invokes the `generate-patgen-input.sh` script first. It then runs
*patgen* seven times using `patgen_translate_classical` as *translate file* and
writes the resulting patterns to the files `patterns_classical.[1-7]`. The
*patgen* log data is written to `patgen_classical.log`.

#### Options
- `--ec` – generate patterns compatible with the EC (T1) font encoding
