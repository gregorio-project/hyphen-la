# Patterns elaboration

## Strings of caracters

The patterns developed on this repository are hyphenated patterns given to the machine concerning a string of characters, in order to mark where a hyphenation is possible in a word, in agreement with the rules of meaning and etymology. They are case insensitive.

A dot at the beginning of the pattern indicates that the string applies exclusively to the beginnings of words. A dot at the end of the pattern indicates that the string applies exclusively to the end of the words.

Each pattern described will always apply to words that contain it, unless another higher statement is present.

## Instructions

We give the instructions by numbers, from 0 to 9. 0 being the default value, it is not useful to write it.

Even numbers forbid hyphenation, more or less strongly depending on their value. While the odd numbers force the hyphenation, more or less strongly according to their value.

If the same string is subject to different instructions, the one with the highest number wins.
*E.g.*: `a3e` > `a2e` > `a1e`

## Pattern modification

Correcting the patterns when you notice an error requires to refer to all the patterns that concern the faulty word.

It is best to find the most words that are in accordance with a rule in order to establish a common pattern, and conversely, find all the words that have a string of characters related but which depend on a contrary rule. This will avoid over-multiplying the patterns.


