#!/usr/bin/env python3

import pyphen
import re
from argparse import ArgumentParser

parser = ArgumentParser()
parser.add_argument("--liturgical", action = "store_true")
parser.add_argument("--classical", action = "store_true")
parser.add_argument("--classical_ec", action = "store_true")
parser.add_argument("--italian", action = "store_true")

args = parser.parse_args()

if args.classical:
	hyphenator = pyphen.Pyphen(filename='patterns/hyph_la_classical.dic',left=2,right=2)
elif args.classical_ec:
	hyphenator = pyphen.Pyphen(filename='patterns/hyph_la_classical_ec.dic',left=2,right=2)
elif args.italian:
	hyphenator = pyphen.Pyphen(filename='patterns/hyph_la_modern.dic',left=2,right=2)
else:
	hyphenator = pyphen.Pyphen(filename='patterns/hyph_la_liturgical.dic',left=1,right=1)

seenSegs = {}
line = 0

def comparenoncompletehyphens(original, obtained):
	i = 0
	for c in obtained:
		if c == '-':
			if original[i] == '-':
				i = i + 1
		else:
			if original[i] == '-':
				return False
			else:
				i = i + 1
	return True

def printError(wrong, correct, base):
	print('%s 		%% %s  (not %s)' % (base, correct, wrong))

def dotest(filename, allhyphens=True):
	global hyphenator, seenSegs
	print('differences in '+filename+':')
	linenum = 0
	with open(filename, 'r') as f:
		for line in f:
			linenum += 1
			line = line.strip()
			line = re.sub(r'\s*\%.*', '', line)
			base = line.replace('-', '')
			if base in seenSegs and line != seenSegs[base][1]:
				print('ERROR: line %d: test \'%s\' differs from test \'%s\' line %d in %s' % (linenum, line, seenSegs[base][1], seenSegs[base][0], seenSegs[base][2]))
			else:
				seenSegs[base] = (linenum, line, filename)
			new = hyphenator.inserted(base)
			if allhyphens:
				if not line == new:
					printError(new, line, base)
			else:
				if not comparenoncompletehyphens(line, new):
					printError(new, line, base)

def deacc(accstr):
	return accstr.replace('á', 'a').replace('é', 'e').replace('í', 'i').replace('ó', 'o').replace('ú', 'u').replace('ý', 'y').replace('́', '').replace('ǽ', 'æ')

def dotest_accents(filename):
	global hyphenator
	print('differences in '+filename+':\nresult without accent (correct) / result with accent (incorrect)')
	with open(filename, 'r') as f:
		for line in f:
			line = line.strip()
			line = re.sub(r'\s*\%.*', '', line)
			baseacc = line.replace('-', '').lower()
			basenoacc = deacc(baseacc)
			resacc = hyphenator.inserted(baseacc)
			resnoacc = hyphenator.inserted(basenoacc)
			if not resnoacc == deacc(resacc):
				printError(resacc, resnoacc, baseacc)

if args.classical or args.classical_ec:
	dotest('tests/wordlist-classical-italian.txt')
	print()
	dotest('tests/wordlist-classical.txt')
elif args.italian:
	dotest('tests/wordlist-classical-italian.txt')
	print()
	dotest('tests/wordlist-italian.txt')
else:
	dotest('tests/wordlist-liturgical.txt')

print()
dotest_accents('tests/wordlist-liturgical-accents.txt')
print()
