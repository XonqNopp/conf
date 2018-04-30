#!/usr/bin/perl
## Script written and mantained by GI
if( $#ARGV == -1 || ( $#ARGV == 0 && $ARGV[0] =~ /--?h(elp)?/ ) ) {
	## Display help, explain usage
	print " This script is intended to be used only through the 'svn merge' command.\n";
	exit 0;
}

$base   = $ARGV[1];
$theirs = $ARGV[2];
$mine   = $ARGV[3];
$merged = $ARGV[4];
$wcpath = $ARGV[5];

for( $i = -1; $i < $#ARGV; $i++ ) {
	$thisARG = $ARGV[$i];
	print "$i: $thisARG\n";
}

#system("vimdiff");

## Ask for exit status
print " Is the merged file OK now? [YES/no]  ";
$finish = <>;
chomp($finish);
if( $finish == "" || $finish =~ /^yes$/i ) {
	$xi = 0;
} else {
	$xi = 1;
}

exit $xi;
