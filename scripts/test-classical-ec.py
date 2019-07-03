#!/usr/bin/env python3

import pyphen
import sys
import re

hyphenator = pyphen.Pyphen(filename='patterns/hyph_la_classical_ec.dic',left=2,right=2)
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
			line = re.sub('\s*\%.*', '', line)
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

dotest('tests/nonliturgical/wordlist-classical-italian.txt')
print()
dotest('tests/nonliturgical/wordlist-classical-only.txt')
