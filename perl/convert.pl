sub normalchars()
{
	@back = ();
	$idx = 0;
	foreach $i( @_ ) {
		$i =~ s/é/e/g;
		$i =~ s/è/e/g;
		$i =~ s/ê/e/g;
		$i =~ s/ë/e/g;
		$i =~ s/à/a/g;
		$i =~ s/á/a/g;
		$i =~ s/â/a/g;
		$i =~ s/ä/a/g;
		$i =~ s/ï/i/g;
		$i =~ s/î/i/g;
		$i =~ s/ì/i/g;
		$i =~ s/í/i/g;
		$i =~ s/ñ/n/g;
		$i =~ s/ó/o/g;
		$i =~ s/ò/o/g;
		$i =~ s/ô/o/g;
		$i =~ s/ö/o/g;
		$i =~ s/ü/u/g;
		$i =~ s/û/u/g;
		$i =~ s/ç/c/g;
		$i =~ s/\t/ /g;
		@back[ $idx ] = $i;
		$idx++;
	}
	return @back;
}

return 1;

