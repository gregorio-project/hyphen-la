all: hyph_la_classical.dic hyph_la_classical_ec.dic hyph_la_modern.dic hyph_la_liturgical.dic

hyphen/substrings.pl:
	git submodule update --init

hyph_la_classical.dic: hyphen/substrings.pl patterns/hyph.la.classical.txt
	perl patterns/hyphen/substrings.pl patterns/hyph.la.classical.txt patterns/hyph_la_classical.dic UTF-8 2 2 > /dev/null

hyph_la_classical_ec.dic: hyphen/substrings.pl patterns/hyph.la.classical.txt
	perl patterns/hyphen/substrings.pl patterns/hyph.la.classical.ec.txt patterns/hyph_la_classical_ec.dic UTF-8 2 2 > /dev/null

hyph_la_modern.dic: hyphen/substrings.pl patterns/hyph.la.modern.txt
	perl patterns/hyphen/substrings.pl patterns/hyph.la.modern.txt patterns/hyph_la_modern.dic UTF-8 2 2 > /dev/null

hyph_la_liturgical.dic: hyphen/substrings.pl patterns/hyph.la.liturgical.txt
	perl patterns/hyphen/substrings.pl patterns/hyph.la.liturgical.txt patterns/hyph_la_liturgical.dic UTF-8 2 2 > /dev/null

clean:
	rm patterns/hyph_la_classical.dic patterns/hyph_la_classical_ec.dic patterns/hyph_la_modern.dic patterns/hyph_la_liturgical.dic

check_all: check_classical check_modern check_liturgical

check_classical:
	python3 scripts/checkPatterns.py patterns/hyph.la.classical.txt
	python3 scripts/checkPatterns.py patterns/hyph.la.classical.ec.txt

check_modern:
	python3 scripts/checkPatterns.py patterns/hyph.la.modern.txt

check_liturgical:
	python3 scripts/checkPatterns.py patterns/hyph.la.liturgical.txt

test: hyph_la_liturgical.dic scripts/test.py
	python3 scripts/test.py
