#!/usr/bin/env python3 

"""
    Hyphenation file checker

    Copyright (C) 2016 Elie Roux

    Permission is hereby granted, free of charge, to any person obtaining a copy of
    this software and associated documentation files (the "Software"), to deal in
    the Software without restriction, including without limitation the rights to
    use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
    of the Software, and to permit persons to whom the Software is furnished to do
    so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.

"""

import argparse
import sys
import re

parser = argparse.ArgumentParser(
                    description='Tiny script to check hyphenation patterns (against duplicated, invalid, etc.).',formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('path',
                    help='Path to a pattern file',
                    action='store', type = argparse.FileType('r'))

args = parser.parse_args()

seenPatterns = {}
line = 0
nbErrors = 0

for pat in args.path:
    line += 1
    pat = pat.strip('\n')
    if re.search('\s', pat):
        print('  line %d: pattern \'%s\' contains space' % (line, pat), file=sys.stderr)
        nbErrors += 1
    reducedPat = re.sub(r'\d', '', pat)
    if reducedPat in seenPatterns:
        print('  line %d: pattern \'%s\' duplicate with pattern \'%s\' line %d' % (line, pat, seenPatterns[reducedPat][1], seenPatterns[reducedPat][0]), file=sys.stderr)
        nbErrors += 1
    else:
        seenPatterns[reducedPat] = (line, pat)

if nbErrors == 0:
    print('No error found')
    sys.exit(0)
else:
    sys.exit(1)
