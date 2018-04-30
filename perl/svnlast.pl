#!/usr/bin/perl
# Displays nice infos for svn log
print " Rewrite this script using svn info command instead... or would it be wrong?\n\n";

# Looking at args
if( $#ARGV == -1 ) {
	$rev = '--limit 1';
	$path = '';
} else {
	if( $ARGV[ 0 ] =~ m/^H$/ ) {
		$rev = '-rHEAD';
		shift @ARGV;
	} elsif( $ARGV[ 0 ] =~ m/^[0-9]+$/ ) {
		$revnum = shift( @ARGV );
		$rev = "-r$revnum";
	} else {
		$rev = '--limit 1';
	}
	$path = '';
	if( $#ARGV >= 0 ) {
		$path = $ARGV[ 0 ];
	}
}
# Executing the command
$unix = "svn log -v $rev $path";
open( SVN, "$unix |" );
@svn = ();
while( $s = <SVN> ) {
	chomp( $s );
	push( @svn, $s );
}
# Removing the lines of ---
pop( @svn );
shift( @svn );
# Sorting results
$first = shift( @svn );
@infos = split( ' \| ', $first );
$rev = $infos[ 0 ];
$rev =~ s/^r//;
$author = $infos[ 1 ];
$date = $infos[ 2 ];
$date =~ s/([0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}):[0-9]{2}.*/\1/;
shift( @svn );
$comment = pop( @svn );
@svn = sort( @svn );
# Displaying the results
print "\n\n";
print "### Log file for revision $rev ###\n";
print "  Done by $author on $date\n";
print "  $comment\n";
foreach $f( @svn ) {
	$f =~ s/^ +//;
	print "     $f\n";
}
print "\n";
# Done

exit 0;

