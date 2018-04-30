#!/usr/bin/perl
# This function is used to open makefiles
#   vik => vim makefile
# or
#   vik dir1 dir2 => vim -o dir1/makefile dir2/makefile...

if( $#ARGV == -1 ) {
	system( 'vim', '-o', 'makefile' );
} else {
	if( $ARGV[0] =~ /^--?h(elp)?$/ ) {
		# HELP
		print " Usage: vik [dir1 dir2...]\n";
		print "   vim for many makefiles\n";
		exit 8;
	}
	@dirs = ();
	foreach $a( @ARGV ) {
		push( @dirs, "$a/makefile" );
	}
	@args = ( 'vim', '-o', @dirs );
	system( @args );
}

exit 0;
