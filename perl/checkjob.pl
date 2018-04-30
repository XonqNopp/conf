#!/usr/bin/perl
## Script written and mantained by GI

if( $#ARGV == -1 || $ARGV[0] =~ /^--?h(elp)?$/ ) {
	# HELP
	print " Usage: checkjob job_name [username [iTunes arg]]\n";
	print " Rings a bell when the given job is finished\n";
	print " Default username is \$USER\n";
	print " If iTunes arg is given, will perform it when job is done\n";
	print " (see iTunes command help for more infos).\n";
	exit 8;
}

$user = `echo \$USER`;
chomp($user);
$job = shift( @ARGV );
if( $#ARGV >= 0 ) {
	$user = shift(@ARGV);
}
$iTunes = "";
if( $#ARGV >= 0 ) {
	$iTunes = shift(@ARGV);
}
# sleep delay [s]
$sleep = 10;
if( $job =~ m/checkjob/ ) {
	print "Sorry, this program can't watch itself...\n\a";
} else {
	$psjob = "";
	$pid = "0";
	@ps = `ps u -au $user`;
	shift(@ps);
	foreach $i( @ps ) {
		chomp($i);
		if( $i =~ /$job/ && $i !~ /checkjob\.pl/ ) {
			$header = $ps[0];
			chomp($header);
			$psjob = "$header\n$i";
			$pid = $i;
			$pid =~ s/^.[^ ]+[ \t]+//;
			$pid =~ s/[ \t]+.*$//;
		}
	}
	if( $pid eq "0" ) {
		print " Sorry, job not found...\n";
	} else {
		print " Ringing a bell ";
		if( $iTunes ne "" ) {
			print "and making iTunes $iTunes ";
		}
		print "when job '$job' from user '$user' (pid $pid) will be completed:\n";
		print "  $psjob\n";
		print "    (Checking every $sleep seconds)\n ";
		$good = 1;
		$first = 1;
		while( $good ) {
			$good = 0;
			@ps = `ps u -ap $pid`;
			shift(@ps);
			foreach $i( @ps ) {
				chomp($i);
				if( $i =~ /$job/ && $i !~ /checkjob\.pl/ ) {
					$good = 1;
					$pid = $i;
					$pid =~ s/^.[^ ]+[ \t]+//;
					$pid =~ s/[ \t]+.*$//;
					if( $first ) {
						$first = 0;
						#print "$i\n";
					}
				}
			}
			if( $good ) {
				sleep( $sleep );
			}
		}
		print "\a\a\a   Done !\n";
		if( $iTunes ne "" ) {
			#system("iTunes",$iTunes);## Not working, not in path...
		}
	}
}

exit 0;

