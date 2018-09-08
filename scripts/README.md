# Scripts

## Dependencies

All those scripts depend on Python 3, and [pyphen](http://pyphen.org/). Note that you must have generated the patterns for libhyphen in order for the scripts to work. See [../patterns/README.md](documentation).

## Installation

Fetch the entire repository (`git clone https://github.com/gregorio-project/hyphen-la.git`) and use it directly, no need to install. You can also adapt it to suit your needs.

### Check patterns

A small Python script which tracks duplicated and invalid pattern in a pattern file.

#### Usage

`python3 checkPatterns.py path/to/pattern/file.txt` show the errors.


### Syllabifier script

A small Python script you can use to add hyphens in a text.

It has many options, but an interesting feature is that it can add `()` automatically in a text, making it ready for use in Gregorio.

#### Usage

See `./syllabify.py -h` for all options.
