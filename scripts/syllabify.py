#!/usr/bin/env python3

"""
    Syllabification script

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

    Depends on pyphen: http://pyphen.org/
    You also need the hyph_la_liturgical.dic file. To get it, get the
      hyphen-la project on https://github.com/gregorio-project/hyphen-la
      and run "make" in the "patterns" directory.

"""

import pyphen
import argparse
import sys
import re
import os
import configparser

dir_path = os.path.dirname(os.path.realpath(__file__))
config_file_name = dir_path + '/syllabify.cfg'

config = configparser.ConfigParser()
config['DEFAULT']['type'] = 'chant'
config['DEFAULT']['mode'] = 'liturgical'
config['DEFAULT']['hyphenchar'] = '-'
config['DEFAULT']['endofword'] = 'False'
config.read(config_file_name)

parser = argparse.ArgumentParser(
                    description='A script to "syllabify" (insert a character between all syllables) a file.',formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('-t', '--text-type', choices = ['chant', 'prose'],
                    help='text type',
                    default=config['DEFAULT']['type'], dest='type')
parser.add_argument('-m', '--hyphen-mode', choices = ['liturgical', 'phonetic', 'etymology'],
                    help='Hyphenation mode',
                    default=config['DEFAULT']['mode'], dest='mode')
parser.add_argument('-c', '--hyphen-char',
                    help='Character to be used to split the syllables.  Allowed to be a string if enclosed in ""',
                    default=config['DEFAULT']['hyphenchar'], dest='hyphenchar')
parser.add_argument('-e', '--end-of-word',
                    help='Change whether the hyphen character is added to the end of each word too',
                    action='store_const', dest='endofword',
                    const=(not config.getboolean('DEFAULT','endofword')),default=config.getboolean('DEFAULT','endofword'))
parser.add_argument('-d','--store-defaults',
                    help='Do not syllabify.  Instead store the current options as the new defaults.  If given more than once, reset defaults to factory settings.  WARNING: User must have write access to %s for this option to work.' % dir_path,
                    action='count', default=argparse.SUPPRESS, dest='defaults')
files = parser.add_argument_group('file arguments:',description='These arguments can also be provided as postional arguments, in which case the input file comes first.')
files.add_argument('-i', '--input', nargs='?',
                   help='Source of the words to be syllabified.  If None or -, then input will be read from stdin.',
                   dest='inputfile')
files.add_argument('-o', '--output-file', nargs='?',
                   help='Destination of the syllabified words.  If None or -, then ouput will be written to stdout.',
                   dest='outputfile')
files.add_argument('fileone',nargs='?',
                   help=argparse.SUPPRESS)
files.add_argument('filetwo',nargs='?',
                   help=argparse.SUPPRESS)

args = parser.parse_args()

if getattr(args, 'defaults', 0) == 1:
    config['DEFAULT']['type'] = args.type
    config['DEFAULT']['mode'] = args.mode
    config['DEFAULT']['hyphenchar'] = args.hyphenchar
    config['DEFAULT']['endofword'] = str(args.endofword)
    with open(config_file_name, 'w') as configfile:
        config.write(configfile)
    print('New defaults stored')
    sys.exit(0)
elif getattr(args, 'defaults', 0) > 1:
    os.remove(config_file_name)
    print('Defaults reset')
    sys.exit(0)

if (args.inputfile == None or args.inputfile == '-'):
    if (args.outputfile == None or args.outputfile == '-'):
        if (args.fileone == None or args.fileone == '-') and (args.filetwo == None or args.filetwo == '-'):
            input = sys.stdin
            output = sys.stdout
        elif args.fileone != None and (args.filetwo == None or args.filetwo == '-'):
            try:
                input = open(args.fileone,'r')
                output = sys.stdout
            except:
                input = sys.stdin
                output = open(args.fileone,'w')
        else:
            input = open(args.fileone,'r')
            output = open(args.filetwo,'w')
    else:
        if (args.fileone == None or args.fileone == '-') and (args.filetwo == None or args.filetwo == '-'):
            input = sys.stdin
            output = open(args.outputfile,'w')
        elif args.fileone != None and (args.filetwo == None or args.filetwo == '-'):
            input = open(args.fileone,'r')
            output = open(args.outputfile,'w')
        else:
            print("Error: too many files")
            print("Both -o and positional output file given")
            sys.exit(1)
else:
    if (args.outputfile == None or args.outputfile == '-'):
        if (args.fileone == None or args.fileone == '-') and (args.filetwo == None or args.filetwo == '-'):
            input = open(args.inputfile,'r')
            output = sys.stdout
        elif args.fileone != None and (args.filetwo == None or args.filetwo == '-'):
            input = open(args.inputfile,'r')
            output = open(args.fileone,'w')
        else:
            print("Error: too many files")
            print("Both -i and positional input file give")
            sys.exit(1)
    else:
        if (args.fileone == None or args.fileone == '-') and (args.filetwo == None or args.filetwo == '-'):
            input = open(args.inputfile,'r')
            output = open(args.outputfile,'w')
        elif args.fileone != None and (args.filetwo == None or args.filetwo == '-'):
            print("Error: too many files")
            print("Both -i and -o given with a positional file")
            sys.exit(1)
        else:
            print("Error: too many files")
            print("Both -i and -o given with positional files")
            sys.exit(1)
        
    

righthyphenmin = 2
lefthyphenmin = 2
cutvowels = False
if (args.type == 'chant'):
    righthyphenmin=1
    lefthyphenmin=1
    cutvowels = True

hyphenator = pyphen.Pyphen(filename=dir_path+'/../patterns/hyph_la_'+args.mode+'.dic',left=lefthyphenmin,right=righthyphenmin)

def hyphenate_one_word(word,punctuation):
    global hyphenator,args
    r = hyphenator.inserted(word,args.hyphenchar)
    r+=punctuation
    if args.endofword:
        r+=args.hyphenchar
    return r

wordregex = re.compile(r'\b([^\W\d_]+)\b([\-‐‑‒–—)\]}〉»’”›!"\'*,.:;?†⁓⁕⁜~+✝✠]*)')


for line in input:
    line = line.strip()
    hyphenline = wordregex.sub(lambda match: hyphenate_one_word(match.group(1),match.group(2)), line)
    output.write(hyphenline+'\n')

input.close()
output.close()
