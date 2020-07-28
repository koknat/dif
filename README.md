# dif - a preprocessing front end to gvimdiff/meld/kompare
![Alt text](dif.png?raw=true "Screenshot of gvimdiff")

# Background

The graphical compare tools gvimdiff, kompare, or meld are used to compare text files on Linux

In many cases, it is difficult and time-consuming to visually compare large files because of formatting differences

For example:
* log files are often many MB of unbroken text, with some "don't care" information such as timestamps
* different versions of version-crontrolled-code may have significant formatting differences


# Purpose

This script 'dif' preprocesses input text files with a wide variety of options

Afterwards, it runs the Linux tools gvimdiff, kompare, or meld on these intermediate files

'dif' can also be used as part of an automated testing framework against golden files, returning 0 for identical, and 1 for mismatch


# Solutions

#### Problem: differences in whitespace or comments or case cause mismatches
Solution:  Use options -white or -nowhite or -comments or -case

#### Problem: input files are too large for a quick comparison
Solution 1:  Use -head or -tail to only compare the first or last N lines

Solution 2:  Use -start and -stop to specify a section of the file using regexes

#### Problem: files are sorted differently
Solution:  Use -sort

#### Problem: log files contain dates and times
Solution:   Use -replaceDates

#### Problem: lines are too long to visually compare easily
Solution:  Use -fold to wrap

#### Problem: need to view your changes to a file on Perforce
Solution:  'dif file#head' will show the differences between the file in p4, vs the local file

#### Problem: files both need to be filtered using regexes, to strip out certain characters or sequences
Solution 1:  Use -grep <regex> or -ignore <regex> to filter in or out

Solution 2:  Use -search <regex> -replace <regex> to supply one instance of substitution and replacement

Solution 3:  Use -replaceTable <file> to supply a file with many substitution/replacement regexes

# Usage examples
* dif file1 file2
* dif file1 file2 -sort
* dif file1 file2 -white -comments -case
* dif file1 file2 -search 'foo' -replace 'bar'


# Options

    Filtering options:    
       -head              Compare only the first 10000 lines
       
       -headLines N       Compare only the first N lines

       -tail              Compare only the first 10000 lines
       
       -tailLines N       Compare only the first N lines

       -fields N          Compare only fields N
                          Multiple fields may be given, separated by commas (-fields N,M)
                          Field numbers start at 0
                          Fields in the input files are assumed to be separated by spaces, unless the filename ends with .csv (separated by commas)
                          Example:  -fields 2
                          Example:  -fields 0,2      (fields 0 and 2)
                          Example:  -fields -1       (last field)
                          Example:  -fields 2+       (field 2 and onwards)
                          Example:  -fields not2+    (ignore fields 2 and onwards)
                          Example:  -fields not0,5+  (ignore fields 0, 5, and onwards)

       -fieldSeparator regex    Only needed if default field separators above are not sufficient
                                Example:  -fieldSeparator ':'
                                Example:  -fieldSeparator '[,=]' 

       -fieldJustify      Make all fields the same width, right-justified

       -white             Remove blank lines and leading/trailing whitespace
                          Condense multiple whitespace to a single space
       
       -noWhite           Remove all whitespace.  Useful to check output of perltidy

       -case              Convert files to lowercase before comparing
       
       -split             Splits each line on whitespace
       
       -splitChar 'char'  Splits each line on 'char'
       
       -trim              Trims each line to 105 characters
                          Useful when lines are very long, and the important information is near the beginning
       
       -trimChars N       Trims with specified number of characters, instead of 105
       
       -comments          Remove any comments like // or # or single-line */ /*

       -grep 'regex'      Only keep lines which match the user-specified regex
                          Multiple regexs can be specified, for example:  -grep '(regexA|regexB)'

       -ignore 'regex'    Ignore any lines which match the user-specified regex
                          This is the exact opposite of the -grep function
                          
       -start 'regex'     Start comparing file when line matches regex
       
       -stop 'regex'      Stop comparing file when line matches regex

                          For example, to compare Perl subroutines 'add' and 'subtract' inside files a.pm and b.pm:
                              dif a.pm b.pm -start '^sub (add|subtract) ' -stop '^}'

       -start1 -stop1 -start2 -stop2
                          Similar to -start and -stop
                          The '1' and '2' refer the files
                          Enables comparing different sections within the same file, or different sections within different files
                          For example, to compare Perl subroutines 'add' and 'subtract' within single file:
                              dif a.pm -start1 'sub add' -stop1 '^}' -start2 'sub subtract' -stop '^}'

       -subroutine 'subroutine_name'
                          Compare same subroutine from two source files
                          Subroutines may be Perl (sub {}) or TCL (proc {}{})
                          May specify multiple subroutines with -subroutine '(mysubA|mysubB|mysubC)'
                          Internally, this piggybacks on the -start -stop functionality

       -subroutineSort
                          Useful when Perl subroutines have been moved within a file
                          This option preprocesses each file, so that the subroutine definitions
                          are in alphabetical order
       
       -search 'regex'
       -replace 'regex'   On each line, do global regex search and replace
                              For example, to replace 'line 1234' with 'line':
                                  -search 'line \d+'  -replace 'line'
                                  
                              Since the search/replace terms are interpreted as regex,
                              remember to escape any parentheses
                                  Exception:  if you are using regex grouping, 
                                              do not escape the parentheses
                                  For example:
                                      -search '(A|B|C)'  -replace 'D'

                              Since the replace term is run through eval, make sure to escape any $ dollar signs
                              Make sure you use 'single-quotes' instead of double-quotes
                              For example, to convert all spaces to newlines, use:
                                  -search '\s+'  -replace '\n'

       -replaceTable file     Specify a two-column file which will be used for search/replace
                              The delimiter is any amount of spaces
                              Terms in the file are treated as regular expressions
                              The replace term is run through eval

       -replaceDates      Remove dates and times, for example:
                               Monday July 20 17:36:34 PDT 2020
                               Dec  3  2019
                               Jul 10 17:42
                               1970.01.01
                               1/1/1970

       -tartv             Compare tarfiles using tar -tv, and look at the file size
                          If file size is not desired in the comparison, also use -fields 1
       
       -lsl               Useful when comparing previously captured output of 'ls -l'
                          Filters out everything except size and filename
          
       -yaml              Used for comparing two yaml files via YAML::XS and Data::Dumper
       
       -json              Used for comparing two json files via JSON::XS and Data::Dumper

       -perlDump          Useful when comparing previously captured output of Data::Dumper
                          filter out all SCALAR/HASH/ARRAY/REF/GLOB/CODE addresses from output of Dumpvalue,
                          since they change on every execution
                              'SPECS' => HASH(0x9880110)    becomes    'SPECS' => HASH()
                          Also works on Python object dumps:
                              <_sre.SRE_Pattern object at 0x216e600>

       -perlEval          The input file is a perl hashref
                          Print the keys in alphabetical order

      
    Preprocessing options (before filtering):
       -bcpp              Run each input file through bcpp with options:  /home/ckoknat/cs2/linux/bcpp -s -bcl -tbcl -ylcnc

       -perltidy          Run each input file through perltidy with options:  /home/utils/perl-5.8.8/bin/perltidy -l=110 -ce
       
       -externalPreprocessScript <script>          
                          Run each input file through your custom preprocessing script
                          It must take input from STDIN and send output to STDOUT, similar to unix 'sort'
                          Trivial example:
                              -externalPreprocessScript 'sort'
                          
                          Examples for comparing binary files:
                              -e '/usr/bin/xxd'
                              -e '/usr/bin/hexdump -c'
                          Although for the case of comparing binary files,
                              a standalone diff tool may be preferable,
                              for example 'qdiff' by Johannes Overmann & Tong Sun


    Postprocessing options (after filtering):
       -sort              Run Linux 'sort' on each input file

       -uniq              Run Linux 'uniq' on each input file to eliminate duplicated adjacent lines
                          Use with -sort to eliminate all duplicates
       
       -strings           Run Linux 'strings' command on each input file to strip out binary characters

       -fold              Run 'fold' on each input file with default of 105 characters per column
                          Useful for comparing long lines,
                          so that scrolling right is not needed within the GUI

       -foldChars N       Run 'fold' on each input file with N characters per column

       -ppOnly            Stop after creating processed files


    Viewing options:
       -quiet             Do not print to screen

       -verbose           Print names and file sizes of preprocessed temp files, before comparing

       -gui cmd           Instead of using gvimdiff to graphically compare the files, use a different tool
                          For example:
                          -gui gvimdiff
                              Uses gvimdiff as a GUI
                          
                          -gui kompare
                              Uses kompare as a GUI

                          -gui meld
                              Uses meld as a GUI

                          -gui md5sum
                              Prints the m5sum to stdout, after preprocessing
                          
                          -gui ''          
                              This is useful when comparing from a script
                              After running dif, check the return status:
                                  0 = files are equal
                                  1 = files are different
                                  dif a.yml b.yml -gui '' -quiet ; echo $?
                           
                          -gui diff
                              Prints diff to stdout instead of to a GUI

                          -gui 'diff -C 1' | grep -v '^[*-]'
                              Use diff, with the options:
                                  one line of Context above and below the diff
                                  remove the line numbers of the diffs

       -diff              Shortcut for '-gui diff'

    Other options:
       -stdin             Parse input from stdin
       -stdout            Cat all preprocessed files to stdout
                          In this use case, dif can be called on only one file
                          This allows dif to be part of a pipeline
                          Example 1:
                              dif file -stdout <options> | another_script
                          If -stdin is given, then -stdout is assumed
                          Example 2:
                              grep foo bar | dif -stdin <options> | baz | qux

       -gold              When used with one filename (file.extension), assumes that 2nd file will be file.golden.extension
                          When used with multiple filenames (file.extension), it runs dif multiple times, once for each of the pairs
                          This option is useful when doing regressions against golden files

       -dir2 <dir>        For each input file specified, run 'dif' on the file in the current directory
                              against the file in the specified directory
                          For example:
                              dif file1 file2 file3 -dir ..
                          will run:
                              dif file1 ../file1
                              dif file2 ../file2
                              dif file3 ../file3
       
      -listFiles         Print report showing which files match, when using -gold or -dir2
    

    File formats:
        dif will automatically uncompress files from these formats into intermediate files:
            .gz
            .bz2
            .xz
            .zip  (single files only)
           

    Default compare tool:
        The default compare GUI is gvimdiff
        To change this, create the text file ~/.dif.options with one of these content lines:
            gui: gvimdiff
            gui: kompare
            gui: meld
            gui: tkdiff


    For convenience, link to this code from ~/bin
        ln -s dif ~/bin/dif

    

    Perforce version control support:
            Perforce uses # to signify version numbers
    Perforce examples:
            dif file#6 file#7   compares p4 version 6 with p4 version 7
            dif file#6 file#+   compares p4 version 6 with p4 version 7
            dif file#6 file#-   compares p4 version 6 with previous version
            dif file#head #-    compares p4 head version with previous version (shortcut)
            dif file#head       compares p4 head version with local version (shortcut)
            dif file#7          compares p4 version 7 with local version (shortcut)
            dif file#6..#8      compares p4 version 6 with p4 version 7, and then compares 7 with 8
    


# Installation instructions

To install dif and run tests:
* download dif from GitHub
* cd dif/test
* ./dif.t

It should return with 'all tests passed'

Perl versions 5.6.1 through 5.30 have been tested

For convenience, copy 'dif' to your ~/bin directory


To see usage:
* cd ..  (back into dif main directory)
* ./dif


To run dif:
* ./dif file1 file2 <options>
