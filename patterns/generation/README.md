# Generation of Latin hyphenation patterns

The patterns for liturgical Latin `hyph.la.liturgical.txt` have been written by
hand. They are improved continuously.

The patterns for medieval and modern Latin `hyph.la.modern.txt` have also been
written by hand. They are currently unmaintained.

The original version of the patterns for classical Latin
`hyph.la.classical.txt` have also been written by hand. Because of some
deficiencies of the old patterns, we have created improved patterns for
classical Latin using *patgen*. The new patterns support marks for long and
short vowels (macrons and breves, e. g. *lĭnguă Lătīnă*) as long and short
vowels are important for classical Latin. We use the following workflow.

## Generation of hyphenation patterns for classical Latin

1. We maintain a list `index_verborum` of about 7500 Latin words without
inflected forms and without hyphenations, but containing information about the
inflection class and hyphens in compound words and with special orthographic
conventions. The exact format of the word list is described below.

2. Run the script `flexura.lua` on this list, which creates all possible
inflected forms, for example *laudō, laudās, laudat, …, laudābō, …, laudāvī, …,
laudātus, laudāta, laudātum, …* from input `laudō`. These forms are stored in
the file `index_formarum`.

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

The steps 2 to 5 are executed by the `generate-patterns.sh` script. The
`publish-patterns.sh` script is used to move the generated patterns to the
correct directories.

All scripts are documented in a [separate file](scripts.md).

## Format of the word list `index_verborum`

Every line of the word list may contain up to four fields divided by commas.
White space and following characters are treated as comments.

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
form is irregular, and the future participle for deponent verbs if its stem
is different from the stem of the perfect passive participle.

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
  `efflō`, `occidō`, `sustulī`, `complūrēs`, `redhibeō`. However, a hyphen is
  necessary, when the second element begins with a vowel or when *neg* is
  followed by *l*: `com-edō`, `red-emptiō`, `neg-ōtium`, `neg-legō`.
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
	orior,3M,ortus,oritūrus
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
