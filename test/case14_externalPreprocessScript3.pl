#!/home/utils/perl-5.8.8/bin/perl
use warnings;
use strict;
sub say { print @_, "\n" };
use Dumpvalue;
use Data::Dumper;
use Getopt::Long;
use YAML::XS ();
use YAML::Syck ();

my %opt;
Getopt::Long::GetOptions( \%opt, 'in=s', 'out=s' );

# Usage:  case14a_externalPreprocessScript3.pl --in <infile> --out <outfile>

my $infile = $opt{in};
my $outfile = $opt{out};
my $text;
if ( $infile =~ /\.yml$/ ) {
    # The input seems to be in .yml format.  Preprocess through yaml read/write to remove formatting differences
    if (1) {
        # Syck is handy because it removes the quotes
        my $ymlRef = YAML::Syck::LoadFile($infile);
        $text = YAML::Syck::Dump($ymlRef);
    } else {
        my $ymlRef = YAML::XS::LoadFile($infile);
        $text = YAML::XS::Dump($ymlRef);
    }
} else {
    # The input is not yml
    open( IN, '<', $infile ) or die "ERROR: Cannot open file for reading  $infile\n\n";
    $text = do { local $/; <IN> };
}
open( OUT, '>', $outfile ) or die "ERROR: Cannot open file for writing:  $outfile\n\n";

# Next, do custom substitutions
for my $line ( split "\n", $text ) {
    chomp($line);
    $line =~ s/\s+/ /;       # condense multiple spaces to one space
    $line =~ s/\s+$//;       # remove spaces at end of line
    $line = lc($line);       # lowercase
    $line =~ s/\s*#.*//;     # remove comments
    $line =~ s/\s*\/\/.*//;  # remove comments
    if (1) {
        # Custom substitutions
        $line =~ s/foo/bar/i;
        $line =~ s/baz/qux/i;
    }
    print OUT "$line\n" if $line =~ /\S/;  # skips empty lines
}

__END__

Example usage:

dif case14a.yml case14c.yml -externalPreprocessScript3 case14_externalPreprocessScript3.pl

To modify one file without doing the diff:
    case14_externalPreprocessScript3.pl --in file1 --out file1.modified
