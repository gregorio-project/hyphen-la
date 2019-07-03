# Scripts

#### Dependencies

All those scripts depend on Python 3, and [pyphen](http://pyphen.org/). Note that you must have generated the patterns for libhyphen in order for the scripts to work. See also [the specific documentation](../patterns/README.md).

#### Installation

Fetch the entire repository (`git clone https://github.com/gregorio-project/hyphen-la.git`) and use it directly, no need to install. You can also adapt it to suit your needs.

## Check patterns

A small Python script which tracks duplicated and invalid patterns in a pattern file.

#### Usage

Type `python3 checkPatterns.py path/to/pattern/file.txt`, or, more simply, use `make check_x` in the main directory show the errors, where `x` can be: `all`, `classical`, `modern`, or `liturgical`.


## Syllabifier script

A small Python script you can use to add hyphens in a text.

It has many options, but an interesting feature is that it can add `()` automatically in a text, making it ready for use in Gregorio.

#### Usage

See `./syllabify.py -h` for all options.


## Test patterns

The scripts `test.py` (for liturgical Latin), `test-classical.py` (for
classical Latin), and `test-classical-ec.py` (for EC/T1 encoded classical
Latin) can automatically test the patterns in the `patterns` folder against the
list of words in the `tests` folder.

#### Usage

Go to the main directory and call `scripts/test.py`,
`scripts/test-classical.py`, or `scripts/test-classical-ec.py`. For liturgical Latin it is also possible to use `make test`.
