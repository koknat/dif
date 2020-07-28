
sub pin2vrgy {
    my $pin = shift;
    $pin = uc($pin);
    $pin =~ s/[\[\]]//g;
    $pin =~ s/\s+//g;
    return $pin;
}

sub stripStilGz {
    my $stil = shift;
	$stil = basename($stil);
	d('$stil');
	my $pat;
	if ( $stil =~ /^(\S+?)(\.stil)?(_\d+)?(\.gz)?$/ ) {
	    $pat = $1;
		d('$pat');
		return $pat;
	} else {
		return;
	}
}

sub divideSafe {
    my ($num, $den, $default) = @_;
	use Scalar::Util;
	#my $d = 1;
	$default //= 0;
	my $result;
	if ( !Scalar::Util::looks_like_number($num) or !Scalar::Util::looks_like_number($den) or $den == 0 ) {
	    return $default;
	} else {
		return $num/$den;
	}
}

sub getXmode {
	my ($pat, $d) = @_;
	return '' if ! defined $pat;
	my $xmode;
	#if ( $pat =~ /_(\d)x_\w_\d+_?\w?\d*$/ ) {
	if ( $pat =~ /\w_(\d)x_\w/ ) {
    	$xmode = $1;
	} else {
	    $xmode = 1;
	}
	d('$pat $xmode');
	return $xmode;
}
