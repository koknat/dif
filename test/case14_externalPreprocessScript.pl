#!/home/utils/perl-5.8.8/bin/perl
use warnings;
use strict;
sub say { print @_, "\n" };
use Dumpvalue;
use Data::Dumper;
use Getopt::Long;
use YAML::XS ();
use YAML::Syck ();

# Usage:  cat <infile>  |  case14a_externalPreprocessScript.pl  >  <outfile>

my $input = do { local $/; <STDIN> };
my $text;
if ( $input =~ /^---/ ) {
    # The input seems to be in .yml format.  Preprocess through yaml read/write to remove formatting differences
    if (1) {
        # Syck is handy because it removes the quotes
        my $ymlRef = YAML::Syck::Load($input);
        $text = YAML::Syck::Dump($ymlRef);
    } else {
        my $ymlRef = YAML::XS::Load($input);
        $text = YAML::XS::Dump($ymlRef);
    }
} else {
    # The input is not yml
    $text = $input;
}

# Next, do custom substitutions
my $out;
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
    $out .= "$line\n" if $line =~ /\S/;  # skips empty lines
}
print $out;

__END__

Example usage:

dif case14a.yml case14c.yml -externalPreprocessScript case14_externalPreprocessScript.pl

To modify one file without doing the diff:
    cat file1 > case14a_externalPreprocessScript.pl > file1.modified
