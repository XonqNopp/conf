#!/usr/bin/perl
# Locate a file in the subdirectories

if( $#ARGV == 0 ) {
	$path = '.';
} else {
	$path = shift( @ARGV );
}
$tofind = shift( @ARGV );
if( $tofind eq '-h' ) {
	# HELP
	print " Usage: findindirs [path] matchname\n";
} else {
	$tofind = lc( $tofind );
	@results = ();
	opendir( DIR, $path ) or die( " Sorry, cannot open directory $path...\n" );
	@dirs = readdir( DIR );
	closedir( DIR );
	if( $path eq '.' ) {
		$path = '';
	} else {
		$path = "$path/";
	}
	foreach $d( @dirs ) {
		if( -d "$path$d" && $d ne '..' && $d ne '.' ) {
			opendir( DIR2, "$path$d" ) or die( " Uh! Dude, there is a problem with $path$d...\n" );
			@files = readdir( DIR2 );
			closedir( DIR2 );
			foreach $f( @files ) {
				if( $f =~ m/$tofind/i ) {
					push( @results, "$d/$f" );
				}
			}
		}
	}
	if( @results != () ) {
		print " ### Looking for $path*$tofind*... ###\n";
		foreach $r( @results ) {
			$fname = $r;
			$fname =~ s/^[^\/]*\///;
			$dirname = $r;
			$dirname =~ s/\/[^\/]*$//;
			print "  + In $dirname : $fname\n";
		}
	} else {
		print " Sorry, filename did not match...\n";
	}
}

exit 0;
