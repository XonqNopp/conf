## Script written and mantained by GI

sub readdirs()
{
	local @back = ();
	local @is_dir = ();
	local $d = $_[0];
	#print " Reading directory $d\n";
	opendir(DIR,$d) or die( " Cannot open directory $d !\n" );
	@ba1 = readdir(DIR);
	closedir(DIR);
	foreach $dd( @ba1 ) {
		if( $dd !~ /^\.\.?$/ && BadFilesCheck( $dd ) ) { 
			$full = "$d/$dd";
			#if( $d eq "." ) { $full = $dd; }
			#$full = $dd;
			push(@back,"$full");
			if( -d $full ) {
				push( @is_dir,$full);
			}
		}
	}
	foreach $dd( @is_dir ) {
		@ba2 = readdirs($dd);
		foreach $d2( @ba2 ) {
			if( $d2 !~ /^\.\.?$/ ) {
				push(@back,$d2);
			}
		}
	}
	return @back;
}

return 1;
