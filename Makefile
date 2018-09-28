all: hyph_la_classical.dic hyph_la_phonetic.dic hyph_la_liturgical.dic

hyphen/substrings.pl:
	git submodule update --init

hyph_la_classical.dic: hyphen/substrings.pl patterns/hyph.la.classical.txt
	perl patterns/hyphen/substrings.pl patterns/hyph.la.classical.txt patterns/hyph_la_classical.dic UTF-8 2 2 > /dev/null

hyph_la_phonetic.dic: hyphen/substrings.pl patterns/hyph.la.phonetic.txt
	perl patterns/hyphen/substrings.pl patterns/hyph.la.phonetic.txt patterns/hyph_la_phonetic.dic UTF-8 2 2 > /dev/null

hyph_la_liturgical.dic: hyphen/substrings.pl patterns/hyph.la.liturgical.txt
	perl patterns/hyphen/substrings.pl patterns/hyph.la.liturgical.txt patterns/hyph_la_liturgical.dic UTF-8 2 2 > /dev/null

clean:
	rm patterns/hyph_la_classical.dic patterns/hyph_la_phonetic.dic patterns/hyph_la_liturgical.dic

check_all: check_classical_patterns check_phonetic_patterns check_liturgical_patterns

check_classical:
	python3 scripts/checkPatterns.py patterns/hyph.la.classical.txt

check_phonetic:
	python3 scripts/checkPatterns.py patterns/hyph.la.phonetic.txt

check_liturgical:
	python3 scripts/checkPatterns.py patterns/hyph.la.liturgical.txt

test: hyph_la_liturgical.dic scripts/test.py
	python3 scripts/test.py
