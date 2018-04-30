#!/usr/bin/perl
# This function is used to open TeX files
#   vix => vim -o *.tex
#   vix a1 a2... => vim -o *a1*.tex *a2*.tex...

@files = ();
if( $#ARGV == -1 ) {
	@files = `ls *.tex 2> /dev/null`;
} else {
	if( $ARGV[0] =~ /^--?h(elp)?$/ ) {
		# HELP
		print " Usage: vix [file1 file2...]\n";
		print "   vim -o *file1*.tex *file2*.tex...\n";
		print "   If no filename is provided: vim -o *.tex\n";
		exit 8;
	}
	foreach $a( @ARGV ) {
		if( $a !~ /\.tex$/ ) {
			$name = "*$a*.tex";
		} else {
			$name = $a;
		}
		@ls = `ls $name 2> /dev/null`;
		push( @files, @ls );
	}
}
if( @files != () ) {
	foreach $f( @files ) {
		chomp( $f );
	}
	@args = ( 'vim', '-o', @files );
	system( @args );
} else {
	print " No matching file found...\n";
}

exit 0;
