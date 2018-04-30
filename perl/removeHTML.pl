sub noHTML()
{
	$n = @_;
	if( $n == 1 ) {
		$i = @_[ 0 ];
		# Remove HTML balises
		$i =~ s/<[^>]*>//g;
		# Remove nbsp
		$i =~ s/&nbsp;/ /g;
		# Remove special characters
		$i =~ s/&aacute;/a/g;
		$i =~ s/&agrave;/a/g;
		$i =~ s/&acirc;/a/g;
		$i =~ s/&auml;/a/g;
		$i =~ s/&eacute;/e/g;
		$i =~ s/&egrave;/e/g;
		$i =~ s/&ecirc;/e/g;
		$i =~ s/&euml;/e/g;
		$i =~ s/&iacute;/i/g;
		$i =~ s/&igrave;/i/g;
		$i =~ s/&icirc;/i/g;
		$i =~ s/&iuml;/i/g;
		$i =~ s/&oacute;/o/g;
		$i =~ s/&ograve;/o/g;
		$i =~ s/&ocirc;/o/g;
		$i =~ s/&ouml;/o/g;
		$i =~ s/&uacute;/u/g;
		$i =~ s/&ugrave;/u/g;
		$i =~ s/&ucirc;/u/g;
		$i =~ s/&uuml;/u/g;
		return $i;
	} else {
		@back = ();
		foreach $i( @_ ) {
			# Remove HTML balises
			$i =~ s/<[^>]*>//g;
			# Remove nbsp
			$i =~ s/&nbsp;/ /g;
			# Remove special characters
			$i =~ s/&aacute;/a/g;
			$i =~ s/&agrave;/a/g;
			$i =~ s/&acirc;/a/g;
			$i =~ s/&auml;/a/g;
			$i =~ s/&eacute;/e/g;
			$i =~ s/&egrave;/e/g;
			$i =~ s/&ecirc;/e/g;
			$i =~ s/&euml;/e/g;
			$i =~ s/&iacute;/i/g;
			$i =~ s/&igrave;/i/g;
			$i =~ s/&icirc;/i/g;
			$i =~ s/&iuml;/i/g;
			$i =~ s/&oacute;/o/g;
			$i =~ s/&ograve;/o/g;
			$i =~ s/&ocirc;/o/g;
			$i =~ s/&ouml;/o/g;
			$i =~ s/&uacute;/u/g;
			$i =~ s/&ugrave;/u/g;
			$i =~ s/&ucirc;/u/g;
			$i =~ s/&uuml;/u/g;
			push(@back,$i);
		}
		return @back;
	}
}

return 1;

