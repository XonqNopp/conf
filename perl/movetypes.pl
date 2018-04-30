#!/usr/bin/perl
$dir = shift( @ARGV );
$dir =~ s/\/$//;
$destdir = shift( @ARGV );
$destdir =~ s/\/$//;
@types = ();
while( $#ARGV >= 0 ) {
	push( @types, shift( @ARGV ) );
}
# Read directory
opendir( DIR, $dir ) or die( " Cannot open directory $dir...\n" );
@files = readdir( DIR );
closedir( DIR );

print " Move files from $dir to $destdir ?\n";
# Display files
@tomove = ();
foreach $f( @files ) {
	chomp( $f );
	if( @types ) {
		foreach $t( @types ) {
			if( $f =~ m/\.$t$/ ) {
				print "$f\n";
				push( @tomove, $f );
			}
		}
	} else {
		print "$f\n";
		push( @tomove, $f );
	}
}
# Ask user
print " ([y]/n)  ";
$answer = <>;
chomp( $answer );
# Move files
if( $answer eq "" || $answer eq "y" ) {
	foreach $it( @tomove ) {
		system( 'mv', '-v', "$dir/$it", "$destdir/$it" );
	}
}

exit 0;

