## dif - a preprocessing front end to meld/gvimdiff/tkdiff/kompare
![Alt text](dif_before_after.png?raw=true "Comparison of  meld  vs  dif with option -comments")

The graphical compare tools meld, gvimdiff, tkdiff, or kompare are used to compare text files on Linux

In many cases, it is difficult and time-consuming to visually compare large files because of formatting differences

For example:
* different versions of code may differ only in comments or whitespace
* log files are often many MB of text, with some "don't care" information such as timestamps or temporary filenames
* json or yaml files may have ordering differences


## Purpose

'dif' preprocesses input text files with a wide variety of options

Afterwards, it runs the Linux tools meld, gvimdiff, tkdiff, or kompare on these intermediate files

'dif' can also be used as part of an automated testing framework against golden files, returning 0 for identical, and 1 for mismatch


## Solutions

#### Problem: differences in whitespace or comments or case cause mismatches
Solution:  Use options -white or -nowhite or -comments or -case

#### Problem: input files are too large for a quick comparison
Solution 1:  Use -head or -tail to only compare the first or last N lines

Solution 2:  Use -start and -stop to specify a section of the file using regexes

#### Problem: files are sorted differently
Solution:  Use -sort

#### Problem: lines are too long to visually compare easily
Solution:  Use -fold to wrap

#### Problem: log files contain dates and times
Solution:   Use -replaceDates

#### Problem: files both need to be filtered using regexes, to strip out certain characters or sequences
Solution 1:  Use -grep <regex> or -ignore <regex> to filter in or out

Solution 2:  Use -search <regex> -replace <regex> to supply one instance of substitution and replacement

Solution 3:  Use -replaceTable <file> to supply a file with many substitution/replacement regexes
       
#### Problem: need to view your changes to a file on Perforce or SVN or GIT
Solution:  'dif file' will show the differences between the head revision and the local file


## Usage examples
* dif file1 file2
* dif file1 file2 -sort
* dif file1 file2 -white -case
* dif file1 file2 file3 -comments
* dif file1 file2 -search 'foo' -replace 'bar'


## Options
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
       
       -noWhite           Remove all whitespace

       -case              Convert files to lowercase before comparing
       
       -split             Splits each line on whitespace
       
       -splitChar 'char'  Splits each line on 'char'
       
       -trim              Trims each line to 105 characters
                          Useful when lines are very long, and the important information is near the beginning
       
       -trimChars N       Trims with specified number of characters, instead of 105
       
       -comments          Remove any comments like // or # or single-line */ /*.  Also removes trailing whitespace

       -grep 'regex'      Only show lines which match the user-specified regex
                          Multiple regexs can be specified, for example:  -grep '(regexA|regexB)'
                          To grep for lines above/below matches, see the help text for option -externalPreprocessScript

       -ignore 'regex'    Ignore any lines which match the user-specified regex
                          This is the opposite of the -grep function
                          
       -start 'regex'     Start comparing file when line matches regex
       
       -stop 'regex'      Stop comparing file when line matches regex
                          The last matching line contains the 'stop' regex

       -stopIgnoreLine    This modifies the 'stop' operation, so that
                          The last matching line does not contain the 'stop' regex

       -start1 -stop1 -start2 -stop2
                          Similar to -start and -stop
                          The '1' and '2' refer the files
                          Enables comparing different sections within the same file, or different sections within different files
                          
                          For example, to compare Perl functions 'add' and 'subtract' within single file:
                              dif a.pm -start1 'sub add' -stop1 '^}' -start2 'sub subtract' -stop '^}'

       -function 'function_name'
                          Compare same  Python def / Perl sub / TCL proc  function from two source files
                          Internally, this piggybacks on the -start -stop functionality

       -functionSort
                          Useful when Python/Perl/TCL function have been moved within a file
                          This option preprocesses each file, so that the function definitions
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

       -tartv             Compare tarfiles using tar -tv, and compare the names and file sizes
                          If file sizes are not desired in the comparison (names only), also use -fields 1
       
       -lsl               Useful when comparing previously captured output of 'ls -l'
                          Filters out everything except names and file sizes
          
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

                          Example using grep to show 2 lines above and below lines matching 'opt'
                              -ext 'grep -C 2 opt'
                          
                          Examples for comparing binary files:
                              -ext '/usr/bin/xxd'
                              -ext '/usr/bin/hexdump -c'
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

       -gui cmd           Instead of using meld to graphically compare the files, use a different tool
                          This supports any tool which has command line usage similar to gvimdiff
                          i.e. 'gvimdiff file1 file2'.  This has been tested on meld, gvimdiff, tkdiff, and kompare
                          (and likely works with diffmerge, diffuse, kdiff, kdiff3, wdiff, xxdiff, colordiff, beyond compare, etc)
                          Examples:

                          -gui gvimdiff
                              Uses gvimdiff as a GUI
                          
                          -gui tkdiff
                              Uses tkdiff as a GUI

                          -gui kompare
                              Uses kompare as a GUI

                          -gui meld
                              Uses meld as a GUI
                              Note that meld does not display line numbers by default
                              Meld / Preferences / Editor / Display / Show line numbers
                              If the box is greyed out, install python-gtksourceview2

                          -gui md5sum
                              Prints the m5sum to stdout, after preprocessing
                          
                          -gui ''          
                              This is useful when comparing from a script
                              in an automated process such as regression testing
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
       -stdin             Parse input from stdin and send output to stdout
                          For example:
                              grep foo bar | dif -stdin <options> | baz | qux

       -stdout            Cat all preprocessed files to stdout
                          In this use case, dif could be called on only one file
                          This allows dif to be part of a pipeline
                          For example:
                              dif file -stdout <options> | another_script
                          If -stdin is given, then -stdout is assumed

       -gold              When used with one filename (file or file.extension),
                          assumes that 1st file will be (file.golden or file.golden.extension)
                          
                          For example:
                              dif file1 -gold
                          will run:
                              dif file1.golden file1.csv
                          
                          For example:
                              dif file1.csv -gold
                          will run:
                              dif file1.csv.golden file1.csv
                          
                          When used with multiple filenames
                          it runs dif multiple times, once for each of the pairs
                          This option is useful when doing regressions against golden files
                          
                          For example:
                              dif file1 file2.csv -gold
                          will run:
                              dif file1.golden file1
                              dif file2.csv.golden file2.csv

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
        The default compare GUI is meld
        To change this, create the text file ~/.dif.defaults with one of these content lines:
            gui: gvimdiff
            gui: tkdiff
            gui: kompare
            gui: meld
            gui: tkdiff
        You may also want to change the default (uncompressed) file size limit, before gvimdiff takes over from kompare/meld
        The default is 2000000 bytes
            meldSizeLimit: 1000000


    For convenience, link to this code from ~/bin
        ln -s /path/dif ~/bin/dif


    Perforce or SVN version control support:
            Perforce uses '#' to signify version numbers.  dif borrows the same notation for SVN
    Perforce or SVN examples:
            dif file              compares head version with local version (shortcut)
            dif file#head         compares head version with local version (shortcut)
            dif file file#head    compares head version with local version
            dif file#head #-      compares head version with previous version (shortcut)
            dif file#7            compares version 7 with local version (shortcut)
            dif file#6 file#7     compares version 6 with p4 version 7
            dif file#6 file#+     compares version 6 with p4 version 7
            dif file#6 file#-     compares version 6 with p4 version 5
            dif file#6..#8        compares version 6 with p4 version 7, and then compares 7 with 8
    Git example:
            dif file              compares committed version to local version


## Installation

To install dif and run tests:
* download dif from GitHub
* cd dif/test
* ./dif.t

This will run dif on the example* unit tests
It should return with 'all tests passed'

Perl versions 5.6.1 through 5.30 have been tested

For convenience, copy 'dif' to your ~/bin directory


To see usage:
* cd ..  (back into dif main directory)
* ./dif


To run dif:
* ./dif file1 file2 <options>
