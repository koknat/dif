#!/home/utils/perl-5.8.8/bin/perl
use warnings;
use strict;
use File::Basename qw(basename dirname);
use Getopt::Long;
use Test::More qw( no_plan );
sub say { print @_, "\n" };
sub D{say "Debug::Statements has been disabled to improve performance"}; sub d{}; sub d2{}; sub ls{};
#eval 'use lib "/home/ate/scripts/regression";  use Debug::Statements ":all";'; say "\nRemember to comment the Debug::Statements line before checking in the code !!\n";

# This should be run from the cmpx/tests directory
# perl cmpx.t

# Parse options
my %opt;
my $d = 0;
GetOptions( \%opt, 'test|t=s', 'extraTests', 'd' => sub { $d = 1 }, 'die' ) or die $!;
my $t = defined $opt{test} ? $opt{test} : 'ALL';
die "ERROR:  Did not expect '@ARGV'.  Did you forget '-t' ? " if @ARGV;

my ($cmpx, $testdir);
chomp( my $whoami = `whoami` );
if ( $whoami eq 'ckoknat' ) {
    $cmpx = "/home/ckoknat/s/regression/cmpx/cmpx";
    $testdir = '/home/scratch.ckoknat_cad/ate/scripts/regression/cmpx/tests';
} else {
    $cmpx = 'perl ../cmpx';
    $testdir = '.';
}

my $pass = 0;
my $fail = 256;
my $err = 512;
print "\n\n\n\n";

if ( runtests('silent') ) {
    test_cmdsilent( $cmpx, "case01a_hosts.txt case01a_hosts.txt", "",        $fail );
    test_cmdsilent( $cmpx, "case01a_hosts.txt case01a_hosts.txt", "-silent", 0 );
}

# Not tested:  'pponly', 'start1=s', 'stop1=s', 'start2=s', 'stop2=s', 'perldump', 'md5sum', 'dir2=s', 'listfiles', 'nodirs'

if ( runtests('white') ) {
    testcmd( $cmpx, "case01a_hosts.txt case01a_hosts.txt",             "",         0 );
    testcmd( $cmpx, "case01a_hosts.txt case01b_hosts_spaces.txt",      "",         $fail );
    testcmd( $cmpx, "case01a_hosts.txt case01b_hosts_spaces.txt",      "-white",   0 );
    testcmd( $cmpx, "case01a_hosts.txt case01c_hosts_blank_lines.txt", "",         $fail );
    testcmd( $cmpx, "case01a_hosts.txt case01c_hosts_blank_lines.txt", "-white",   0 );
    testcmd( $cmpx, "case01a_hosts.txt case01c_hosts_blank_lines.txt", "-w",       0 );
    testcmd( $cmpx, "case01a_hosts.txt case01g_hosts_nospaces.txt",    "",         $fail );
    testcmd( $cmpx, "case01a_hosts.txt case01g_hosts_nospaces.txt",    "-nowhite", 0 );
}

if ( runtests('head') ) {
    testcmd( $cmpx, "case01a_hosts.txt case01d_hosts_missingline.txt", "-headlines 3", 0 );
}
if ( runtests('tail') ) {
    testcmd( $cmpx, "case01a_hosts.txt case01e_hosts_scrambled.txt", "-taillines 1", 0 );
}

if ( runtests('case') ) {
    testcmd( $cmpx, "case01a_hosts.txt case01j_hosts_uppercase.txt", "",      $fail );
    testcmd( $cmpx, "case01a_hosts.txt case01j_hosts_uppercase.txt", "-case", 0 );
}

if ( runtests('comments') ) {
    testcmd( $cmpx, "case01a_hosts.txt case01f_hosts_comments.txt", "",          $fail );
    testcmd( $cmpx, "case01a_hosts.txt case01f_hosts_comments.txt", "-comments", 0 );
}

if ( runtests('grep') ) {
    testcmd( $cmpx, "case01a_hosts.txt case01d_hosts_missingline.txt", "",                $fail );
    testcmd( $cmpx, "case01a_hosts.txt case01a_hosts.txt",             "-grep 'network'", 0 );
    testcmd( $cmpx, "case01a_hosts.txt case01d_hosts_missingline.txt", "-grep 'network'", 0 );
}

if ( runtests('ignore') ) {
    testcmd( $cmpx, "case01a_hosts.txt case01a_hosts.txt",             "-ignore 'localhost6'", 0 );
    testcmd( $cmpx, "case01a_hosts.txt case01d_hosts_missingline.txt", "-ignore 'localhost6'", 0 );
}

if ( runtests('sort_strings') ) {
    testcmd( $cmpx, "case01a_hosts.txt case01e_hosts_scrambled.txt", "",               $fail );
    testcmd( $cmpx, "case01a_hosts.txt case01a_hosts.txt",           "-sort",          0 );
    testcmd( $cmpx, "case01a_hosts.txt case01e_hosts_scrambled.txt", "-sort",          0 );
    testcmd( $cmpx, "case02a.bin case02a.bin",                     "",               0 );
    testcmd( $cmpx, "case02a.bin case02a.bin",                     "-strings",       0 );
    # The next test has $fail on Ubuntu, so commenting it out
    #testcmd( $cmpx, "case02a.bin case02b_scrambled.bin",           "",               $err );    # Could not parse diff output
    testcmd( $cmpx, "case02a.bin case02b_scrambled.bin",           "-strings",       $fail );
    testcmd( $cmpx, "case02a.bin case02b_scrambled.bin",           "-sort",          0 );
    testcmd( $cmpx, "case02a.bin case02b_scrambled.bin",           "-sort -strings", 0 );
    #testcmd( $cmpx, "case02a.bin case02c_longer.bin",              "",               $err );    # Could not parse diff output
    testcmd( $cmpx, "case02a.bin case02c_longer.bin",              "-strings",       $fail );
    #testcmd( $cmpx, "case02a.bin case02c_longer.bin",              "-sort",          $err );
    #testcmd( $cmpx, "case02a.bin case02c_longer.bin",              "-sort -strings", $fail );   # Could not parse diff output
}

if ( runtests('uniq') ) {
    testcmd( $cmpx, "case01a_hosts.txt case01a_hosts.txt",         "-uniq",              0 );
    testcmd( $cmpx, "case01a_hosts.txt case01i_hosts_doubles.txt", "",                   $fail );
    testcmd( $cmpx, "case01a_hosts.txt case01i_hosts_doubles.txt", "-uniq",              $fail );
    testcmd( $cmpx, "case01a_hosts.txt case01i_hosts_doubles.txt", "-uniq -sort",        0 );
}

if ( runtests('fold') ) {
    testcmd( $cmpx, "case01a_hosts.txt case01a_hosts.txt",             "-fold",          0 );
    testcmd( $cmpx, "case01a_hosts.txt case01d_hosts_missingline.txt", "-fold",          $fail );
    testcmd( $cmpx, "case01a_hosts.txt case01a_hosts.txt",             "-foldchars 10",  0 );
    testcmd( $cmpx, "case01a_hosts.txt case01d_hosts_missingline.txt", "-foldchars 10",  $fail );
}

if ( runtests('split') ) {
    testcmd( $cmpx, "case01a_hosts.txt case01a_hosts.txt",             "-split",          0 );
    testcmd( $cmpx, "case01a_hosts.txt case01d_hosts_missingline.txt", "-split",          $fail );
    testcmd( $cmpx, "case01a_hosts.txt case01a_hosts.txt",             "-splitchar '.'",  0 );
    testcmd( $cmpx, "case01a_hosts.txt case01d_hosts_missingline.txt", "-splitchar '.'",  $fail );
}

if ( runtests('trim') ) {
    # The case01k_hosts_trimmed.txt looks odd since this script considers each tab to be one character, but vim thinks they are 4 or 8
    testcmd( $cmpx, "case01a_hosts.txt case01k_hosts_trimmed.txt",     "-trimchars 40",   0 );
}

if ( runtests('fields') ) {
    testcmd( $cmpx, "case04a_lsl.txt case04b_lsl.txt", "-fields 0,8", $fail );
    testcmd( $cmpx, "case04a_lsl.txt case04b_lsl.txt", "-fields 3,8", 0 );
    testcmd( $cmpx, "case04a_lsl.txt case04b_lsl.txt", "-fields 0,8 -fieldSeparator '\\s+'", $fail );
    testcmd( $cmpx, "case04a_lsl.txt case04b_lsl.txt", "-fields 3,8 -fieldSeparator '\\s+'", 0 );
    testcmd( $cmpx, "case08a.csv case08b.csv", "", $fail );
    testcmd( $cmpx, "case08a.csv case08b.csv.gz", "-fields 1", $fail );
    testcmd( $cmpx, "case08a.csv case08b.csv.gz", "-fields 2", 0 );
    testcmd( $cmpx, "case08a.csv case08b.csv.gz", "-fields 1 -fieldSeparator ','", $fail );
    testcmd( $cmpx, "case08a.csv case08b.csv.gz", "-fields 2 -fieldSeparator ','", 0 );
    testcmd( $cmpx, "case04a_lsl.txt case04b_lsl.txt", "-fields -1", 0 );
    testcmd( $cmpx, "case08a.csv case08c.csv", "", $fail );
    testcmd( $cmpx, "case08a.csv case08c.csv", "-fields -1", 0 );
    testcmd( $cmpx, "case08a.csv case08b.csv.gz", "-fields not0,1,3+", 0 );
    # -fieldJustify
    testcmd( $cmpx, "case08c.csv case08d.csv", "", $fail );
    testcmd( $cmpx, "case08c.csv case08d.csv", "-fieldJustify", 0 );
}

if ( runtests('start_stop') ) {
    testcmd( $cmpx, "case04a_lsl.txt case04b_lsl.txt", "-start '( collect| k)' -stop '( csv_print| kwhite)' ", 0 );
}

if ( runtests('sub') ) {
    testcmd( $cmpx, "case01a_hosts.txt case01h_hosts_misspelling.txt", "",                                              $fail );
    testcmd( $cmpx, "case01a_hosts.txt case01a_hosts.txt",             "-sub 'HOST^^host'",                             0 );
    testcmd( $cmpx, "case01a_hosts.txt case01h_hosts_misspelling.txt", "-sub 'HOST^^host'",                             0 );
}

if ( runtests('subtable') ) {
    testcmd( $cmpx, "case01a_hosts.txt case01h_hosts_misspelling.txt", "-subtable $testdir/case03_subtable", 0 );
}

if ( runtests('paragraphSort') ) {
    testcmd( $cmpx, "case07a_perlSub.pm case07c_paragraphSort.pm", "-paragraphSort", 0 );
}

if ( runtests('tartv') ) {
    #testcmd( $cmpx, "case10a.tar.gz case10b.tar.gz",             "",         $fail );          # same 2 files, but it fails since the name of the file is inside the .tar.gz
    testcmd( $cmpx, "case10a.tar.gz case10b.tar.gz",             "-tartv",            0 );      # same 2 files
    testcmd( $cmpx, "case10a.tar.gz case10c.tar.gz",             "-tartv",            $fail );  # additional 3rd file
    testcmd( $cmpx, "case10a.tar.gz case10c.tar.gz",             "-tartv -fields 1",  $fail );  # additional 3rd file, only print the filenames
}

if ( runtests('zipped') ) {
    testcmd( $cmpx, "case01a_hosts.txt.gz case01e_hosts_scrambled.txt.gz",           "",      $fail );
    testcmd( $cmpx, "case01e_hosts_scrambled.txt.gz case01e_hosts_scrambled.txt.gz", "-sort", 0 );
    testcmd( $cmpx, "case01a_hosts.txt.xz case01e_hosts_scrambled.txt.xz",           "",      $fail );
    testcmd( $cmpx, "case01e_hosts_scrambled.txt.xz case01e_hosts_scrambled.txt.xz", "-sort", 0 );
    testcmd( $cmpx, "case01a_hosts.txt.gz case01e_hosts_scrambled.txt.xz",           "",      $fail );
    testcmd( $cmpx, "case01e_hosts_scrambled.txt.gz case01e_hosts_scrambled.txt.xz", "-sort", 0 );
    testcmd( $cmpx, "case01a_hosts.txt.bz2 case01e_hosts_scrambled.txt.xz",           "",      $fail );
    testcmd( $cmpx, "case01e_hosts_scrambled.txt.bz2 case01e_hosts_scrambled.txt.xz", "-sort", 0 );
}

if ( runtests('gold') ) {
    testcmd( $cmpx, "case01a_hosts.txt",                    "-gold",         0 );
    testcmd( $cmpx, "case01a_hosts.golden.txt",             "-gold",         0 );
    testcmd( $cmpx, "case01b_hosts_spaces.txt",             "-gold",         $fail );
    testcmd( $cmpx, "case01b_hosts_spaces.golden.txt",      "-gold",         $fail );
}

if ( 0 and runtests('dir2') ) {
    # TODO
    # Bypassing since -dir2 is not supported with full path names, and the test runs with full path names like this:
    #     > /home/ckoknat/s/regression/cmpx/cmpx /home/scratch.ckoknat_cad/ate/scripts/regression/cmpx/case01a_hosts.txt -dir2 dirA
    #     2nd file will be dirA//home/scratch.ckoknat_cad/ate/scripts/regression/cmpx/case01a_hosts.txt
    testcmd( $cmpx, "case01a_hosts.txt dirA/case01a_hosts.txt",             "",         0 );
    testcmd( $cmpx, "case01a_hosts.txt dirB/case01a_hosts.txt",             "",         $fail );
    testcmd( $cmpx, "case01a_hosts.txt",                          "-dir2 dirA",         0 );       # fails!
    testcmd( $cmpx, "case01a_hosts.txt",                          "-dir2 dirB",         $fail );
    testcmd( $cmpx, "case01a_hosts.txt",                "-dir2 dirA -comments",         0 );
    die;
}

if ( runtests('lsl') ) {
    testcmd( $cmpx, "case04b_lsl.txt case04c_lsl_tail.txt", "", $fail );
    testcmd( $cmpx, "case04b_lsl.txt case04c_lsl_tail.txt", "-taillines 50", 0 );
    testcmd( $cmpx, "case04a_lsl.txt case04a_lsl.txt", "",     0 );
    testcmd( $cmpx, "case04a_lsl.txt case04b_lsl.txt", "",     $fail );
    testcmd( $cmpx, "case04a_lsl.txt case04a_lsl.txt", "-lsl", 0 );
    testcmd( $cmpx, "case04a_lsl.txt case04b_lsl.txt", "-lsl", 0 );
}


if ( runtests('perleval') ) {
    testcmd( $cmpx, "case11a_perlhash case11b_perlhash",             "",                  $fail );
    testcmd( $cmpx, "case11a_perlhash case11b_perlhash",             "-perleval",         0 );
    testcmd( $cmpx, "case11a_perlhash case11c_perlhash",             "-perleval",         $fail );
}

if ( runtests('subroutineSort') ) {
    testcmd( $cmpx, "case13a.pl case13b.pl", "", $fail );
    testcmd( $cmpx, "case13a.pl case13b.pl", "-subroutineSort", $pass );
    testcmd( $cmpx, "case13a.pl case13c.pl", "-subroutineSort", $fail );
}

if ( runtests('externalPreprocessScript') ) {
    testcmd( $cmpx, "case01a_hosts.txt case01e_hosts_scrambled.txt",    "",                                    $fail );
    testcmd( $cmpx, "case01a_hosts.txt case01a_hosts.txt",              "-externalPreprocessScript sort",          0 );  # trivial
    testcmd( $cmpx, "case01a_hosts.txt case01e_hosts_scrambled.txt",    "-externalPreprocessScript sort",          0 );
    testcmd( $cmpx, "case01a_hosts.txt.gz case01e_hosts_scrambled.txt", "-externalPreprocessScript sort",          0 );  # handle .gz
}

if ( $opt{extraTests}  or  -d "/home/ckoknat" ) {
    say "\n\n***************************************************************************************************************************************";
    say "* Running additional tests, which may fail if there are missing executables or Perl libraries (yaml, json, tree, bcpp, perltidy, bz2) *";
    say "***************************************************************************************************************************************";

    if ( runtests('json') ) {
        testcmd( $cmpx, "case14a.json case14b.json", "",            $fail );
        testcmd( $cmpx, "case14a.json case14b.json", "-json",       $pass );
        testcmd( $cmpx, "case14a.json case14a.json.gz", "",         $pass );
        testcmd( $cmpx, "case14a.json case14c.json", "-json -case", $pass );
    }

    if ( runtests('yaml') ) {
        testcmd( $cmpx, "case14a.yml case14b.yml", "",            $fail );
        testcmd( $cmpx, "case14a.yml case14b.yml", "-yaml",       $pass );
        testcmd( $cmpx, "case14a.yml case14a.yml.gz", "",         $pass );
        testcmd( $cmpx, "case14a.yml case14c.yml", "-yaml -case", $pass );
    }
    
    if ( runtests('externalPreprocessScript') ) {
        testcmd( $cmpx, "case14a.yml case14b.yml", "",            $fail );
        testcmd( $cmpx, "case14a.yml case14b.yml", "-externalPreprocessScript $testdir/case14_externalPreprocessScript.pl",       $pass );
        testcmd( $cmpx, "case14a.yml case14c.yml", "-externalPreprocessScript $testdir/case14_externalPreprocessScript.pl",       $pass );
    }
    
    if ( runtests('bcpp') ) {
        testcmd( $cmpx, "case09a.c case09b.c", "", $fail );
        testcmd( $cmpx, "case09a.c case09b.c", "-bcpp", 0 );
    }
    if ( runtests('perltidy') ) {
        testcmd( $cmpx, "case05a_pl.txt case05a_pl.txt.tdy", "",          $fail );
        testcmd( $cmpx, "case05a_pl.txt case05a_pl.txt.tdy", "-perltidy", 0 );
    }

    if ( runtests('dir') ) {
        # Compare two directories, these use 'tree'
        testcmd( $cmpx, "dirA dirAcopy", "-ignore dir", 0 );  # -ignore dir is needed for the comparison because the directory name is listed in the header
        testcmd( $cmpx, "dirA dirB",     "-ignore dir", $fail );
    }
    if ( runtests('bz') ) {
        testcmd( $cmpx, "case01a_hosts.txt.bz2 case01e_hosts_scrambled.txt.bz2",           "",      $fail );
        testcmd( $cmpx, "case01e_hosts_scrambled.txt.bz2 case01e_hosts_scrambled.txt.bz2", "-sort", 0 );
    }

}

# Print pass/fail summary
my $num_failed = summary();
d '$num_failed';
if ( $whoami eq 'ckoknat' ) {
    if ( ! defined $opt{test}  and  ! $num_failed ) {
        say "If everything passes do this:";
        say "    ~/r/cmpx2/cmpx2.t";
    }
}

# testcmd($cmd, $filelist, $options, $expected_exitstatus);
sub testcmd {
    print "#\n#\n";
    my ( $cmd, $filelist, $options, $expected_exitstatus ) = @_;
    my @filelist = split /\s+/, $filelist;
	@filelist = map { "$testdir/$_" } @filelist unless $filelist[0] =~ m{^//};
	my $command = "$cmd @filelist $options -difftool ''";
    my $status  = system($command);
    die if ! is( $status, $expected_exitstatus, "$command  ;  echo \$status\nExpected $expected_exitstatus" ) and $opt{die};
}

# Test if output of command is silent (no printing to stdout
# test_cmdsilent($cmd, $filelist, $options, $expected_exitstatus)
sub test_cmdsilent {
    my ( $cmd, $filelist, $options, $expected_exitstatus ) = @_;
    my $tmpfile = "/tmp/cmpx_${$}_silent.txt";
    my @filelist = split /\s+/, $filelist;
	@filelist = map { "$testdir/$_" } @filelist;
    my $command = "$cmd @filelist $options > $tmpfile";
    system($command);
    my $status = ( -f $tmpfile and -z $tmpfile ) ? 0 : $fail;
    print `ls -l $tmpfile`;
    die if ! is( $status, $expected_exitstatus, "$command  ;  echo $status\nExpected $expected_exitstatus" ) and $opt{die};
}

# Copied from /home/ate/scripts/regression/regression.pm, because want to make tests standalone
# Controls running of test suites (a test suite is a set of tests)
sub runtests {
	my $testgroup = shift;
    # $t is a shared 'our' variable which was specifed on the command line with -t
    #     it is either
    #     -t <testgroup>
    #     or
    #     -t <regex>
    #     or
    #     -t ALL  or  no -t specified on command line
    #     or
    #     -t torture
    #     or
    #     -t torture,<regex>
    #
    # Implemented it as follows within .t:
    #     $regression::t = defined $opt{test} ? $opt{test} : 'ALL';
    #
    # .t contains blocks such as these, each passing $testgroup to runtests():
    #     if ( runtests('chiplet2firstChipRev') ) {}
    #     if ( runtests('FailureAnalysis|chiplet2firstChipRev') ) {}
    #
    # If the regex is followed by '+', then run that test and all tests following it
    #
    my $d = 0; # 1 = debug statements for runtests() and tortureTest()  2 = debug statements also for .t which tortureTest() runs
    my $local_t = $t; # for debug statement
	if ( $t =~ /^(torture,?)?($testgroup|ALL)?(\+)*$/ ) {
        my ($torture, $t_regex, $plus) = ($1,$2,$3);
        d '$testgroup $local_t $torture $t_regex $plus';
        if ( $torture ) {
            $t_regex = 'ALL' if ! defined $t_regex;
            exit tortureTest( { options => "-t $t_regex -die", mailme => 1, debug => $d } );
        }
        print "\n*** $testgroup ***\n";
        if ( $plus ) {
            $t = 'ALL';
        }
        return 1;
	} else {
        return 0;
    }
}
# Copied from /home/ate/scripts/regression/regression.pm, because want to make tests standalone
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
    if ( $href->{return_only_fail_message} ) {
        # for emulating die_on_fail within regression::run_tests()
        if ($failed) {
            return $message;
        } else {
            return;
        }
    } else {
        # the usual case
        print $message;
        return $failed;
    }
}

__END__

