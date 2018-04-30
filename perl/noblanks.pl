#!/usr/bin/perl
#  Removes the blank spaces in filenames of whole directories

@dirs = ();
if( $#ARGV == -1 ) {
	$d = `pwd`;
	chomp( $d );
	push( @dirs, $d );
} else {
	while( $#ARGV > -1 ) {
		push( @dirs, shift( @ARGV ) );
	}
}
if( $dirs[0] eq '-h' ) {
	# HELP
	print " Usage: noblanks [dir1 dir2...]\n";
	print "   Removes the blank spaces in the filenames of\n";
	print "   dir1, dir2... If no dir specified, current is taken.\n";
} else {
	foreach $dir( @dirs ) {
		#chomp( $dir );
		opendir( DIR, $dir ) or die( " Cannot open $dir..." );
		@f = readdir( DIR );
		closedir( DIR );
		foreach $f( @f ) {
			if( $f =~ m/ / ) {
				$without = $f;
				$without =~ s/ /_/g;
				print "Moving $f to $without...\n";
				system( 'mv', "$dir/$f", "$dir/$without" );
			}
		}
	}
}

exit 0;

