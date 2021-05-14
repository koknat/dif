#!/usr/bin/perl
# #!/home/utils/perl-5.8.8/bin/perl
##!/home/utils/perl-5.26/5.26.2-058/bin/perl
##!/home/utils/perl5/perlbrew/perls/5.26.2-060/bin/perl
use warnings;
#use warnings FATAL => qw( all );
use strict;
use File::Basename qw(basename dirname);
use File::Temp qw(tempdir);
use Getopt::Long;
use Test::More qw( no_plan );  # 5.8.1 or newer
$SIG{__WARN__} = sub { die @_ };  # die instead of produce warnings
sub say { print @_, "\n" };
sub D{say "Debug::Statements has been disabled to improve performance"}; sub d{}; sub d2{}; sub ls{};
#use lib "/home/ate/scripts/regression";
#use Debug::Statements ":all";

# This should be run from the dif/test directory
# perl dif.t

# Parse options
my %opt;
my $d = 0;
GetOptions( \%opt, 'test|t=s', 'extraTests', 'modernPerl', 'd' => sub { $d = 1 }, 'die' ) or die $!;
my $t = defined $opt{test} ? $opt{test} : 'ALL';
die "ERROR:  Did not expect '@ARGV'.  Did you forget '-t' ? " if @ARGV;

my $script = 'dif';
my $dif;  # dif executable
my $testDir;  # dif/test directory
chomp( my $pwd = `pwd` );
if ( $pwd =~ m{/$script(-master.*)?/test$} ) {
    $dif = dirname($pwd) . "/$script";
    $testDir = "$pwd";
} elsif ( $pwd =~ m{/$script(-master.*)?$} ) {
    $dif = "$pwd/$script";
    $testDir = "$pwd/test";
} else {
    die "ERROR:  This must be run from the dif/test directory!\n";
}
#say "\$pwd = $pwd";
#say "\$dif = $dif";
#say "\$testDir = $testDir";
die "ERROR:  executable not found:  $dif" unless -e $dif;
chomp( my $whoami = `whoami` );
if ( $whoami eq 'ckoknat' and ! $opt{modernPerl} ) {
    $dif = "/home/utils/perl-5.8.8/bin/perl $dif";
}

my $pass = 0;
my $fail = 256;
my $err = 512;
print "\n\n\n\n";
my $globaltmpdir = tempdir( '/tmp/d_XXXX', CLEANUP => 1 );

if ( runtests('white') ) {
    testcmd( $dif, "case01a_hosts.txt case01a_hosts.txt",             "",         $pass );
    testcmd( $dif, "case01a_hosts.txt case01b_hosts_spaces.txt",      "",         $fail );
    testcmd( $dif, "case01a_hosts.txt case01b_hosts_spaces.txt",      "-white",   $pass );
    testcmd( $dif, "case01a_hosts.txt.link case01b_hosts_spaces.txt", "-white",   $pass );
    testcmd( $dif, "case01a_hosts.txt case01c_hosts_blank_lines.txt", "",         $fail );
    testcmd( $dif, "case01a_hosts.txt case01c_hosts_blank_lines.txt", "-white",   $pass );
    testcmd( $dif, "case01a_hosts.txt case01c_hosts_blank_lines.txt", "-w",       $pass );
    testcmd( $dif, "case01a_hosts.txt case01g_hosts_nospaces.txt",    "",         $fail );
    testcmd( $dif, "case01a_hosts.txt case01g_hosts_nospaces.txt",    "-nowhite", $pass );
}

if ( runtests('head') ) {
    my ($cmd, $result);
    $result = getNumLines("$dif $testDir/case20a.txt -stdout -headlines 6 -q");
    d '$cmd $result';
    is($result, 6, "headLines 6 wc = 6");
    
    $result = getNumLines("$dif $testDir/case20a.txt -stdout -headlines '-6' -q");
    d '$cmd $result';
    is($result, 4, "headLines -6 wc = 4");

    testcmd( $dif, "case01a_hosts.txt case01d_hosts_missingline.txt", "", $fail );
    testcmd( $dif, "case01a_hosts.txt case01d_hosts_missingline.txt", "-headlines 3", $pass );
}
if ( runtests('tail') ) {
    my ($cmd, $result);

    # case20a.txt contains 10 lines
    $result = getNumLines("$dif $testDir/case20a.txt -stdout -taillines 3 -q");
    d '$cmd $result';
    is($result, 3, "tailLines 3 wc = 3");
    
    $result = getNumLines("$dif $testDir/case20a.txt -stdout -taillines '-3' -q");
    d '$cmd $result';
    is($result, 7, "tailLines -3 wc = 7");
    
    $result = getNumLines("$dif $testDir/case20a.txt -stdout -headLines 7 -tailLines 5 -q");
    d '$cmd $result';
    is($result, 5, "headLines 7 tailLines 5 wc = 5");  # skips first 2 lines, keeps 5, skips final 3
    
    $result = getNumLines("$dif $testDir/case20a.txt -stdout -headLines '-3' -tailLines '-2' -q");
    d '$cmd $result';
    is($result, 5, "headLines -3 tailLines -2 wc = 5");  # skips first 2 lines, and final 3

    testcmd( $dif, "case01a_hosts.txt case01j_hosts_uppercase.txt", "", $fail );
    testcmd( $dif, "case01a_hosts.txt case01j_hosts_uppercase.txt", "-taillines 1", $pass );
}

if ( runtests('case') ) {
    testcmd( $dif, "case01a_hosts.txt case01j_hosts_uppercase.txt", "",      $fail );
    testcmd( $dif, "case01a_hosts.txt case01j_hosts_uppercase.txt", "-case", $pass );
}

if ( runtests('comments') ) {
    testcmd( $dif, "case01a_hosts.txt case01f_hosts_comments.txt", "",          $fail );
    testcmd( $dif, "case01a_hosts.txt case01f_hosts_comments.txt", "-comments", $pass );
    testcmd( $dif, "case01a_hosts.txt case01k_hosts_multiline_comments.txt", "-comments", $pass );
    # Compare 3 files at once:
    # dif case01a_hosts.txt case01f_hosts_comments.txt case01e_hosts_scrambled.txt
    # dif case01a_hosts.txt case01f_hosts_comments.txt case01e_hosts_scrambled.txt -comment
}

if ( runtests('grep') ) {
    testcmd( $dif, "case01a_hosts.txt case01d_hosts_missingline.txt", "",                $fail );
    testcmd( $dif, "case01a_hosts.txt case01a_hosts.txt",             "-grep 'network'", $pass );
    testcmd( $dif, "case01a_hosts.txt case01d_hosts_missingline.txt", "-grep 'network'", $pass );
}

if ( runtests('ignore') ) {
    testcmd( $dif, "case01a_hosts.txt case01a_hosts.txt",             "-ignore 'localhost6'", $pass );
    testcmd( $dif, "case01a_hosts.txt case01d_hosts_missingline.txt", "-ignore 'localhost6'", $pass );
}

if ( runtests('sort_strings') ) {
    testcmd( $dif, "case01a_hosts.txt case01e_hosts_scrambled.txt", "",               $fail );
    testcmd( $dif, "case01a_hosts.txt case01a_hosts.txt",           "-sort",          $pass );
    testcmd( $dif, "case01a_hosts.txt case01e_hosts_scrambled.txt", "-sort",          $pass );
    testcmd( $dif, "case02a.bin case02a.bin",                     "",               $pass );
    testcmd( $dif, "case02a.bin case02a.bin",                     "-strings",       $pass );
    # The next test has $fail on Ubuntu, so commenting it out
    #testcmd( $dif, "case02a.bin case02b_scrambled.bin",           "",               $err );    # Could not parse diff output
    testcmd( $dif, "case02a.bin case02b_scrambled.bin",           "-strings",       $fail );
    testcmd( $dif, "case02a.bin case02b_scrambled.bin",           "-sort",          $pass );
    testcmd( $dif, "case02a.bin case02b_scrambled.bin",           "-sort -strings", $pass );
    #testcmd( $dif, "case02a.bin case02c_longer.bin",              "",               $err );    # Could not parse diff output
    testcmd( $dif, "case02a.bin case02c_longer.bin",              "-strings",       $fail );
    #testcmd( $dif, "case02a.bin case02c_longer.bin",              "-sort",          $err );
    #testcmd( $dif, "case02a.bin case02c_longer.bin",              "-sort -strings", $fail );   # Could not parse diff output
}

if ( runtests('uniq') ) {
    testcmd( $dif, "case01a_hosts.txt case01a_hosts.txt",         "-uniq",              $pass );
    testcmd( $dif, "case01a_hosts.txt case01i_hosts_doubles.txt", "",                   $fail );
    testcmd( $dif, "case01a_hosts.txt case01i_hosts_doubles.txt", "-uniq",              $fail );
    testcmd( $dif, "case01a_hosts.txt case01i_hosts_doubles.txt", "-uniq -sort",        $pass );
}

if ( runtests('fold') ) {
    testcmd( $dif, "case01a_hosts.txt case01a_hosts.txt",             "-fold",          $pass );
    testcmd( $dif, "case01a_hosts.txt case01d_hosts_missingline.txt", "-fold",          $fail );
    testcmd( $dif, "case01a_hosts.txt case01a_hosts.txt",             "-foldchars 10",  $pass );
    testcmd( $dif, "case01a_hosts.txt case01d_hosts_missingline.txt", "-foldchars 10",  $fail );
}

if ( runtests('split') ) {
    testcmd( $dif, "case01a_hosts.txt case01a_hosts.txt",             "-split",          $pass );
    testcmd( $dif, "case01a_hosts.txt case01d_hosts_missingline.txt", "-split",          $fail );
    testcmd( $dif, "case01a_hosts.txt case01a_hosts.txt",             "-splitchar '.'",  $pass );
    testcmd( $dif, "case01a_hosts.txt case01d_hosts_missingline.txt", "-splitchar '.'",  $fail );
}

if ( runtests('round') ) {
    testcmd( $dif, "case16a_round.csv case16b_round.csv",             "",                $fail );
    testcmd( $dif, "case16a_round.csv case16b_round.csv",             "-round '%0.2f'",  $pass );
}

if ( runtests('trim') ) {
    # The case01k_hosts_trimmed.txt looks odd since this script considers each tab to be one character, but vim thinks they are 4 or 8
    testcmd( $dif, "case01a_hosts.txt case01k_hosts_trimmed.txt",     "-trimchars 40",   $pass );
}

if ( runtests('fields') ) {
    testcmd( $dif, "case04a_lsl.txt case04b_lsl.txt", "-fields 5,6,7", $fail );
    testcmd( $dif, "case04a_lsl.txt case04b_lsl.txt", "-fields 4,8", $pass );
    testcmd( $dif, "case04a_lsl.txt case04b_lsl.txt", "-fields 5,6,7 -fieldSeparator '\\s+'", $fail );
    testcmd( $dif, "case04a_lsl.txt case04b_lsl.txt", "-fields 4,8 -fieldSeparator '\\s+'", $pass );
    testcmd( $dif, "case08a.csv case08b.csv", "", $fail );
    testcmd( $dif, "case08a.csv case08b.csv.gz", "-fields 1", $fail );
    testcmd( $dif, "case08a.csv case08b.csv.gz", "-fields 2", $pass );
    testcmd( $dif, "case08a.csv case08b.csv.gz", "-fields 1 -fieldSeparator ','", $fail );
    testcmd( $dif, "case08a.csv case08b.csv.gz", "-fields 2 -fieldSeparator ','", $pass );
    testcmd( $dif, "case08a.csv case08c.csv", "", $fail );
    testcmd( $dif, "case08a.csv case08c.csv", "-fields -1", $pass );
    testcmd( $dif, "case08a.csv case08b.csv.gz", "-fields not0,1,3+", $pass );
    # -fieldJustify
    testcmd( $dif, "case08c.csv case08d.csv", "", $fail );
    testcmd( $dif, "case08c.csv case08d.csv", "-fieldJustify", $pass );
}

if ( runtests('start_stop') ) {
    my ($options, $cmd, $result);

    $options = "-start '^def offset' -stop '^\\s*\$'";
    $result = getNumLines("$dif $testDir/case12_start_stop.py -stdout $options -q");
    d '$cmd $result';
    is($result, 5, "start_stop -start and -stop");

    $options = "-start '^def offset'";
    $result = getNumLines("$dif $testDir/case12_start_stop.py -stdout $options -q");
    d '$cmd $result';
    is($result, 23, "start_stop -start without -stop");
    
    $options = "-stop '^\\s*\$'";
    $result = getNumLines("$dif $testDir/case12_start_stop.py -stdout $options -q");
    d '$cmd $result';
    is($result, 3, "start_stop -stop without -start");

    $options = "-start '^def line^^display^^world' -stop '^\\s*\$'";
    $result = getNumLines("$dif $testDir/case12_start_stop.py -stdout $options -q");
    d '$cmd $result';
    is($result, 2, "start_stop -start with 3 matches needed");
    
    $options = "-start '^def' -stop '^\\s*\$' -startMultiple";
    $result = getNumLines("$dif $testDir/case12_start_stop.py -stdout $options -q");
    d '$cmd $result';
    is($result, 22, "start_stop -startMultiple");

    $options = "-start '^def offset' -stop '^\\s*\$' -startIgnoreFirstLine";
    $result = getNumLines("$dif $testDir/case12_start_stop.py -stdout $options -q");
    d '$cmd $result';
    is($result, 4, "start_stop -startIgnoreFirstLine");
    
    $options = "-start '^def offset' -stop '^\\s*\$' -startIgnoreFirstLine -stopIgnoreLastLine";
    $result = getNumLines("$dif $testDir/case12_start_stop.py -stdout $options -q");
    d '$cmd $result';
    is($result, 3, "start_stop -startIgnoreFirstLine -stopIgnoreLastLine");
}

if ( runtests('start1_stop1_start2_stop2') ) {
    # -stopIgnoreLastLine is needed here because Python has no '^}' to delimit def blocks
    testcmd( $dif, "case15a.py case15b.py", "-start1 '^def factor' -stop1 '^def ' -start2 '^def factor' -stop2 '^def ' -stopIgnoreLastLine", $pass );
}

if ( runtests('search_replace') ) {
    testcmd( $dif, "case01a_hosts.txt case01h_hosts_misspelling.txt", "",                                              $fail );
    testcmd( $dif, "case01a_hosts.txt case01a_hosts.txt",             "-search 'HOST' -replace 'host'",                $pass );
    testcmd( $dif, "case01a_hosts.txt case01h_hosts_misspelling.txt", "-search 'HOST' -replace 'host'",                $pass );
    testcmd( $dif, "case18a.asm case18b.asm", "-search '\\s*(;.*)?\$' -replace ''",                                    $pass );
}

if ( runtests('replaceDates') ) {
    testcmd( $dif, "case06a_replaceDates.txt case06b_replaceDates.txt", "", $fail );
    testcmd( $dif, "case06a_replaceDates.txt case06b_replaceDates.txt", "-replaceDates", $pass );
    testcmd( $dif, "case06c_replaceDates_lsl.txt case06d_replaceDates_lsl.txt", "", $fail );
    testcmd( $dif, "case06c_replaceDates_lsl.txt case06d_replaceDates_lsl.txt", "-replaceDates", $pass );
}

if ( runtests('replaceTable') ) {
    testcmd( $dif, "case01a_hosts.txt case01h_hosts_misspelling.txt", "-replaceTable $testDir/case03_replaceTable", $pass );
}

if ( runtests('stdin_stdout') ) {
    my ($cmd, $result);

    $result = getNumLines("cat $testDir/case06a_replaceDates.txt | $dif -stdin -stdout -replaceDates -q | grep 'date'");
    d '$cmd $result';
    is($result, 16, "stdin__stdout");
    
    my $tmpfile = "$globaltmpdir/dif_out.txt";
    $result = getNumLines("cat $testDir/case06a_replaceDates.txt | $dif -stdin -out $tmpfile -replaceDates -q ; grep 'date' $tmpfile");
    $result =~ s/^\s*//;
    d '$cmd $result';
    is($result, 16, "stdin__stdout out");

    # Test that -replaceDates works in conjunction with -search -replace
    $result = getNumLines("cat $testDir/case06a_replaceDates.txt | $dif -stdin -stdout -replaceDates -search 'A' -replace 'AA' -q | grep 'date'");
    d '$cmd $result';
    is($result, 16, "stdin__stdout -replaceDates in conjunction with -search -replace");
    $result = getNumLines("cat $testDir/case06a_replaceDates.txt | $dif -stdin -stdout -replaceDates -search 'foo' -replace 'bar' -q | grep 'bar'");
    d '$cmd $result';
    is($result, 1, "stdin__stdout -replaceDates in conjunction with -search -replace");
}

if ( runtests('quiet') ) {
    test_cmdquiet( $dif, "case01a_hosts.txt case01a_hosts.txt", "",       $fail );
    # The next test will fail if a different user environment causes messages to be written to screen
    # For example, if a system doesn't have meld installed, and the message isn't guarded with 'unless $opt{quiet}'
    test_cmdquiet( $dif, "case01a_hosts.txt case01a_hosts.txt", "-quiet", $pass );
}

if ( runtests('paragraphSort') ) {
    testcmd( $dif, "case07a_perlSub.pm case07c_paragraphSort.pm", "-paragraphSort", $pass );
}

if ( runtests('tartv') ) {
    #testcmd( $dif, "case10a_tar.tar.gz case10b_tar.tar.gz",             "",         $fail );          # same 3 files, but it fails since the name of the file is inside the .tar.gz
    testcmd( $dif, "case10a_tar.tar.gz case10b_tar.tar.gz",             "-tartv",            $pass );  # same 3 files
    testcmd( $dif, "case10a_tar.tar.gz case10c_tar.tar.gz",             "-tartv",            $fail );  # removed 1st file, additional 4th file
    testcmd( $dif, "case10a_tar.tar.gz case10c_tar.tar.gz",             "-tartv -fields 1",  $fail );  # removed 1st file, additional 4th file, only print the filenames
    # tar -cvf case10a_tar.tar case10a_tar ; tar -cvf case10b_tar.tar case10b_tar ; tar -cvf case10c_tar.tar case10c_tar ; gzip case10*_tar.tar
}

if ( runtests('gz') ) {
    testcmd( $dif, "case01a_hosts.txt.gz case01e_hosts_scrambled.txt.gz",             "",      $fail );
    testcmd( $dif, "case01e_hosts_scrambled.txt.gz case01e_hosts_scrambled.txt.gz",   "-sort", $pass );
}

if ( runtests('zip')  and  whichCommand('unzip') ) {
    testcmd( $dif, "case01a_hosts.txt.gz case01a_hosts.txt.zip",            "",      $pass );
    testcmd( $dif, "case01a_hosts.txt.gz case01e_hosts_scrambled.txt.zip",  "",      $fail );
    testcmd( $dif, "case01a_hosts.txt.gz case01e_hosts_scrambled.txt.zip",  "-sort", $pass );
}

if ( runtests('Z')  and  whichCommand('uncompress') ) {
    testcmd( $dif, "case01a_hosts.txt.gz case01a_hosts.txt.Z",            "",      $pass );
    testcmd( $dif, "case01a_hosts.txt.gz case01e_hosts_scrambled.txt.Z",  "",      $fail );
    testcmd( $dif, "case01a_hosts.txt.gz case01e_hosts_scrambled.txt.Z",  "-sort", $pass );
}

if ( runtests('bz')  and  whichCommand('bzcat') ) {
    testcmd( $dif, "case01a_hosts.txt.gz case01a_hosts.txt.bz2",            "",      $pass );
    testcmd( $dif, "case01a_hosts.txt.gz case01e_hosts_scrambled.txt.bz2",  "",      $fail );
    testcmd( $dif, "case01a_hosts.txt.gz case01e_hosts_scrambled.txt.bz2",  "-sort", $pass );
}

if ( runtests('xz')  and  whichCommand('xzcat') ) {
    testcmd( $dif, "case01a_hosts.txt.gz case01a_hosts.txt.xz",            "",      $pass );
    testcmd( $dif, "case01a_hosts.txt.gz case01e_hosts_scrambled.txt.xz",  "",      $fail );
    testcmd( $dif, "case01a_hosts.txt.gz case01e_hosts_scrambled.txt.xz",  "-sort", $pass );
}

if ( runtests('report') ) {
    # Simply list files with sizes and md5sums
    chdir("$testDir");
    my ($cmd, $result);

    $cmd = "$dif dirA/* -report";
    chomp($result = `$cmd`);
    d '$cmd $result';
    like($result, qr{190\s+7\s+}, 'report');  # Did not include hash value since this can change based on the hashing algorithm

    $cmd = "$dif dirA/* -report -fast";
    chomp($result = `$cmd`);
    d '$cmd $result';
    like($result, qr{190}, 'report');
    
    $cmd = "$dif dirA -report -fast";
    chomp($result = `$cmd`);
    d '$cmd $result';
    like($result, qr{190}, 'report');
    
    chdir("$pwd");
    
    $result = getNumLines("$dif $testDir -report -stdout | grep DOES_NOT_EXIST");
    d '$cmd $result';
    is($result, 0, "report with one file should not complain of files which do not exist");
}

if ( runtests('dirs') ) {
    # Compare two directories.  -report is used for facilitating testing
    # MAIN    dirA         dirB
    # 01a     normal       -comments
    # 01b     (missing)    -white
    # 01c     normal       (missing)
    chdir("$testDir");
    testcmd( $dif, "dirA dirAcopy", "", $pass );
    testcmd( $dif, "dirA/ dirAcopy/", "", $pass );
    testcmd( $dif, "dirA dirAcopy", "-report", $pass );
    testcmd( $dif, "../test/dirA ../test/dirAcopy", "-report", $pass );
    testcmd( $dif, "dirAlink dirAcopy", "-report", $pass );
    testcmd( $dif, "dirA dirB",     "-report", $fail );
    testcmd( $dif, "../test/dirA ../test/dirB",     "-report", $fail );
    testcmd( $dif, "dirA dirB",     "-report -excludeFiles '01[bc]' -comments", $pass );
    testcmd( $dif, "dirA dirB",     "-report -includeFiles '01a' -comments", $pass );
    testcmd( $dif, "", "-includeFiles 'case01a' dirA dirB -report",   $fail );
    testcmd( $dif, "", "-includeFiles 'case01a' dirA dirB -report -comments -white",   $pass );
    chdir("$testDir/dirA");
    testcmd( $dif, "", "-includeFiles 'case01[ac]' -dir2 ../dirA -report",   $pass );
    testcmd( $dif, "", "-includeFiles 'case01[ac]' -dir2 ../dirB -report",   $fail );  # case01c does not exist in dirB
    testcmd( $dif, "", "-includeFiles 'case01a' -dir2 ../dirB -report",   $fail );
    testcmd( $dif, "", "-includeFiles 'case01a' -dir2 ../dirB -report -comments -white",   $pass );
    chdir("$pwd");
}

if ( runtests('dir2') ) {
    testcmd( $dif, "case01a_hosts.txt.gz dirA/case01a_hosts.txt.gz",                                 "",                                 $pass );
    testcmd( $dif, "case01a_hosts.txt.gz dirB/case01a_hosts.txt.gz",                                 "",                                 $fail );
    testcmd( $dif, "case01a_hosts.txt.gz",                                                        "-dir2 $testDir/dirA",              $pass );
    testcmd( $dif, "case01a_hosts.txt.gz",                                                        "-dir2 $testDir/dirB",              $fail );
    testcmd( $dif, "case01a_hosts.txt.gz",                                                        "-dir2 $testDir/dirB -comments",    $pass );
    testcmd( $dif, "case01b_hosts_spaces.txt",                                                 "-dir2 $testDir/dirB -report -white",   $pass );
    testcmd( $dif, "case01a_hosts.txt.gz case01b_hosts_spaces.txt",                               "-dir2 $testDir/dirB -report",   $fail );
    testcmd( $dif, "case01a_hosts.txt.gz case01b_hosts_spaces.txt",                               "-dir2 $testDir/dirB -report -comments -white",   $pass );
    testcmd( $dif, "case01a_hosts.txt case01b_hosts_spaces.txt case01c_hosts_blank_lines.txt", "-dir2 $testDir/dirB -report",   $fail );  # case01c does not exist in dirB
}

if ( runtests('gold') ) {
    testcmd( $dif, "case01a_hosts.txt",                    "-gold",         $pass );
    testcmd( $dif, "case01a_hosts.golden.txt",             "-gold",         $pass );
    testcmd( $dif, "case01b_hosts_spaces.txt",             "-gold",         $fail );
    testcmd( $dif, "case01b_hosts_spaces.golden.txt",      "-gold",         $fail );
}

if ( runtests('lsl') ) {
    testcmd( $dif, "case04a_lsl.txt case04a_lsl.txt", "",     $pass );
    testcmd( $dif, "case04a_lsl.txt case04b_lsl.txt", "",     $fail );
    testcmd( $dif, "case04a_lsl.txt case04a_lsl.txt", "-lsl", $pass );
    testcmd( $dif, "case04a_lsl.txt case04b_lsl.txt", "-lsl", $pass );
    testcmd( $dif, "case04b_lsl.txt case04c_lsl.txt", "", $fail );
    testcmd( $dif, "case04b_lsl.txt case04c_lsl.txt", "-basenames", $pass );
}


if ( runtests('perleval') ) {
    testcmd( $dif, "case11a_perlhash case11b_perlhash",             "",                  $fail );
    testcmd( $dif, "case11a_perlhash case11b_perlhash",             "-perleval",         $pass );
    testcmd( $dif, "case11a_perlhash case11c_perlhash",             "-perleval",         $fail );
}

if ( runtests('function') ) {
    my ($cmd, $result);

    $result = getNumLines("$dif $testDir/case13b.pl -stdout -function a -q");
    d '$cmd $result';
    is($result, 4, "function a .pl wc");
    
    $result = getNumLines("$dif $testDir/case15b.py -stdout -function quickSort -q");
    d '$cmd $result';
    is($result, 15, "function quickSort .py wc");
    
    $result = getNumLines("$dif $testDir/case17b.c -stdout -function sieve -q");
    d '$cmd $result';
    is($result, 14, "function sieve .c wc");
    
    $result = getNumLines("$dif $testDir/case19b.js -stdout -function isPrime -q");
    d '$cmd $result';
    is($result, 17, "function isPrime .js wc");

    # a vs b = changes within a function
    # b vs c = sorting
    testcmd( $dif, "case13a.pl case13b.pl", "-function a", $fail );
    testcmd( $dif, "case13b.pl case13c.pl", "-function a", $pass );

    testcmd( $dif, "case15a.py case15b.py", "-function quickSort", $fail );
    testcmd( $dif, "case15b.py case15c.py", "-function quickSort", $pass );
    
    testcmd( $dif, "case17a.c case17b.c", "-function sieve", $fail );
    testcmd( $dif, "case17b.c case17b.c", "-function sieve", $pass );
    
    testcmd( $dif, "case19a.js case19b.js", "-function isPrime", $fail );
    testcmd( $dif, "case19b.js case19b.js", "-function isPrime", $pass );
}

if ( runtests('functionSort') ) {
    testcmd( $dif, "case13b.pl case13c.pl", "", $fail );
    testcmd( $dif, "case13b.pl case13c.pl", "-functionSort", $pass );

    testcmd( $dif, "case15b.py case15c.py", "", $fail );
    testcmd( $dif, "case15b.py case15c.py", "-functionSort", $pass );
    testcmd( $dif, "case15a.py case15c.py", "-functionSort", $fail );
    
    testcmd( $dif, "case17b.c case17c.c", "", $fail );
    testcmd( $dif, "case17b.c case17c.c", "-functionSort", $pass );
    testcmd( $dif, "case17a.c case17b.c", "-functionSort", $fail );
    
    testcmd( $dif, "case19b.js case19c.js", "", $fail );
    testcmd( $dif, "case19b.js case19c.js", "-functionSort", $pass );
    testcmd( $dif, "case19a.js case19b.js", "-functionSort", $fail );
}

if ( runtests('ext') ) {
    testcmd( $dif, "case01a_hosts.txt case01e_hosts_scrambled.txt",    "",                                    $fail );
    testcmd( $dif, "case01a_hosts.txt case01a_hosts.txt",              "-externalPreprocessScript sort",          $pass );  # trivial
    testcmd( $dif, "case01a_hosts.txt case01e_hosts_scrambled.txt",    "-externalPreprocessScript sort",          $pass );
    testcmd( $dif, "case01a_hosts.txt case01e_hosts_scrambled.txt",    "-externalPreprocessScript /usr/bin/nonexisting",          $fail );
    testcmd( $dif, "case01a_hosts.txt.gz case01e_hosts_scrambled.txt", "-externalPreprocessScript sort",          $pass );  # handle .gz
}

if ( runtests('bin')  and  ( -f '/usr/bin/xxd' or -f '/usr/bin/hexdump' ) ) {
    testcmd( $dif, "case01a_hosts.txt case01a_hosts.txt",              "-bin",          $pass );  # trivial
    testcmd( $dif, "case01a_hosts.txt case01e_hosts_scrambled.txt",    "-bin",          $fail );
}

if ( runtests('bcpp')  and  whichCommand('bcpp') ) {
    testcmd( $dif, "case09a.c case09b.c", "", $fail );
    testcmd( $dif, "case09a.c case09b.c", "-bcpp", $pass );
}

if ( runtests('tree')  and  whichCommand('tree') ) {
    testcmd( $dif, "dirA dirAcopy", "-tree -ignore dir", $pass );  # -ignore dir is needed for the comparison because the directory name is listed in the header
    testcmd( $dif, "dirA dirB",     "-tree -ignore dir", $fail );
}

if ( runtests('dos2unix')  and  whichCommand('dos2unix') ) {
    testcmd( $dif, "case01a_hosts.txt case01l_hosts_dos.txt",      "",            $fail );
    testcmd( $dif, "case01a_hosts.txt case01l_hosts_dos.txt",      "-dos2unix",   $pass );
}

eval 'use YAML::XS ()';
if ($@) {
    if ( $whoami eq 'ckoknat' and ! defined $opt{test} ) {
        say "WARNING:  Not running tests 'yaml' and 'externalPreprocessScript";
    }
} else {
    if ( runtests('yaml') ) {
        testcmd( $dif, "case14a.yml case14b.yml", "",            $fail );
        testcmd( $dif, "case14a.yml case14b.yml", "-yaml",       $pass );
        testcmd( $dif, "case14a.yml case14a.yml.gz", "",         $pass );
        testcmd( $dif, "case14a.yml case14c.yml", "-yaml -case", $pass );
        testcmd( $dif, "case14a.yml.gz case14c.yml.gz", "-yaml -case", $pass );
        testcmd( $dif, "case14a.yml.gz case14c.yml.gz", "-yaml -removeDictKeys '(eggs|spam)'", $pass );
    }
    if ( runtests('externalPreprocessScript') ) {
        # May fail because of YAML library dependency
        testcmd( $dif, "case14a.yml case14b.yml", "",            $fail );
        testcmd( $dif, "case14a.yml case14b.yml", "-externalPreprocessScript $testDir/case14_externalPreprocessScript.pl",       $pass );
        testcmd( $dif, "case14a.yml case14c.yml", "-externalPreprocessScript $testDir/case14_externalPreprocessScript.pl",       $pass );
    }
}

eval 'use JSON::XS ()';
if ($@) {
    if ( $whoami eq 'ckoknat' and ! defined $opt{test} ) {
        say "WARNING:  Not running tests 'yaml' and 'externalPreprocessScript'";
    }
} else {
    if ( runtests('json') ) {
        testcmd( $dif, "case14a.json case14b.json", "",            $fail );
        testcmd( $dif, "case14a.json case14b.json", "-json",       $pass );
        testcmd( $dif, "case14a.json case14a.json.gz", "",         $pass );
        testcmd( $dif, "case14a.json case14c.json", "-json -case", $pass );
        testcmd( $dif, "case14a.json.gz case14c.json.gz", "-json -case", $pass );
        testcmd( $dif, "case14a.json.gz case14c.json.gz", "-json -removeDictKeys '(eggs|spam)'", $pass );
    }
}

eval 'use Spreadsheet::BasicRead ()  ;  use Spreadsheet::ParseExcel ()';
if ($@) {
    if ( $whoami eq 'ckoknat' and ! defined $opt{test} ) {
        say "WARNING:  Not running test 'xls'";
    }
} else {
    if ( runtests('xls') ) {
        testcmd( $dif, "case08a.xls case08b.xls", "", $pass );  # 08b has bold text, but same values
        testcmd( $dif, "case08a.xls case08c.xls", "", $fail );  # 08c has different values
    }
}

eval 'use Spreadsheet::Read ();  use Spreadsheet::ParseODS ()';
if ($@) {
    if ( $whoami eq 'ckoknat' and ! defined $opt{test} ) {
        say "WARNING:  Not running test 'ods'";
    }
} else {
    if ( runtests('ods') ) {
        testcmd( $dif, "case08a.ods case08b.ods", "", $pass );  # 08b has bold text, but same values
        testcmd( $dif, "case08a.ods case08c.ods", "", $fail );  # 08c has different values
    }
}

eval 'use CAM::PDF ()';
if ($@) {
    if ( $whoami eq 'ckoknat' and ! defined $opt{test} ) {
        say "WARNING:  Not running test 'pdf'";
    }
} else {
    if ( runtests('pdf') ) {
        testcmd( $dif, "case01a_hosts.pdf case01e_hosts_scrambled.pdf", "", $fail );
        testcmd( $dif, "case01a_hosts.pdf case01e_hosts_scrambled.pdf", "-sort", $pass );
    }
}


if ( $opt{extraTests}  or  -d "/home/ckoknat" ) {
    unless ( $opt{test} ) {
        say "\n\n***********************************************************************************************";
        say "* Running additional tests, which may fail if there are missing executables or Perl libraries *";
        say "***********************************************************************************************";
    }

    if ( runtests('perltidy') ) {
        testcmd( $dif, "case05a_pl.txt case05a_pl.txt.tdy", "",          $fail );
        testcmd( $dif, "case05a_pl.txt case05a_pl.txt.tdy", "-perltidy", $pass );
    }

}

# Print pass/fail summary
my $num_failed = summary();
d '$num_failed';
if ( $whoami eq 'ckoknat' ) {
    if ( ! defined $opt{test}  and  ! $num_failed ) {
        say "If everything passes do this:";
        say "    ~/r/$script/test2/${script}2.t";
    }
}

sub getNumLines {
    my $cmd = shift;
    $cmd = "$cmd | wc -l";
    chomp(my $numLines = `$cmd`);
    $numLines =~ s/^\s+//;  # macOS
    return $numLines;
}

# testcmd($cmd, $filelist, $options, $expected_exitstatus);
sub testcmd {
    print "#\n#\n";
    my ( $cmd, $filelist, $options, $expected_exitstatus ) = @_;
    my @filelist = split /\s+/, $filelist;
    if ( @filelist ) {
        @filelist = map { "$testDir/$_" } @filelist unless $filelist[0] =~ m{^//};
    }
    my $command = "$cmd @filelist $options -gui none";
    d '$command';
    my $status  = system($command);
    die if ! is( $status, $expected_exitstatus, "$command  ;  echo \$status\nExpected $expected_exitstatus" ) and $opt{die};
}

# Test if output of command is quiet (no printing to stdout
# test_cmdquiet($cmd, $filelist, $options, $expected_exitstatus)
sub test_cmdquiet {
    my ( $cmd, $filelist, $options, $expected_exitstatus ) = @_;
    my $tmpfile = "$globaltmpdir/dif_${$}_quiet.txt";
    my @filelist = split /\s+/, $filelist;
    if ( @filelist ) {
        @filelist = map { "$testDir/$_" } @filelist unless $filelist[0] =~ m{^//};
    }
    my $command = "$cmd @filelist $options > $tmpfile";
    system($command);
    my $status = ( -f $tmpfile and -z $tmpfile ) ? 0 : $fail;
    print `ls -l $tmpfile`;
    die if ! is( $status, $expected_exitstatus, "$command  ;  echo $status\nExpected $expected_exitstatus" ) and $opt{die};
}

# Controls running of test suites (a test suite is a set of tests)
sub runtests {
    my $testgroup = shift;
    # $t is specifed on the command line with -t
    #     it is either
    #     -t <testgroup>
    #     or
    #     -t <regex>
    #     or
    #     -t ALL  or  no -t specified on command line
    #
    # .t contains blocks such as these, each passing $testgroup to runtests():
    #     if ( runtests('yaml') ) {}
    #     if ( runtests('yaml|json') ) {}
    #
    # If the regex is followed by '+', then run that test and all tests following it
    #
    my $d = 0; # 1 = debug statements for runtests()
    my $local_t = $t; # for debug statement
    if ( $t =~ /^($testgroup|ALL)?(\+)*$/ ) {
        my ($t_regex, $plus) = ($1,$2,$3);
        d '$testgroup $local_t $t_regex $plus';
        print "\n*** $testgroup ***\n";
        if ( $plus ) {
            $t = 'ALL';
        }
        return 1;
    } else {
        return 0;
    }
}
sub summary {
    # Print message if any test failed
    my ($href) = @_;
    my ($passed, $failed) = (0,0);
    my @tests = Test::More->builder->details;
    my @failed;
    my $i = 0;
    for my $test (@tests) {
        $i++;
        if ($test->{ok}) {$passed++} else {$failed++; push @failed, $i};
    }
    my $message;
    if ( $passed == 0  &&  $failed == 0 ) {
        $message = "\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! no tests run !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n";
    } elsif ( $failed ) {
        $message = "\n################################ tests " . (join " ", @failed) . " FAILED ################################\n";
    } else {
        $message = "\n################################ all tests passed ################################\n";
    }
    #done_testing(); # TODO uncomment?
    print $message;
    return $failed;
}

sub whichCommand {
    my $executableAndOptions = shift;
    ( my $executable = $executableAndOptions ) =~ s/^(\S+).*/$1/;    # Strip any options before using 'which'
    my $which = `which $executable 2> /dev/null`;
    #my $which = `which $executable`;
    #return 0 if $which eq '' or $which =~ /Command not found/;
    return 0 if $which eq '';
    return 1;
}

# Not tested yet:  'perldump', 'nodirs'

__END__

__END__

dif by Chris Koknat  https://github.com/koknat/dif
v65 Fri May 14 11:27:56 PDT 2021


This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details:
<http://www.gnu.org/licenses/gpl.txt>

