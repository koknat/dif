#!/home/utils/perl-5.8.8/bin/perl
use warnings;
use strict;

sub b {
    bar();
    baz();
}

sub a {
    foo();
    bar();
}

__END__
commentB
