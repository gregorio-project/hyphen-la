# Documentation

This directory contains some documentation about Latin hyphenation.

## General considerations

Several aspects of the Latin language make hyphenation consensus difficult to find. The main difficulty is that Latin has been written and pronounced in various ways in different times and places, and thus has been hyphenated in different ways.

A good hyphenation system should consider the following criteria:
- _usage:_ when people are used to a certain hyphenation, any other hyphenation
  will look strange
- _phonology:_ hyphenation should make sense in syllable segmentation, based on
  phonology
- _grammar:_ it should also respect grammar
- _etymology:_ etymology can also be a criterion in some cases
- _typography:_ some hyphenations that would make sense for other criteria
  don’t from a typographical point of view (typically after the first letter or
  before the last one)
- _type of text:_ a chant is not hyphenated the same way as a regular text
  (`quon-i-am` in chant, `quon-iam` in prose)

All these criteria conflict with each other, and a balance is difficult to find.

## Hyphenation styles

Our patterns support three different hyphenation styles of Latin: *classical*,
*modern*, and *liturgical*.

### Classical hyphenation

The hyphenation rules are based on classical Latin phonology and etymology.
This hyphenation style should be used
- for editions of classical Latin texts,
- for dictionaries and grammars of classical Latin,
- for educational material if no Italian pronuncation is used,
- for any Latin text if the traditional German or Slavic pronunciation of Latin
  is used.

See [classical-hyphenation.md](classical-hyphenation.md) for details.

### Modern (and medieval) hyphenation

The hyphenation rules are based on Italian phonetics and typographic tradition.
This hyphenation style should be used
- for editions of medieval and modern Latin texts if the Italian or a similar
  pronunciation is used,
- for educational material in Italy if the classical hyphenation style is not
  preferred,
- for liturgical texts if Italian pronunciation is used and a rather
  traditional typography is preferred (opposed to the liturgical style),
- for non-liturgical ecclesiastical documents.

See [modern-hyphenation.md](modern-hyphenation.md) for details.

### Liturgical hyphenation

The hyphenation rules are based on Italian phonetics, but more consequently
than in the modern hyphenation style. This hyphenation style should be used
- for liturgical texts if Italian pronunciation is used.

An attempt has been made to summarize the liturgical hyphenation rules in [liturgical-hyphenation.md](liturgical-hyphenation.md), which gives also considerations on diphthongs, homographs and words for which the hyphenation is not certain.

Until Vatican II council, the Vatican required texts to be hyphenated in the
“medieval” (post-4th century CE) way, but after Vatican II this rule seems less
strict, and Solesmes got an oral authorization to use the phonetical patterns,
which are more similar to the classical ones and are easier to read. Solesmes
cautiously used the phonetical patterns in their recent books.

### Comparison of the three hyphenation styles

The following examples show some typical differences between the three styles.
- *magnus*
    - *classical*: `mag-nus` based on classical phonology
    - *modern* and *liturgical*: `ma-gnus` based on Italian phonetics
- *crescit*
    - *classical*: `cres-cit` based on classical phonology
    - *modern* and *liturgical*: `cre-scit` based on Italian phonetics
- *cresco*
    - *classical*: `cres-co` based on classical phonology
    - *modern*: `cre-sco` based on Italian typographic tradition
    - *liturgical*: `cres-co` based on Italian phonetics
- *hostis*
    - *classical*: `hos-tis` based on classical phonology
    - *modern*: `ho-stis` based on Italian typographic tradition
    - *liturgical*: `hos-tis` based on Italian phonetics
- *vesper*
    - *classical*: `ves-per` based on classical phonology
    - *modern*: `ve-sper` based on Italian typographic tradition
    - *liturgical*: `ves-per` based on Italian phonetics
- *longaevus*
    - *classical*: `long-ae-vus` based on etymology
    - *modern*: `lon-gae-vus` based on Italian phonetics
    - *liturgical*: `lon-gæ-vus` based on Italian phonetics
- *decennis*
    - *classical*: `dec-en-nis` based on etymology
    - *modern* and *liturgical*: `de-cen-nis` based on Italian phonetics
- *neglego*
    - *classical*: `neg-le-go` based on etymology
    - *modern* and *liturgical*: `ne-gle-go` based on Italian phonetics
- *discedo*
    - *classical*: `dis-ce-do` based on etymology
    - *modern* and *liturgical*: `di-sce-do` based on Italian phonetics

## Bibliography
### Latin hyphenation
- Abbaye de Solesmes, *Distinction des syllabes dans les mots latins*, in
  Études Grégoriennes XLII (2016).
- Claudio Beccari, *Computer Aided Hyphenation for Italian and Modern Latin*,
  in TUGboat Volume 13.1 (1992), available on
  [tug.org](https://tug.org/TUGboat/tb13-1/tb34becc.pdf).
- Yannis Haralambous, *Hyphenation Patterns for Ancient Greek and Latin*, in
  TUGboat Volume 13.4 (1992), available on
  [tug.org](https://tug.org/TUGboat/tb13-4/tb37hara-hyfgl.pdf).
- Claudio Beccari, *Some Remarks on Typesetting Classical Latin*, in TUGboat
  Volume 15.1 (1994), available on
  [tug.org](https://tug.org/TUGboat/tb15-1/tb42becc-ancient.pdf).
- Claudio Beccari, *Greek and Latin hyphenation – Recent advances*, in
  ArsTEXnica N° 18 (2014), available on
  [guitex.org](http://www.guitex.org/home/images/ArsTeXnica/AT018/GreekLatinHyphens.pdf).
- Max Niedermann, *Phonétique historique du latin*, 1940. An extract is
  reproduced [here](liturgical-hyphenation.md#Phonétique-historique-du-latin).

### Dictionaries
- [*Thesaurus Linguae Latinae
  (ThLL)*](https://www.thesaurus.badw.de/tll-digital/tll-open-access.html),
  1900 ff. – The ThLL is the most comprehensive dictionary of ancient Latin. It
  is monolingual Latin and contains etymological notes as well as all known
  special forms of every word. The ThLL is still incomplete. So far, it covers
  the letters A–M, O, P, and parts of N and R.
- Félix Gaffiot, [*Dictionnaire illustré
  latin-français*](https://www.lexilogos.com/latin/gaffiot.php), 1934. – A very
  comprehensive Latin-French dictionary of ancient Latin. There is also a
  [revised edition](http://gerardgreco.free.fr/spip.php?article43&lang=fr) of
  2016. The original version of 1934 marks long vowels in open syllables only,
  whereas the revised edition marks all long vowels.
- Karl Ernst Georges, [*Ausführliches lateinisch-deutsches
  Handwörterbuch*](http://www.zeno.org/Georges-1913), 8th edition, 1913/1918. –
  A comprehensive Latin-German dictionary of ancient Latin.
- Henri Goelzer, *Le latin en poche. Dictionnaire latin-français*, 1928. –
  Covers ancient and medieval Latin up to the Carolingian era.
- Eugène Benoist et Henri Goelzer, *Nouveau dictionnaire Latin-Français*, 1934
  (?). – The most complete version of this dictionary published shortly after
  the death of the author.
- C. T. Lewis/C. Short, [*A Latin
  Dictionary*](http://www.perseus.tufts.edu/hopper/text?doc=Perseus%3atext%3a1999.04.0059),
  1879. – A comprehensive Latin-English dictionary.
- The *Oxford Latin Dictionary (OLD)*, 1968–1982. – A dictionary representing a
  relatively recent stage of research, but only covering classical Latin.
- Joseph Maria Stowasser, *Lateinisch-deutsches Schulwörterbuch*, several
  editions (e. g. 1979, 1994, 2016). – This is a popular school dictionary in
  the German-speaking countries. It does not only cover ancient Latin, but also
  selected medieval and Neo-Latin authors.
- Albert Sleumer, *Kirchenlateinisches Wörterbuch*, 1926. – A Latin-German
  dictionary dedicated to the Latin of the Vulgate and the liturgical books.

### Dictionaries of medieval Latin
- Charles du Cange et al., [*Glossarium mediæ et infimæ
  Latinitatis*](http://ducange.enc.sorbonne.fr/), 1883–1887. – Outdated and
  intended for historians rather than philologists, but still the only
  dictionary covering the Latin of the entire Middle Ages.
- [*Novum Glossarium Mediae Latinitatis (NGML)*](http://glossaria.eu/ngml/),
  1957 ff. – A modern dictionary of medieval Latin within the period from 800
  to 1200 with French translations, so far covering the letters L–O and parts
  of P.
- *Mittellateinisches Wörterbuch (MLW)*, 1959 ff. – A modern dictionary of the
  medieval Latin of German-speaking territories up to the 13th century,
  containing Latin explanations and German translations of every word. So far,
  it covers the letters A–H and parts of I.

### Etymological dictionaries
- A Ernout/A. Meillet, *Dictionnaire étymologique de la langue latine*.
  Reprint of the 4th edition (1959) revised by J. André, 1985. – An
  etymological dictionary that has been kept up to date until relatively recent
  times.
- A. Walde/J. B. Hofmann, [*Lateinisches etymologisches
  Wörterbuch*](https://archive.org/details/walde/), 3rd edition, 1938/1954. –
  The most recent German-speaking etymological dictionary of Latin does not
  only give the etymology as supposed by the author, but also shortly discusses
  deviant opinions. Unfortunately, some articles are confused and difficult to
  understand.
- Ferdinand Jacob, [*Lexique étymologique
  latin-français*](https://archive.org/stream/LexiqueEtymologiqueLatin-franais),
  1883. – Outdated, but quite comprehensive.

### Grammars
- H. Rubenbauer/J. B. Hofmann, *Lateinische Grammatik*, 12th edition, revised
  by R. Heine, 1995.
- H. Petitmangin, [*Grammaire latine
  (complète)*](https://archive.org/details/PetitmanginLatinGrammaire/), 37th
  edition, revised by P.-N. Burtin and A. Pitou, 1956.
- Rafael Kühner, *Ausführliche Grammatik der lateinischen Sprache*, 2nd
  edition, vol. 1: [*Elementar-, Formen- und
  Wortlehre*](https://archive.org/details/ausfhrlichegra01khuoft/) revised by
  F. Holzweissig, 1912.
- Leumann/Hofmann/Szantyr, *Lateinische Grammatik*, vol. 1: *Lateinische Laut-
  und Formenlehre* by Manu Leumann. Handbuch der Altertumswissenschaft, 2.
  Abteilung, 2. Teil, 1. Band, 1977.

### Other aids
- François Martin, *Les mots latins*, 1976.
- Rüdiger Fischer, *Lateinische Wortkunde*, 4th edition, 2007.
- [*Collatinus web*](https://outils.biblissima.fr/en/collatinus-web/). Online
  lemmatiser and morphological analyser for Latin texts. – Very helpful, but
  not free of errors and not always complete.
- [*Grand dictionnaire latin*](https://www.grand-dictionnaire-latin.com/). – Is
  able to generate inflected forms quite reliably.
