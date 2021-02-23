#!/home/utils/perl-5.8.8/bin/perl
use warnings;
use strict;

sub a {
    foo();
}

sub b {
    bar();
    baz();
}

__END__
commentA
