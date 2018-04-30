#!/usr/bin/perl
use strict;
use warnings;
use POSIX;
use Proc::Daemon;

my $HSH = $ENV{"HSH"};
my $vash = $ENV{"vash"};
require "$vash/perl/readrec.pl";
require "$vash/perl/BadFilesCheck.pl";

my $debug = 0;
while($#ARGV > -1 && $ARGV[0] =~ /^-/) {
	my $a = shift(@ARGV);
	if($a =~ /^--?d(ebug)?$/) {
		$debug = 1;
	} else {
		die(" Argument $a not recognized...");
	}
}

## TODO:
## Use cloneDir sub to clone recursive
## Check if lockfile still there and print error somewhere if not

my $continue = 1;

$SIG{TERM} = sub{$continue = 0;};
$SIG{INT } = sub{$continue = 0;};
#$SIG{KILL} = sub{$continue = 0;};
## Cannot catch it...

my $lockfile = "/tmp/Qruns.now";
my $cpdir    = "/home/induni/Desktop/.SolDo";
my $logfile  = "$cpdir/Q.log";
my $Qdir     = "/media/Q";
my $pid = 0;
my $satan = undef;

if(!-f "$lockfile") {
	if(!$debug) {
		Proc::Daemon::Init;
		##$pid = Proc::Daemon::Init;
		#$satan = Proc::Daemon->new(
			##work_dir => "/tmp",
			##child_STDOUT => "+>>/tmp/Q.out",
			##child_STRERR => "+>>/tmp/Q.err",
			##pid_file     => $lockfile
		#);
		#$pid = $satan->Init();
	}
	open(my $LOG, ">>", "$logfile") or die(" Cannot append to log file $logfile...");
	if(!$debug) {
		*STDOUT = *LOG;
		*STDERR = *LOG;
	}
	open(my $LOCK, ">", "$lockfile") or die(" Cannot write lockfile $lockfile");
	print $LOCK $pid;
	close($LOCK);
	##
	close($LOG);
	##
	my $delay = 30;# * 2;
	if($debug) {
		$delay = 1;
	}
	##
	while($continue && -f "$lockfile" ) {
		## Open log file (not opened all the time)
		open(my $LOG, ">>", "$logfile") or die(" Cannot append to log file $logfile...");
		if(!$debug) {
			*STDOUT = *LOG;
			*STDERR = *LOG;
		}
		## Read the directory
		my @files = readdirs($Qdir);
		if($debug) {
			print " Directory $Qdir contents known\n";
		}
		## Get today's date
		my $today = strftime("%Y%m%d", localtime);
		## Loop through the files
		foreach my $f(@files) {
			chomp($f);
			$f =~ s/^${Qdir}\///;
			#if($debug) {
				#print " Considering file '$f'\n";
			#}
			if($f !~ /^\.\.?$/ && $f !~ /\/Thumbs\.db$/) {
				#if($debug) {
					#print "   Valid\n";
				#}
				## Get the timestamp
				my $timestamp = strftime("%Y-%m-%d %H:%M:%S", localtime);
				## Fix the filename
				(my $newf = $f) =~ s/ /_/g;
				#$newf =~ s/\.([^.]*)$/ZgRLmFHeReCoMEsTHeSuN$1/;
				#$newf =~ s/\./_/g;
				#$newf =~ s/ZgRLmFHeReCoMEsTHeSuN/./;
				#$newf =~ s/[()\[\],;:'"<>%&]//g;
				$newf =~ s/[^A-Za-z0-9_.\/-]//g;
				$newf =~ s/(\$|#)//g;
				$newf =~ s/__/_/g;
				$newf = "$today/$newf";
				if($debug) {
					#print "     New name: $newf\n";
					print " $f\n";
					print "   -> $newf\n";
				}
				if($newf =~ /\//) {
					(my $checkDir = "$cpdir/$newf") =~ s/\/[^\/]*$//;
					if(!-d "$checkDir") {
						system("mkdir", "-p", "$checkDir");
					}
				}
				#if(!-e "$cpdir/$newf") {
					#if($debug) {
						#print "     Not already present\n";
					#}
					if(!-d "$cpdir/$today") {
						(my $todaystamp = $timestamp) =~ s/ .*$//;
						print $LOG "\n";
						print $LOG "\n";
						print $LOG "    *** $todaystamp ***\n";
						print $LOG "\n";
					}
					if(system("mkdir", "-p", "$cpdir/$today")) {
						die(" Could not create today's directory...");
					}
					my @output = ();
					(my $cpf = $f) =~ s/\$/\\\$/g;
					if(-d "$Qdir/$f") {
						@output = `mkdir -pv \"$Qdir/$cpf\" \"$cpdir/$newf\"`;
					} else {
						@output = `cp -puv \"$Qdir/$cpf\" \"$cpdir/$newf\"`;
					}
					if($?) {
						print $LOG "# $timestamp ##### Cannot copy $f\n";
						if($debug) {
							print "# $timestamp ##### Cannot copy $f\n";
						}
					}
					foreach my $l(@output) {
						chomp($l);
						#(my $ll = $l) =~ s/^.*-> `${cpdir}\/${today}\///;
						(my $ll = $l) =~ s/^.*${cpdir}\/${today}\///;
						$ll =~ s/['’]$//;
						print $LOG "$timestamp   $ll\n";
						if( ${debug} ) {
							print "$timestamp   $l\n";
						}
					}
				#}
			}
		}
		## Sleep before beginning again
		sleep($delay);
		##
		## For debug purpose:
		if($debug) {
			$continue = 0;
		}
		close($LOG);
	}
	if(system("rm", "$lockfile")) {
		die(" ?!? I didn't even noticed someone killed me...");
		#die(" Could not remove lock file ${lockfile} on exit");
	}
} elsif($debug) {
	print " Process is already running (or seems so).\n";
} else {
	print " I will not buy this record, it is scratched!\n";
}

exit 0;
