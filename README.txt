
# Background

The graphical compare tools gvimdiff, kompare, or meld are used to compare text files on Linux

In many cases, it is difficult and time-consuming to visually compare large files because of formatting differences

For example:
* log files are often many MB of unbroken text, with some "don't care" information such as timestamps
* different versions of version-crontrolled-code may have significant formatting differences


# Purpose

This script 'dif' preprocesses input text files with a wide variety of options

Afterwards, it runs the Linux tools gvimdiff, kompare, or meld on these intermediate files

'dif' can also be used as part of an automated testing framework, returning 0 for identical, and 1 for mismatch


# Installation instructions

To install dif and run tests:
* download dif from GitHub  'git clone https://github.com/koknat/dif.git'
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
    
