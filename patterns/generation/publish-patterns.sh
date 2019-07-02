version=2.0
versionEC=2.0-EC
TeXFile=../tex/hyph-la-x-classic.tex
TeXFileEC=../tex/hyph-la-x-classic.ec.tex
echo -n "publishing hyphenation patterns for classical Latin, version "
echo -n $version
echo -n "/"
echo $versionEC
echo "pattern files used:"
ls -l {patterns_classical.7,patterns_classical_ec.7}
echo -n "% title: Hyphenation patterns for classical Latin
% copyright: Copyright (C) " | tee $TeXFile > $TeXFileEC
echo -n `date +%Y` | tee -a $TeXFile >> $TeXFileEC
echo -n " Keno Wehr
% notice: This file is part of the hyph-utf8 package.
%     See http://www.hyphenation.org/tex for more information.
%     These patterns are also suitable for medieval and modern Latin if German
%     or Slavic pronunciation is used.
%     See https://github.com/gregorio-project/hyphen-la/tree/master/doc for
%     documentation.
% source: https://github.com/gregorio-project/hyphen-la/tree/master/patterns/generation
% language:
%     name: Classical Latin
%     tag: la-x-classic
% version: " | tee -a $TeXFile >> $TeXFileEC
echo -n $version >> $TeXFile
echo -n $versionEC >> $TeXFileEC
echo -n " " | tee -a $TeXFile >> $TeXFileEC
date +%F | tee -a $TeXFile >> $TeXFileEC
echo -n "% authors:
%  -
%     name: Claudio Beccari
%  -
%     name: Keno Wehr
%     contact: wehr (at) abgol.de
% licence:
%     name: MIT
%     url:  http://opensource.org/licenses/MIT
%     text: >
%           Permission is hereby granted, free of charge, to any person
%           obtaining a copy of this software and associated documentation
%           files (the \"Software\"), to deal in the Software without
%           restriction, including without limitation the rights to use,
%           copy, modify, merge, publish, distribute, sublicense, and/or
%           sell copies of the Software, and to permit persons to whom the
%           Software is furnished to do so, subject to the following
%           conditions:
%
%           The above copyright notice and this permission notice shall be
%           included in all copies or substantial portions of the Software.
%
%           THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND,
%           EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
%           OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
%           NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
%           HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
%           WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
%           FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
%           OTHER DEALINGS IN THE SOFTWARE.
% hyphenmins:
%     generation:
%         left: 2
%         right: 2
% changes:
%  -
%     date: 2014-10-06
%     version: 1.2
%     author: Claudio Beccari
%  -
%     date: `date +%F`
%     version: 2.0" | tee -a $TeXFile >> $TeXFileEC
echo "" >> $TeXFile
echo "-EC" >> $TeXFileEC
echo -n "%     author: Keno Wehr
%     description: patgen-based pattern generation; improved support of
%         compound words; do not hyphenate Roman numerals; support of v and j
%         spellings, ae/oe ligatures, " | tee -a $TeXFile >> $TeXFileEC
echo "accents, macrons, breves, and ties" >> $TeXFile
echo "and accents" >> $TeXFileEC
echo -n "%
\\message{Hyphenation patterns for classical Latin, v. " | tee -a $TeXFile >> $TeXFileEC
echo -n $version >> $TeXFile
echo -n $versionEC >> $TeXFileEC
echo -n " `date +%F`" | tee -a $TeXFile >> $TeXFileEC
echo "}
%
% The following patgen parameters have been used:
%" | tee -a $TeXFile >> $TeXFileEC
cat patterns_classical_parameters | tee -a $TeXFile >> $TeXFileEC
echo "%" | tee -a $TeXFile >> $TeXFileEC
echo '\bgroup
\lccode"E1="E1
\lccode"E6="E6
\lccode"E9="E9
\lccode"ED="ED
\lccode"F3="F3
\lccode"F7="F7
\lccode"FA="FA
\lccode"FD="FD' >> $TeXFileEC
echo '\patterns{' | tee -a $TeXFile >> $TeXFileEC
cat patterns_classical.7 >> $TeXFile
sed -e 's/á/^^e1/g' -e 's/é/^^e9/g' -e 's/í/^^ed/g' -e 's/ó/^^f3/g' \
-e 's/ú/^^fa/g' -e 's/ý/^^fd/g' -e 's/æ/^^e6/g' -e 's/œ/^^f7/g' \
< patterns_classical_ec.7 >> $TeXFileEC
echo "}" | tee -a $TeXFile >> $TeXFileEC
echo '\egroup' >> $TeXFileEC
cp patterns_classical.7 ../hyph.la.classical.txt
cp patterns_classical_ec.7 ../hyph.la.classical.ec.txt
