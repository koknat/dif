
The graphical compare tools meld, gvimdiff, tkdiff, and kompare are used to compare text files on Linux

In many cases, it is difficult and time-consuming to visually compare large files because of formatting differences

For example:
* different versions of code may differ only in comments or whitespace
* log files are often many MB of unbroken text, with some "don't care" information such as timestamps or temporary filenames
* json or yaml files may have ordering differences


## Purpose

'dif' preprocesses input text files with a wide variety of options

Afterwards, it runs the Linux tools meld, gvimdiff, tkdiff, or kompare on these intermediate files

'dif' can also be used as part of an automated testing framework, returning 0 for identical, and 1 for mismatch


## Installation

To install dif and run tests:
* cd dif/test
* ./dif.t

It should return with 'all tests passed'

Perl versions 5.6.1 through 5.30 have been tested

For convenience, link to 'dif' from your ~/bin directory, or create an alias


To see usage:
* cd ..  (back into dif main directory)
* ./dif


To run dif
* ./dif file1 file2 <options>
    
