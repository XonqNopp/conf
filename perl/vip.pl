#!/usr/bin/perl
# This function is used to open TeX files
#   vip => vim -o *.cpp
#   vip X a1 a2...
#     X = c : vim -o *a1*.cpp *a2*.cpp...
#     X = h : vim -o *a1*.hpp *a2*.hpp...
#     X = M : vim -o *Main.cpp
#     X = ch: vim -o *a1*.cpp *a1*.hpp...

$type = '';
if( $#ARGV == -1 ) {
	$type = 'c';
} else {
	if( $ARGV[0] =~ /^--?h(elp)?$/ ) {
		# HELP
		print " Usage: vip X ...\n";
		print "   X == c: vim *.cpp\n";
		print "   X == M: vim *Main.cpp\n";
		print "   X == h: vim *.hpp\n";
		print "           with args: vim \$1.hpp \$2.hpp...\n";
		print "   no X: vim \$1.cpp \$2.cpp...\n";
		exit 8;
	}
	$type = shift( @ARGV );
}
if( $type ne '' ) {
	@files = ();
	@forls = ();
	if( $#ARGV > -1 ) {
		foreach $a( @ARGV ) {
			push( @forls, "*$a*" );
		}
	} else {
		@forls = ( '*' );
	}
	if( $type eq 'c' ) {
		@ext = ( '.cpp', '.cc', '.c' );
	} elsif( $type eq 'h' ) {
		@ext = ( '.hpp', '.h' );
	} elsif( $type eq 'M' ) {
		@ext = ( 'Main.cpp' );
	} elsif( $type eq 'ch' ) {
		@ext = ( '.cpp', '.cc', '.c', '.hpp', '.h' );
	}
	foreach $ls( @forls ) {
		foreach $e( @ext ) {
			@fs = `ls $ls$e 2> /dev/null`;
			push( @files, @fs );
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
}

exit 0;
