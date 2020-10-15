#!/usr/bin/perl
## Script written and mantained by GI
## Used to write the file containing all the picture filenames needed to be converted from ps to eps
@reports = @ARGV;
@pics = ();

foreach $report( @reports ) {
	print "  Reading $report...\n";
	open( REP, "<", $report ) or die( " Report not openable :-(\n" );
	@rep = <REP>;
	close(REP);
	$repinline = join(' ',@rep);
	$repinline =~ s/  +/ /g;
	$repinline =~ s/\\subfloat\[[^\]]*\]\{//g;
	chomp( $repinline );
	@repsplit = split( ' ',$repinline );
	foreach $r( @repsplit ) {
		chomp( $r );
		if( $r =~ /^\\/ && $r !~ /\#/ ) {
			if( $r =~ /includegraphics/ ) {
			# Standard case #
				$r =~ s/^.*includegraphics(\[[^\]]*\])?\{//;
				$r =~ s/\}.*$//;
				$picname = "$r ";
				push( @pics, $picname );
			}
		}
	}
}

# Print GEN
$filename = "pics.mk";
open(GEN,">",$filename) or die( " pics.mk cannot be written\n" );
print GEN "PICS = ";
foreach $p( @pics ) {
	print GEN $p;
}
close(GEN);

exit 0;
