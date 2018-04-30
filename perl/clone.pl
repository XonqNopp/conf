#!/usr/bin/perl
## Script written and mantained by GI
## Backup dir1 in dir2

$HSH = `echo \$HSH`;
chomp($HSH);
require "$HSH/.wash/perl/readrec.pl";
require "$HSH/.wash/perl/BadFilesCheck.pl";

my $do_remove = 0;
while( $ARGV[0] =~ /^-/ ) {
	my $a = shift( @ARGV );
	if( $a =~ /^--follow-rm$/ ) {
		$do_remove = 1;
	} else {
		print " Sorry, argument $a not recognized...\n";
	}
}

$dir1 = $ARGV[0];
$dir2 = $ARGV[1];
if( ! -d $dir2 ) {
	print "  Destination directory not found, creating...\n";
	system("mkdir -p $dir2");
}
$log_filename = ".clone.log";
$log_file = "$dir2/$log_filename";
open(LOG,">>",$log_file) or die(" Cannot open log file $log_file...\n" );
($sec, $min, $hour, $day, $month, $yy, $wd, $yd, $dst ) = localtime(time);
$year = $yy + 1900;
$month++;
print LOG "\n\n";
print LOG "   *** LOG FILE FOR CLONING OF ";
if( $day < 10 ) { print LOG "0"; }
print LOG "$day.";
if( $month < 10 ) { print LOG "0"; }
print LOG "$month.$year, ";
if( $hour < 10 ) { print LOG "0"; }
print LOG "$hour:";
if( $min < 10 ) { print LOG "0"; }
print LOG "$min:";
if( $sec < 10 ) { print LOG "0"; }
print LOG "$sec ***\n";
print LOG "\n";
$gdir1 = $dir1;
$gdir1 =~ s/\./\\./g;
$gdir1 =~ s/\//\\\//g;
$gdir2 = $dir2;
$gdir2 =~ s/\./\\./g;
$gdir2 =~ s/\//\\\//g;
@dd = readdirs($dir1);
@d2 = readdirs($dir2);
%check = map{ $_ => 1 } @d2;
%check2 = map{ $_ => 1 } @dd;

## Trap function
$SIG{INT} = sub {
	print LOG " # Interrupted while copying $d...\n";
	close(LOG);
	die( "   # Interrupted while copying $d...\n" );
};

## Find why makefile's are all updated systematically???

if( $do_remove ) {
	foreach my $dbis( @d2 ) {
		my $similar = $dbis;
		$similar =~ s/^$gdir2/$dir1/;
		my $short = $dbis;
		$short =~ s/^.*\///;
		## Avoid copying the useless files
		if( BadFilesCheck( $short ) && $short ne $log_filename ) {
			if( -f $dbis && !exists( $check2{$similar} ) ) {
				print LOG " - Removing $dbis...\n";
				print " - Removing $dbis...\n";
				system("rm","-r",$dbis);
			}
		}
	}
}
foreach $d( @dd ) {
	$similar = $d;
	$similar =~ s/^$gdir1/$dir2/;
	#if( $similar ~~ @d2 ) { # smart matching only from 5.10
	$short = $d;
	$short =~ s/^.*\///;
	## Avoid copying the useless files
	if( BadFilesCheck( $short ) && $short ne $log_filename ) {
		if( exists( $check{$similar} ) ) {
			$ref = $d;
			$ref =~ s/^$gdir1/$dir2/;
			if( $d =~ /\// ) {
				$thisdir = $d;
				$thisdir =~ s/^(.*)\/[^\/]*$/\1/;
				#$thisdir =~ s/^$gdir1/$dir2/;
			} else { 
				#$thisdir = $dir2;
				$thisdir = $dir1;
			}
			$bash = "find \"$thisdir\" -newer \"$ref\" -name \"$short\"";
			open(FIND,"$bash |");
			while( $ii = <FIND> ) { 
				chomp($ii);
				$fetch = $ii;
				$fetch =~ s/^$dir1/$dir2/;
				$nofetch = $ii;
				$nofetch =~ s/^$dir1\///;
				if( ! -d $ii ) {
					print " o $nofetch -> $fetch\n";
					print LOG " o $nofetch -> $fetch\n";
					system( "cp", "-p", "$ii", "$fetch" );
				}
			}
			close(FIND);
		} else {
			$newone = $d;
			$newone =~ s/^$gdir1\///;
			$oldone = $d;
			$oldone =~ s/^$gdir1/$dir2/;
			if( -d $d ) {
				print LOG "d";
			} else {
				print LOG " ";
			}
			print " + $newone -> $oldone\n";
			print LOG "+ $newone -> $oldone\n";
			if( -d $d ) {
				system( "mkdir", "-p", "$oldone" );
			} else {
				system( "cp", "-p", "$d", "$oldone" );
			}
		}
	} else { 
		if( $short ne "Icon\r" && $short ne $log_filename ) { 
			print "     (Removing info file $short)\n";
			print LOG "   * Removing info file $short\n";
			system("rm",$d); 
		}
	}
}

print "\n\n  New items from\n     $dir1\n  have replaced old ones in\n     $dir2\n\n";

close(LOG);
exit 0;
