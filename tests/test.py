#!/usr/bin/env python3

import pyphen
import sys
import re

hyphenator = pyphen.Pyphen(filename='../patterns/hyph_la_liturgical.dic',left=1,right=1)
seenSegs = {}
line = 0
nbErrors = 0

def comparenoncompletehyphens(original, obtained):
	global nbErrors
	i = 0
	for c in obtained:
		if c == '-':
			if original[i] == '-':
				i = i + 1
		else:
			if original[i] == '-':
				nbErrors += 1
				return False
			else:
				i = i + 1
	return True

def printError(wrong, correct, base):
	print('%s 		%% %s  (not %s)' % (base, correct, wrong), file=sys.stderr)

def dotest(filename, allhyphens=True):
	global hyphenator, seenSegs, nbErrors
	print('differences in '+filename+':', file=sys.stderr)
	linenum = 0
	with open(filename, 'r') as f:
		for line in f:
			linenum += 1
			line = line.strip()
			line = re.sub('\s*\%.*', '', line)
			base = line.replace('-', '')
			if base in seenSegs and line != seenSegs[base][1]:
				print('ERROR: line %d: test \'%s\' differs from test \'%s\' line %d in %s' % (linenum, line, seenSegs[base][1], seenSegs[base][0], seenSegs[base][2]), file=sys.stderr)
				nbErrors += 1
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
	print('differences in '+filename+':\nresult without accent (correct) / result with accent (incorrect)', file=sys.stderr)
	with open(filename, 'r') as f:
		for line in f:
			line = line.strip()
			line = re.sub('\s*\%.*', '', line)
			baseacc = line.replace('-', '').lower()
			basenoacc = deacc(baseacc)
			resacc = hyphenator.inserted(baseacc)
			resnoacc = hyphenator.inserted(basenoacc)
			if not resnoacc == deacc(resacc):
				printError(resacc, resnoacc, baseacc)

#dotest('proofreading-Claudio-2.txt')
#print('\n')
#dotest('proofreading-Solesmes-1.txt')
#print('\n')
#dotest('proofreading-Solesmes-2.txt')
#print('\n')
#dotest('proofreading-Solesmes-3.txt')
#print('\n')
dotest('proofreading-liturgical.txt')
print('\n')
dotest_accents('proofreading-liturgical-accents.txt')
print('\n')
dotest('proofreading-diphtongues.txt')
print('\n')
dotest_accents('proofreading-diphtongues-accents.txt')
print('\n')
#dotest('proofreading-Flavigny-text-1.txt')
#print('\n')
#dotest('proofreading-Flavigny-2.txt')
#print('\n')
#dotest('orberg.txt', False)
#print('\n')
#dotest_accents('proofreading-Solesmes-1-accents.txt')
#print('\n')
#dotest_accents('proofreading-Solesmes-2-accents.txt')
#print('\n')
#dotest_accents('proofreading-Solesmes-3-accents.txt')
#print('\n')

if nbErrors > 0:
	sys.exit(1)
