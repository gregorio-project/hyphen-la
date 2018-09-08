# Latin hyphenation resources

This repository aims at providing useful programs and resources for Latin hyphenation. It is based on the work by Claudio Beccari (who is also one of the main contributor to this repository), with the aim to spread his work and improve it through feedback of some Monasteries using the patterns for their liturgical books.

See [this demo](http://gregorio-project.github.io/hyphen-la/) for liturgical tests!

See [patterns](patterns) directory for the different patterns.

See [doc](doc) directory for some documentation.

See [tests](tests) directory for some tests.

See [scripts](scripts) for small python scripts using the patterns to hyphenate a text in a very simple way, or to check the patterns.

## Makefile

Run `make` in the main directory to do the conversion of patterns to libhyphen format (see the patterns [Readme](patterns/README.md) for more details).

Run `make check_all` to check the patterns files (see also the scripts [Readme](scripts/README.md) for more details).

Run `make test` to test the patterns against word lists in the [tests](tests) directory.


### Thanks

This repository has been made possible throught the help of
 * Claudio Beccari, main author
 * [The Abbey of Solesmes (FR)](http://www.solesmes.com/)
 * [The Abbey of Flavigny (FR)](http://www.clairval.com)
 * [Abbazia di Praglia (IT)](http://www.praglia.it)
 * [Abbazia Mater Ecclesiae (IT)](http://it.wikipedia.org/wiki/Abbazia_Mater_Ecclesiae)
