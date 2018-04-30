#!/usr/bin/perl
## Script written and mantained by GI
## Used to run LaTeX compilations. Checks if the .aux file has changed. Can also check if the idx file has changed.

## Improvement way: check the log file for warnings (not too much because of undef ref), citation undef, for ref, tables...

## TODO {{
## add debug option
## use strict warnings my
## Must remove aux file when nothing needs to be done!!!
## Warning: include (not input) files also generates aux files, must take them in bktex
## When first time, needs bib
## Could determine itself which beamer mode it is
## Add 'my' declarations
## Look for citation undef in log to rerun bib ONCE
## Look for sty files in the working directory
## When adding TOC after the first run, error because of toc file
## Check the way it checks bibtex needs to be run
## WARNING: may be more than one bibtex file, separated by commas on inline (l.790 @bibs)
## (seems to never get to l.570...) (oops, had defined new command with bib :-S)
## when checking if run needed, stop if true
## Treat problems from after the latex command differently so I don;t have to redo the run
## Stop copying the bib file and only check if more recent (all of them)
## If dead, keep the kept files in bktex as they were
## If interrupted while doing an eps, rm it
## Finish option to have dvips muted or not
## Keep the aux files from before if failed before dvips
## Check if lapd files also newer than PDF
## Fix chmod
## Do it more efficient (if condition found, break the loop)
## Make sub to help structure this script
## If found smth that implies a run, stop checking and run!!
## Should check why it always runs 3-4 times... (rip, bib)
## Shoud look on class and packages if present in curdir and check for -w (at least)
## Should save log always?
## Must handle regexp in file_ext
## if bktex files exist and ./files too, rm latter and use former
## check log for: LaTeX Warning: Label(s) may have changed. Rerun to get cross-references right.
## Must run bibtex only if there is a bib *line*, file present does not mean used (error)
## if aux in curdir and .texst, use latter since more reliable
## add option in .lapd for exotic commands to be recognized as includegraphics
## backinp up kept files is not optimal
##   Must do one sub for ext to get back and one for ext to move away
## when dying, check if aux has different select@language. If so, keep new one
## }}}

sub open_failed_die;

## Help {{{
if($#ARGV == -1 || ($#ARGV > -1 && $ARGV[0] =~ /^--?h(elp)?$/)) {
	if($#ARGV > -1) {
		shift(@ARGV);
		if($#ARGV > -1) {
			## Help conf files {{{
			if($ARGV[0] =~ /^conf$/) {
				print "  To set global arguments for all the files of the directory,\n";
				print "    write them in the file 'latexpawa.lapd'.\n";
				print "  To set arguments specific to each file, set them in 'filename.lapd'.\n";
				print "\n";
				print "  For arguments requiring a value, write the argument name followed by\n";
				print "    a semi-colon and the value.\n";
				print "  Arguments that are logical should be set only as 'arg'. If\n";
				print "    the default is true and you want to set it to false, you\n";
				print "    can write 'arg: 0'.\n";
				print "  The arguments must be on separated lines.\n";
				print "  Commented lines (beginning with #) are ignored.\n";
				print "\n";
				print "  The arguments that are recognized are the following:\n";
				print "    - 'pf' = (a|b)[0-9] or letter, legal, tavloid, statement, executive,\n";
				print "             folio, quarto, 10x14 (psnup output paper format)\n";
				print "    - 'N' = x\n";
				print "    - 'slides'  for slides mode when writing a beamer document\n";
				print "    - 'handout' idem\n";
				print "    - 'notes'   idem\n";
				print "    - 'no_rotate' to prevent ps2pdf to automatically rotate your pages\n";
				print "                  (useful when working with graphs containing 90deg text)\n";
				print "    - 'cp' = cp path\n";
				print "    - 'mv' = mv path. Be careful: since the PDF won't be at its original\n";
				print "             location anymore, the script will always rerun the latex command.\n";
				print "    - 'chmod' to do chmod u+w before cp/mv and chmod a-w after\n";
				print "    - 'force-run' to force latex to run again\n";
				print "      (this should not be let permanently in a conf file)\n";
				print "    - 'open' = (true|false) to open the PDF when ready\n";
				print "\n";
				print "  You can also provide different arguments for the same file with\n";
				print "    different output filenames.\n";
				print "  You specify each time the output filename (PDF) except for the\n";
				print "    default case (must be present) which will be the input filename:\n";
				print "    case file1.pdf\n";
				print "       arg1: blabla1\n";
				print "       arg2: blabla2\n";
				print "       arg3\n";
				print "    break\n";
				print "    case file2.pdf\n";
				print "       arg1: blabla4\n";
				print "       arg3\n";
				print "    break\n";
				print "    default\n";
				print "       arg1: blabla1\n";
				print "       arg2: blabla5\n";
				print "    break\n";
				print "\n";
				exit 8;
			}
			## }}}
		}
	}
	## Display help, explain usage
	print "  This is LaTeX Pawa!!!!!!!!!!\n";
	print "    Usage: latexpawa\n";
	print "               [--pf=((a|b)[0-9]|letter|legal|tabloid|statement|executive|\n";
	print "                     folio|quarto|10x14)]     (psnup output paper format)\n";
	print "               [-N/--slides/--handout/--notes]\n";
	print "               [--no_rotate]\n";
	print "               [--cp=cp_path]\n";
	print "               [--mv=mv_path]\n";
	print "               [--chmod]\n";
	print "               [--force-run]\n";
	print "               [--no-open]\n";
	print "             filename.tex\n";
	print "               [output_filename.pdf]\n";
	print "\n";
	print "  These arguments can also be set in a configuration file.\n";
	print "  See latexpawa --help conf\n";
	print "\n";
	print "  This script will cleverly print the PDF from a given tex file.\n";
	print "  It will redo a LaTeX compilation if needed, compile bib and index,\n";
	print "   do the needed pictures in eps.\n";
	print "\n";
	exit 8;
}
## }}}

$OS = `uname | cut -b 1-6`;
## Setting path to script from execution {{{
my $curpath = ".";
if($0 =~ /\//) {
	($curpath = $0) =~ s/\/[^\/]*$//;
}
## }}}
## Getting fundamental vars {{{
require "$curpath/ext_latex.pl";
require "$curpath/system_die.pl";
$bktex_dir = latex_bktex_dir();
my $Restoroute = "_RESTORE_THIS_SPACE_";
## }}}
## Get the TeX filename {{{
$output_filename[0] = "";

$filename = pop(@ARGV);
if($filename =~ /\.pdf$/) {
	$output_filename[0] = $filename;
	$filename = pop(@ARGV);
}
if($filename !~ /\.tex$/) {
	die("No tex filename well provided...\n");
}
## Remove extension
$filename =~ s/\.tex$//;
## }}}
## File extensions to move {{{
@kept_exts = latex_kept_exts();
@file_exts = latex_tmp_exts();
@half_exts = latex_half_exts();
## }}}

## Is this the general trap function or only when the signal interrupt is caught??
## Trap function {{{
$SIG{INT} = sub {
	opendir($CUD, ".");
	@cur_content = readdir($CUD);
	closedir($CUD);
	foreach $curfile(@cur_content) {
		chomp($curfile);
		if($curfile !~ /^\.\.?$/) {
			foreach $f(@kept_exts) {
				$g = regex2shell_ext($f);
				if($curfile =~ /$filename\.$f$/) {
					@flies = glob("$filename.$g");
					foreach $bee(@flies) {
						system("rm","$bee");
					}
				}
			}
			foreach $f(@file_exts) {
				$g = regex2shell_ext($f);
				if($curfile =~ /$filename\.$f$/) {
					@flies = glob("$filename.$g");
					foreach $bee(@flies) {
						system("rm","$bee");
					}
				}
			}
			foreach $f(@half_exts) {
				$g = regex2shell_ext($f);
				if($curfile =~ /$filename\.$f$/) {
					@flies = glob("$filename.$g");
					foreach $bee(@flies) {
						system("rm","$bee");
					}
				}
			}
		}
	}
	die("\n   Burn, witch!!!!\n\n");## Er........................
};
## }}}

## Preliminary display
print "\n   ***** You are currently running LaTeX PaWaAa !! *****\n\n";

## Checking if directory exists {{{
if(! -d "$bktex_dir") {
	print "  Creating $bktex_dir directory...\n";
	if(system("mkdir","$bktex_dir") != 0) {
		die(" Cannot create $bktext_dir directory...");
	}
	#system_return("mkdir","$bktex_dir","zgrlmf",LOG,"Cannot create $bktex_dir directory...");
}
## }}}

## Opening Perl log file {{{
$log_file = "$bktex_dir/$filename.plg";
open(LOG,">",$log_file) or die(" Cannot open log file $log_file");
## }}}

## Prefix char {{{
$prefix{"perl"}             = "# ";
$prefix{"perl args"}        = "& ";
$prefix{"log"}              = "- ";
$prefix{"latex"}            = "@ ";
$prefix{"shell"}            = "\$ ";
$prefix{"bibtex makeindex"} = "% ";
#$prefix{} = "*";
#$prefix{} = "+";
#$prefix{} = "=";
$prefix{"debug"}            = "G ";
$prefix{"default"}          = " d";
$prefix{"killed"}           = "xx";

print LOG "##############################\n";
print LOG "   Legend:\n";
while(($key, $val) = each(%prefix)) {
	print LOG "      $val $key\n";
}
print LOG "##############################\n";
print LOG "\n";
## }}}

## Script variables {{{
$def{"paper_format"} = "a4";
$def{"pinup"} = 1;
$def{"no_rotate"} = 0;
$def{"cp_path"} = "";
$def{"mv_path"} = "";
$def{"must_run"} = 0;
$def{"do_open"} = 1;
$def{"is_notes"} = 0;
$def{"dvipsmute"} = 1;
$def{"chmod"} = 0;
## }}}
## Default for script variables {{{
$paper_format[0] = $def{"paper_format"};
$pinup[0] = $def{"pinup"};
$no_rotate[0] = $def{"no_rotate"};
$cp_path[0] = $def{"cp_path"};
$mv_path[0] = $def{"mv_path"};
$must_run[0] = $def{"must_run"};
$do_open[0] = $def{"do_open"};
$is_notes[0] = $def{"is_notes"};
$dvipsmute[0] = $def{"dvipsmute"};
$chmod[0] = $def{"chmod"};
## }}}

$do_many[0] = 0;
$do_among = 0;
$i_among = 0;

## Reading conf files {{{
@lapd = ("latexpawa",$filename);
foreach $file(@lapd) {
	if(-f "$file.lapd") {
		print LOG "&  Reading $file.lapd conf file...\n";
		open(INS, "$file.lapd") or open_failed_die(LOG,"open","$file.lapd");
		@ins = <INS>;
		close(INS);
		$first = $ins[0];
		chomp($first);
		if($first =~ /^\t*case / || $first =~ /^\t*default$/) {
			$do_many = 1;
			print LOG "#  Many cases to do.\n";
		} else {
			$do_among = 1;
		}
		foreach $param_line(@ins) {
			chomp($param_line);
			if($param_line !~ /^\s*#/) {## Commented lines are ignored
				if($do_among == 0) {
					#die("Missing stop argument 106... Stay blocked in script. Must try to write arguments in list and run until end of list\n\n");
					if($param_line =~ /^\t*case / || $param_line =~ /^\t*default$/) {
						$do_among = 1;
						$this_i = $i_among + 1;
						print LOG "#   Treating case $this_i...\n";
						if($param_line =~ /^\t*case /) {
							## output filename
							$output_filename[$i_among] = $param_line;
							$output_filename[$i_among] =~ s/^\t*case *//;
							if($output_filename[$i_among] !~ /\.pdf$/) {
								print LOG "-  Output filename must be a PDF...\n";
								die("Output filename must be a PDF...\n");
							}
						} else {
							$output_filename[$i_among] = "$filename.pdf";
						}
					}
				} else {
					if($param_line =~ /^\t*break$/) {
						## Check if all arguments set, if not set to default
						### Arguments to check: pinup paper_format no_rotate cp_path mv_path do_open must_run output_filename chmod
						@check_args = ("paper_format","pinup","no_rotate","cp_path","mv_path","must_run","do_open","chmod");
						if($#output_filename < $i_among) {
							$output_filename[$i_among] = "$filename.pdf";
						}
						foreach $ca(@check_args) {
							if($#$ca < $i_among) {
								$$ca[$i_among] = $def{$ca};
								print LOG "&d Setting $ca to default value $def[$ca]\n";
							}
						}
						## End of this case
						$do_among = 0;
						$i_among++;
					} else {
						if($param_line =~ /:/) {
							$param_name = $param_line;
							$param_name =~ s/ *:[^:]*$//;
							$param_name =~ s/^\t+//;
							$param_val  = $param_line;
							$param_val  =~ s/^[^:]*: *//;
							if($param_val =~ /^true$/) {
								$param_val = 1;
							} elsif($param_val =~ /^false$/) {
								$param_val = 0;
							}
						} else {
							$param_name = $param_line;
							$param_name =~ s/^\t+//;
							undef $param_val;
						}
						##
						## N {{{
						if($param_name eq "N") {
							$pinup[$i_among] = $param_val;
							print LOG "&  Setting $pinup[$i_among] page(s) per sheet.\n";
						## }}}
						## slides {{{
						} elsif($param_name eq "slides") {
							if(defined($param_val)) {
								if($param_val) {
									$no_rotate[$i_among] = 1;
									print LOG "&  Mode -slides-, setting no_rotate.\n";
								}
							} else {
								$no_rotate[$i_among] = 1;
								print LOG "&  Mode -slides-, setting no_rotate.\n";
							}
						## }}}
						## handout {{{
						} elsif($param_name eq "handout") {
							if(defined($param_val)) {
								if($param_val) {
									$pinup[$i_among] = -2;
									$no_rotate[$i_among] = 1;
									print LOG "&  Mode -handout-, setting no_rotate and 2 pages per sheet.\n";
								}
							} else {
								$pinup[$i_among] = -2;
								$no_rotate[$i_among] = 1;
								print LOG "&  Mode -handout-, setting no_rotate and 2 pages per sheet.\n";
							}
						## }}}
						## notes {{{
						} elsif($param_name eq "notes") {
							if(defined($param_val)) {
								if($param_val) {
									$pinup[$i_among] = -4;
									$no_rotate[$i_among] = 1;
									$is_notes[$i_among] = 1;
									print LOG "&  Mode -notes-, setting no_rotate and 4 pages per sheet.\n";
								}
							} else {
								$pinup[$i_among] = -4;
								$no_rotate[$i_among] = 1;
								$is_notes[$i_among] = 1;
								print LOG "&  Mode -notes-, setting no_rotate and 4 pages per sheet.\n";
							}
						## }}}
						## no_rotate {{{
						} elsif($param_name eq "no_rotate") {
							if(defined($param_val)) {
								if($param_val) {
									$no_rotate[$i_among] = 1;
									print LOG "&  Setting no_rotate.\n";
								}
							} else {
								$no_rotate[$i_among] = 1;
								print LOG "&  Setting no_rotate.\n";
							}
						## }}}
						## cp {{{
						} elsif($param_name eq "cp") {
							$cp_path[$i_among] = $param_val;
							print LOG "&  Setting copy path to $cp_path[$i_among]\n";
						## }}}
						## mv {{{
						} elsif($param_name eq "mv") {
							$mv_path[$i_among] = $param_val;
							print LOG "&  Setting moving path to $mv_path[$i_among]\n";
						## }}}
						## chmod {{{
						} elsif($param_name eq "chmod") {
							if(defined($param_val)) {
								if($param_val) {
									$chmod[$i_among] = 1;
									print LOG "&  Setting chmod\n";
								}
							} else {
								$chmod[$i_among] = 1;
								print LOG "&  Setting chmod\n";
							}
						## }}}
						## force-run {{{
						} elsif($param_name eq "force-run") {
							if(defined($param_val)) {
								if($param_val) {
									$must_run[$i_among] = 1;
									print LOG "&  Force rerun.\n";
								}
							} else {
								$must_run[$i_among] = 1;
								print LOG "&  Force rerun.\n";
							}           
						## }}}
						## open {{{
						} elsif($param_name eq "open") {
							if(defined($param_val)) {
								if(!$param_val) {
									$do_open[$i_among] = 0;
									print LOG "&  Asking NOT to open the PDF when done.\n";
								}
							}
						## }}}
						## pf {{{
						} elsif($param_name eq "pf") {
							$paper_format[$i_among] = $param_val;
							print LOG "&  Setting paper format to be $paper_format[$i_among].\n";
						## }}}
						## dvipsmute {{{
						} elsif($param_name eq "dvipsmute") {
							$dvipsmute[$i_among] = $param_val;
							print LOG "&  Setting dvipsmute to $param_val\n";
						## }}}
						## default
						} else {
							print LOG "&  Argument $param_name not recognized...\n";
							die("  Argument $param_name not recognized...\n");
						}
					}
				}
			}
		}
		print LOG "\n";
	}
}
## }}}
## Read arguments list (must be done AFTER reading conf (lapd) files) {{{
if($#ARGV > -1) {
	while($#ARGV > -1) {
		print LOG "&  Reading arguments...\n";
		$param = shift(@ARGV);
		if($param =~ /^-[0-9]+$/) {
			$pinup[0] = $param;
			$pinup[0] =~ s/^-//;
			print LOG "&  Setting $pinup page(s) per sheet.\n";
		} elsif($param =~ /^--slides$/) {
			$no_rotate[0] = 1;
			print LOG "&  Mode -slides-, setting no_rotate.\n";
		} elsif($param =~ /^--handout$/) {
			$pinup[0] = -2;
			$no_rotate[0] = 1;
			print LOG "&  Mode -handout-, setting no_rotate and 2 pages per sheet.\n";
		} elsif($param =~ /^--notes$/) {
			$pinup[0] = -4;
			$no_rotate[0] = 1;
			$is_notes[0] = 1;
			print LOG "&  Mode -notes-, setting no_rotate and 4 pages per sheet.\n";
		} elsif($param =~ /^--no_rotate$/) {
			$no_rotate[0] = 1;
			print LOG "&  Setting no_rotate.\n";
		} elsif($param =~ /^--cp=/) {
			$cp_path[0] = $param;
			$cp_path[0] =~ s/^--cp=//;
			print LOG "&  Setting copy path to $cp_path\n";
		} elsif($param =~ /^--mv=/) {
			$mv_path[0] = $param;
			$mv_path[0] =~ s/^--mv=//;
			print LOG "&  Setting moving path to $mv_path\n";
		} elsif($param =~ /^--chmod$/) {
			$chmod[0] = 1;
			print LOG "&  Setting chmod\n";
		} elsif($param =~ /^--force-run$/) {
			$must_run[0] = 1;
			print LOG "&  Force rerun.\n";
		} elsif($param =~ /^--no-open$/) {
			$do_open[0] = 0;
			print LOG "&  Asking NOT to open the PDF when done.\n";
		} elsif($param =~ /^--pf=((a|b)[0-9]|letter|legal|tabloid|statement|executive|folio|quarto|10x14)$/) {
			$paper_format[0] = $param;
			$paper_format[0] =~ s/^--pf=//;
			print LOG "&  Setting paper format to be $paper_format.\n";
		} elsif($param =~ /^--dvipsmute/) {
			($pvl = $param) =~ s/^--dvipsmute=?//;
			if($pvl eq "" || $pvl eq "true") {
				$dvipsmute[0] = 1;
			} elsif($pvl eq "false") {
				$dvipsmute[0] = 0;
			}
		} else {
			print LOG "&  Argument $param_name not recognized...\n";
			die("  Argument $param not recognized...\n");
		}
	}
	print LOG "\n";
}
## }}}
## Loop through all cases asked {{{
for($ix = 0; $ix <= $#pinup; $ix++) {
	$bib_update = 0;
	$rerun = 0;
	$do_bib = 0;
	## Set default output filename (security) {{{
	if($output_filename[$ix] eq "") {
		$output_filename[$ix] = "$filename.pdf";
	}
	## }}}
	## If more than one case, give information where we are {{{
	if($#pinup > 0) {
		$this_i = $ix + 1;
		$all_i  = $#pinup + 1;
		print LOG "\n#  Running case $this_i of $all_i\n";
	}
	## }}}
	## Special treatement if treating notes from a presentation {{{
	if($is_notes[$ix]) {
		$all_filename = "$filename.aux";
		$all_filename =~ s/notes\.aux/all.aux/;
		$both_filename = "$filename.aux";
		$both_filename =~ s/notes\.aux/both.aux/;
		if(! -f "$all_filename" && ! -f "$bktex_dir/$all_filename" && ! -f "$both_filename" && ! -f "$bktex_dir/$both_filename") {
			$errmess = "#  No all/both aux file detected...\n";
			print LOG $errmess;
			die($errmess);
		} else {
			if(-f "$all_filename") {
				print LOG "#  Copying $all_filename...\n";
				system_return("cp",$all_filename,"$filename.aux","zgrlmf","Cannot copy $all_filename to $filename.aux...");
			} elsif(-f "$bktex_dir/$all_filename") {
				print LOG "#  Copying $bktex_dir/$all_filename...\n";
				system_return("cp","$bktex_dir/$all_filename","$bktex_dir/$filename.aux","zgrlmf","Cannot copy $all_filename to $filename.aux inside $bktex_dir directory...");
			} elsif(-f "$both_filename") {
				print LOG "#  Copying $both_filename...\n";
				system_return("cp",$both_filename,"$filename.aux","zgrlmf","Cannot copy $both_filename to $filename.aux...");
			} elsif(-f "$bktex_dir/$both_filename") {
				print LOG "#  Copying $bktex_dir/$both_filename...\n";
				system_return("cp","$bktex_dir/$both_filename","$bktex_dir/$filename.aux","zgrlmf","Cannot copy $both_filename to $filename.aux inside $bktex_dir directory...");
			}
		}
	}
	## }}}

	@includes = ("$filename.tex");
	my @aux_includes = ($filename);
	@bibs = ();
	## Reading filename to check input and include (with aux) {{{
	print "    Reading $filename.tex...\n";
	open(REP, "<", "$filename.tex") or open_failed_die(LOG, "read", "$filename.tex");
	@rep = <REP>;
	close(REP);
	$repinline = join(' ',@rep);
	$repinline =~ s/  +/ /g;
	chomp($repinline);
	@repsplit = split(' ',$repinline);
	foreach $r(@repsplit) {
		my $aux = 0;
		chomp($r);
		if($r =~ /^\\/ && $r !~ /\#/) {
			if($r =~ /in(clude|put)\{/) {
				if($r =~ /include\{/) {
					$aux = 1;
				}
				## Check also for input/include files.tex
				$r =~ s/^.*in(clude|put)\{([^}]*)\}.*$/$2/;
				#if($r !~ /\.tex$/) {
				if($r !~ /\./) {
					$r = "$r.tex";
				}
				if($r !~ /\\/) {
					push(@includes, $r);
					if($aux) {
						$r =~ s/\.tex$//;
						if($r ~~ @aux_includes) {
							print LOG "G  aux_includes has $r\n";
						} else {
							print LOG "G  aux_includes[] = $r\n";
							push(@aux_includes, $r);
						}
					}
					####### TRY TO IMPROVE BIB MANAGEMENT #######
				}
			}
		}
	}
	## }}}
	## Read each file to check for listing, aux, pic, bib {{{
	foreach $tex_file(@includes) {
		print LOG "#  Reading $tex_file to check its content...\n";
		open(TEX,"<",$tex_file) or open_failed_die(LOG, "read", $tex_file);
		#print LOG "G  open\n";
		@this_content = <TEX>;
		#print LOG "G  read\n";
		close(TEX);
		#print LOG "G  closed\n";
		$this_inline = join(' ',@this_content);
		$this_inline =~ s/  +/ /g;
		$this_inline =~ s/\\subfloat\[[^\]]*\]\{//g;
		$this_inline =~ s/\\(only|uncover)<[^>]*>\{//g;
		## Taking care of pic name with spaces:
		while($this_inline =~ /includegraphics(\[[^\]]*\])?{"[^"]* [^"]*"}/) {
			$this_inline =~ s/(includegraphics(\[[^\]]*\])?{"[^"]*) ([^"]*"})/$1$Restoroute$3/g;
		}
		chomp($this_inline);
		@this_split = split(' ',$this_inline);
		foreach $r(@this_split) {
			## Not necessary but insurance
			chomp($r);
			## Restore spaces in filenames of pics
			$r =~ s/${Restoroute}/ /g;
			##
			my $aux = 0;
			## Check if other included files are found but in filename
			if($r =~ /^\\/ && $r !~ /\#/ && $r =~ /in(clude|put)\{/ && $tex_file ne "$filename.tex") {
				if($r =~ /include\{/) {
					$aux = 1;
				}
				$newfile = $r;
				$newfile =~ s/^.*in(clude|put)\{([^}]*)\}.*$/$2/;
				#if($newfile !~ /\.tex$/) {
				if($newfile !~ /\./) {
					$newfile = "$newfile.tex";
				}
				push(@includes, $newfile);
				if($aux) {
					$newfile =~ s/\.tex$//;
					push(@aux_includes, $newfile);
				}
			}
			## Check for bibliography
			if($r =~ /^\\/ && $r !~ /\#/ && $r =~ /bibliography\{/) {
				$bib = $r;
				$bib =~ s/^.*bibliography\{([^}]*)\}.*$/$1/;
				print LOG "G bibs:\n";
				if($bib =~ /,/) {
					## More than one!!!
					@allbibs = split(",", $bib);
					foreach my $bb(@allbibs) {
						if($bb !~ /\.bib$/) {
							$bb = "$bb.bib";
						}
						print LOG "G $bb\n";
						push(@bibs, $bb);
						if((-M "$bb") < (-M "$output_filename[$ix]")) {
							$must_run = 2;
							$bib_update = 1;
							$do_bib = 1;
							$rerun = 2;
							print LOG "-  Bib file $bb is more recent than the output...\n";
						}
					}
				} else {
					if($bib !~ /\.bib$/) {
						$bib = "$bib.bib";
					}
					print LOG "G $bib\n";
					push(@bibs, $bib);
					if((-M "$bib") < (-M "$output_filename[$ix]")) {
						$must_run = 2;
						$bib_update = 1;
						$do_bib = 1;
						$rerun = 2;
						print LOG "-  Bib file $bib is more recent than the output...\n";
					} else {
						print LOG "G  Bib file $bib is old enough :)\n";
					}
				}
			}
			## Check if there is a listing
			if($r =~ /^\\/ && $r !~ /\#/ && $r =~ /lstinputlisting/) {
				$lst = $r;
				$lst =~ s/^\\lstinputlisting\[[^\]]*]\{([^}]*)\}.*$/$1/;
				#$lst =~ s/}.*$//;
				$code = $lst;
				if((-M "$code") < (-M "$output_filename[$ix]")) {
					if($must_run < 1) {
						$must_run = 1;
					}
					print LOG "-  Listing $code is more recent than the output...\n";
				}
			}
			## Check for pictures
			if($r =~ /^\\.*includegraphics/ && $r !~ /\#/ && $r !~ /@/) {
			# Standard case #
				$newpic = $r;
				#print LOG "G  $newpic\n";
				if($newpic =~ /includegraphics\[/) {
					#print LOG "G  includegraphics with optional arg\n";
					$newpic =~ s/^.*includegraphics\[[^\]]*\]\{"?([^}"]*)"?\}.*$/$1/;
				} else {
					#print LOG "G  includegraphics naked\n";
					$newpic =~ s/^.*includegraphics\{"?([^}"]*)"?\}.*$/$1/;
				}
				#print LOG "G  $newpic\n";
				#$newpic =~ s/^.*includegraphics(\[[^\]]*\])?\{([^}]*)\}.*$/$2/;
				#$newpic =~ s/\}+.*$//;
				$epsname = $newpic;
				#if($epsname =~ /\.eps$/) {## if using other types of pics, but should not happen
					$psname = $epsname;
					$psname =~ s/\.eps$/\.ps/;
					if(! -f $psname && ! -f $epsname) {
						$diestring = "*** No .ps nor .eps file found for $epsname... ***\n";
						print LOG $diestring;
						die($diestring);
					}
					if(-f $psname && (! -f $epsname || (-M "$epsname") > (-M "$psname"))) {
						if($must_run < 1) {
							$must_run = 1;
						}
						## Do ps2eps (must check which one)
						print LOG "\$  Updating picture $epsname...\n";
						system_return("ps2eps","-f",$psname ,"zgrlmf",LOG,"Cannot ps2eps $psname...");
					} elsif(-f $epsname && ((-M "$epsname") < (-M "$output_filename[$ix]"))) {
						if($must_run < 1) {
							$must_run = 1;
						}
						print LOG "-  Picture $epsname is more recent than the output...\n";
					}
				#}
			}
		}
	}
	## }}}

	## if .aux not exists, run latex {{{
	if(!-e "$bktex_dir/$filename.aux" && !-e "$filename.aux") {
		print LOG "@  1st run ever...\n";
		system_return("latex","$filename.tex","zgrlmf",LOG,"LaTeX failed...");
	}
	## }}}

	## Check if PDF exists and whether a tex file is more recent than the PDF {{{
	#if(defined($output_filename[$ix])) {
		if(!-f $output_filename[$ix]) {
			if($must_run < 1) {
				$must_run = 1;
			}
			print LOG "- $output_filename[$ix] does not exist yet...\n";
		} else {
	#}
	## }}
	## Running LaTeX if needed {{
	#if(-f $output_filename[$ix]) {
		foreach $file(@includes) {
			if((-M "$file") < (-M $output_filename[$ix])) {
				if($must_run < 1) {
					$must_run = 1;
				}
				print LOG "-  $file is more recent than the output...\n";
			}
		}
	}
	## }}}
	if($must_run) {
		## Before running, getting the aux files {{{
		if(!-e "$filename.aux") {
			print LOG "\$  Get back $bktex_dir/$filename.aux (.aux)...\n";
			system_return("cp","$bktex_dir/$filename.aux","$filename.aux","zgrlmf",LOG,"Cannot get $filename.aux back");
			foreach my $aux(@aux_includes) {
				print LOG "\$  Get back $bktex_dir/$aux.aux (.aux)...\n";
				system("cp","$bktex_dir/$aux.aux","$aux.aux");
			}
			## @exts = (); foreach @exts sys_return...
			if(-e "$bktex_dir/$filename.toc") {
				print LOG "\$  Get back $bktex_dir/$filename.toc (.toc)...\n";
				system_return("cp","$bktex_dir/$filename.toc","$filename.toc","zgrlmf",LOG,"Cannot get $filename.toc back");
			}
			if(-e "$bktex_dir/$filename.idx") {
				print LOG "\$  Get back $bktex_dir/$filename.idx (.idx)...\n";
				system_return("cp","$bktex_dir/$filename.idx","$filename.idx","zgrlmf",LOG,"Cannot get $filename.idx back");
			}
			## checking file_exts
			opendir($BKD, "$bktex_dir") or open_failed_die(LOG, "readdir", "$bktex_dir");
			@bkcont = readdir($BKD);
			closedir($BKD);
			foreach $bkfile(@bkcont) {
				if($bkfile !~ /^\.\.?$/) {
					#print LOG "G  bktex file $bkfile\n";
					foreach $ext(@file_exts) {
						$sext = regex2shell_ext($ext);
						#if($ext ne $sext) {
							#print LOG "G  ext $ext - sext $sext\n";
						#}
						if($bkfile =~ /${filename}\.${ext}$/) {
							#print LOG "G  file match!\n";
							@flies = glob("$bktex_dir/$filename.$sext");
							foreach $bee(@flies) {
								($wasp = $bee) =~ s/${bktex_dir}\///;
								#print LOG "G  file $bee\n";
								print LOG "\$  Get back $bee (.$ext)...\n";
								system_return("mv","$bee","$wasp","zgrlmf",LOG,"Cannot get $bee back");
							}
						}
					}
				}
			}
		} else {
			print LOG "\$  Back up of .aux file.\n";
			system_return("cp","$filename.aux","$bktex_dir/$filename.aux","zgrlmf",LOG,"Cannot copy $filename.aux to $bktex_dir");
			foreach my $aux(@aux_includes) {
				if(-f "$aux.aux") {
					print LOG "\$  Back up of $aux.aux file.\n";
					system_return("cp","$aux.aux","$bktex_dir/$aux.aux","zgrlmf",LOG,"Cannot copy $aux.aux to $bktex_dir");
				}
			}
			if(-e "$filename.toc") {
				print LOG "\$  Back up of .toc file.\n";
				system_return("cp","$filename.toc","$bktex_dir/$filename.toc","zgrlmf",LOG,"Cannot copy $filename.toc to $bktex_dir");
			}
			if(-e "$filename.idx") {
				print LOG "\$  Back up of .idx file.\n";
				system_return("cp","$filename.idx","$bktex_dir/$filename.idx","zgrlmf",LOG,"Cannot copy $filename.idx to $bktex_dir");
			}
		}
		## }}}
		## Running LaTeX as many times as required {{{
		@latex_args = ("latex","$filename.tex","zgrlmf");
		while($must_run) {
			$must_run--;
			print LOG "@  Running LaTeX...\n";
			system_return(@latex_args,LOG,"LaTeX failed...");
		}
		print LOG "\n";
		## }}}

		## Check the aux file to be unchanged {{{
		print LOG "#  Checking .aux file...\n";
		open(A1, "<", "$filename.aux") or open_failed_die(LOG, "read", "the .aux file");
		if(-f "$bktex_dir/$filename.aux") {
			open(A0, "<", "$bktex_dir/$filename.aux") or open_failed_die(LOG, "read", "the $bktex_dir/.aux file");
			@a1 = <A1>;
			@a0 = <A0>;
			close(A1);
			close(A0);
			if($#a1 != $#a0) {
				$rerun = 1;
				print LOG "   Line count different! Must rerun LaTeX!\n";
			} else {
				for($i = 0; $i <= $#a0; ++$i) {
					if($a1[$i] ne $a0[$i]) {
						$rerun = 1;
						print LOG "   Different! Must rerun LaTeX!\n";
						last;
					}
				}
			}
		} else {
			$rerun = 1;
			print LOG "   Inexistent! Must rerun LaTeX!\n";
		}
		foreach my $aux(@aux_includes) {
			print LOG "#  Checking $aux.aux file...\n";
			open(A1, "<", "$aux.aux") or open_failed_die(LOG, "read", "the $aux.aux file");
			if(-f "$bktex_dir/$aux.aux") {
				open(A0, "<", "$bktex_dir/$aux.aux") or open_failed_die(LOG, "read", "the $bktex_dir/$aux.aux file");
				@a1 = <A1>;
				@a0 = <A0>;
				close(A1);
				close(A0);
				if($#a1 != $#a0) {
					$rerun = 1;
					print LOG "   Line count different! Must rerun LaTeX!\n";
				} else {
					for($i = 0; $i <= $#a0; ++$i) {
						if($a1[$i] ne $a0[$i]) {
							$rerun = 1;
							print LOG "   Different! Must rerun LaTeX!\n";
							last;
						}
					}
				}
			} else {
				$rerun = 1;
				print LOG "   Inexistent! Must rerun LaTeX!\n";
			}
		}
		## }}}
		## Check the toc file to be unchanged {{{
		if(-e "$filename.toc") {
			print LOG "#  Checking .toc file...\n";
			open(T1, "<", "$filename.toc") or open_failed_die(LOG, "read", "the .toc file");
			open(T0, "<", "$bktex_dir/$filename.toc") or open_failed_die(LOG, "read", "the $bktex_dir/.toc file");
			@t1 = <T1>;
			@t0 = <T0>;
			close(T1);
			close(T0);
			if($#t1 != $#t0) {
				$rerun = 1;
				print LOG "   Different! Must rerun LaTeX!\n";
			} else {
				for($i = 0; $i <= $#t0; ++$i) {
					if($t1[$i] ne $t0[$i]) {
						$rerun = 1;
						print LOG "   Different! Must rerun LaTeX!\n";
						last;
					}
				}
			}
		}
		print LOG "\n";
		## }}}
		## Check the bib file to be unchanged. Run bibtex if needed {{{
		foreach my $bb(@bibs) {
			## Nothing here yet
		}
		if(-e "$filename.bib") {
			#if($bib_update) {
				#$do_bib = 1;
				#$rerun = 2;
			#}
			## Must change this to check all bib files from @bibs
			if(-e "$bktex_dir/$filename.bib") {
				print LOG "#  Checking .bib file...";
				open(B1, "<", "$filename.bib") or open_failed_die(LOG, "read", "the .bib file");
				open(B0, "<", "$bktex_dir/$filename.bib") or open_failed_die(LOG, "read", "the $bktex_dir/.bib file");
				@b1 = <B1>;
				@b0 = <B0>;
				close(B1);
				close(B0);
				if($#b1 != $#b0) {
					$do_bib = 1;
					$rerun = 2;
					print LOG "-  Different! Must rerun BibTeX and LaTeX!\n";
				} else {
					for($i = 0; $i <= $#b0; ++$i) {
						if($b1[$i] ne $b0[$i]) {
							$do_bib = 1;
							$rerun = 2;
							print LOG "-  Different! Must rerun BibTeX and LaTeX!\n";
							last;
						}
					}
				}
				print LOG "\n";
			} else {
				$do_bib = 1;
				print LOG "-  No backup of .bib file found, must run BibTeX...\n";
			}
		}
		if($do_bib == 1) {
			$rerun = 2;
			print LOG "%  Running BibTeX...\n\n";
			print "\n\n  ## BIBTEX ##\n";
			system_return("bibtex","$filename.aux","zgrlmf",LOG,"BibTeX failed...");
		}
		## }}}

		## Check the idx file to be unchanged. Run makeindex if needed {{{
		## if .ind not exists OR .idx has changed, run makeindex -s filename.ist filename.idx, rerun latex (makeindex can be run here)
		if(-e "$filename.idx") {
			$index = 0;
			if(! -e "$filename.ind") {
				$index = 1;
				$rerun = 2;
				print LOG "-  No .ind file found though there is the .idx file, must run makeindex...\n";
			} else {
				print LOG "#  Checking .idx file...";
				open(I1, "<", "$filename.idx") or open_failed_die(LOG, "read", "the .idx file");
				open(I0, "<", "$bktex_dir/$filename.idx") or open_failed_die(LOG, "read", "the $bktex_dir/.idx file");
				@i1 = <I1>;
				@i0 = <I0>;
				close(I1);
				close(I0);
				if($#i1 != $#i0) {
					$rerun = 2;
					$index = 1;
					print LOG "-  Different! Must rerun MakeIndex and LaTeX!\n";
				} else {
					for($i = 0; $i <= ($#i1 > $#i0 ? $#i0 : $#i1); ++$i) {
						#print LOG "i1[$i]: $i1[$i]\n";
						#print LOG "i0[$i]: $i0[$i]\n";
						if($i1[$i] ne $i0[$i]) {
							$rerun = 2;
							$index = 1;
							print LOG "-  Different! Must rerun MakeIndex and LaTeX!\n";
							last;
						}
					}
				}
				print LOG "\n";
			}
			if($index == 1) {
				print "\n\n  ++ MAKEINDEX ++\n\n";
				if(-e "$filename.ist") {
					print LOG "%  Running MakeIndex, found $filename.ist.\n";
					system_return("makeindex","-s","$filename.ist","$filename.idx","zgrlmf",LOG,"makeindex failed...");
				} else {
					print LOG "%  Running MakeIndex (no .ist file)...\n";
					system_return("makeindex","$filename.idx","zgrlmf",LOG,"makeindex failed...");
				}
			}
		}
		## }}}

		## Rerun latex as many times as required {{{
		while($rerun) {
			$rerun--;
			print LOG "@  Running LaTeX again...\n";
			print "\n\n      *** LaTeX ***\n\n";
			system_return("latex","$filename.tex","zgrlmf",LOG,"LaTeX failed...");
		}
		## }}}
		## Move auxiliary files to $bktex_dir directory {{{
		opendir($CUD, ".") or open_failed_die(LOG, "opendir", ".");
		@curcont = readdir($CUD);
		closedir($CUD);
		foreach $cuf(@curcont) {
			chomp($cuf);
			if($cuf !~ /^\.\.?$/ && $cuf !~ /^${bktex_dir}$/ && $cuf !~ /^\..*\.swp$/ && $cuf !~ /^\.vimrc.*$/) {
				foreach $ext(@kept_exts) {
					$sext = regex2shell_ext($ext);
					#if($cuf =~ /${filename}\.${ext}$/) {
						#@flies = glob("$filename.$sext");
						#foreach $bee(@flies) {
							#print LOG "\$  Storing kept_exts $bee (.$ext) in $bktex_dir...\n";
							#system_return("mv","-f","$bee","$bktex_dir/$bee","zgrlmf","Cannot move $bee to $bktex_dir");
						#}
					#}
					if($cuf =~ /\.${ext}$/) {
						print LOG "\$  Storing kept_exts $cuf (.$ext) in $bktex_dir...\n";
						system_return("mv","-f","$cuf","$bktex_dir/$cuf","zgrlmf","Cannot move $bee to $bktex_dir");
					}
				}
				#print LOG "G  Loop aux_include...\n";
				#foreach $aux(@aux_includes) {
					#print LOG "G   $aux\n";
					#if($cuf =~ /${aux}\.aux$/) {
						#@flies = glob("$aux.aux");
						#foreach $bee(@flies) {
							#print LOG "\$  Storing aux $bee in $bktex_dir...\n";
							#system_return("mv","-f","$bee","$bktex_dir/$bee","zgrlmf","Cannot move $bee to $bktex_dir");
						#}
					#}
				#}
				foreach $ext(@file_exts) {
					$sext = regex2shell_ext($ext);
					#if($cuf =~ /${filename}\.${ext}$/) {
						#@flies = glob("$filename.$sext");
						#foreach $bee(@flies) {
							#print LOG "\$  Storing file_exts $bee (.$ext) in $bktex_dir...\n";
							#system_return("mv","-f","$bee","$bktex_dir/$bee","zgrlmf","Cannot move $bee to $bktex_dir");
						#}
					#}
					if($cuf =~ /\.${ext}$/) {
						print LOG "\$  Storing file_exts $cuf (.$ext) in $bktex_dir...\n";
						system_return("mv","-f","$cuf","$bktex_dir/$cuf","zgrlmf","Cannot move $bee to $bktex_dir");
					}
				}
			}
		}
		## }}}
		## Printing PS from DVI, removing DVI {{{
		print LOG "\$  Printing .ps file...\n";
		#print " Converting the DVI to PS...\n";
		print " DVI -> ";
		if($dvipsmute[$ix]) {
			system_return("dvips","-q","$filename.dvi","zgrlmf",LOG,"dvips failed...");
		} else {
			system_return("dvips","$filename.dvi","zgrlmf",LOG,"dvips failed...");
		}
		print LOG "\$  Removing .dvi file.\n";
		print "PS ";
		system_return("rm","$filename.dvi","zgrlmf",LOG,"Cannot remove DVI file...");
		## }}}
		## Arranging PS if needed {{{
		if($pinup[$ix] != 1 || $paper_format[$ix] ne "a4") {
			system_return("mv","$filename.ps","tmp.ps","zgrlmf",LOG,"Cannot move ps file to tmp.ps...");
			@psnup = ("psnup","-p$paper_format[$ix]");
			if($pinup[$ix] > 0) {
				$nup = $pinup[$ix];
				push(@psnup,"-$nup");
				push(@psnup,"-Pa4");
				#$page_w = "-W210mm";
				#push(@psnup,$page_w);
				#$page_h = "-H297mm";
				#push(@psnup,$page_h);
			} else {
				$nup = -$pinup[$ix];
				push(@psnup,"-$nup");
				$slide_w = "-W5.04in";
				push(@psnup,$slide_w);
				$slide_h = "-H3.78in";
				push(@psnup,$slide_h);
				#$slide_m = "-m0.5cm";
				#push(@psnup,$slide_m);
			}
			push(@psnup,"tmp.ps");
			push(@psnup,"$filename.ps");
			print LOG "\$  Printing $nup pages per sheet on $paper_format[$ix] paper\n";
			system_return(@psnup,"zgrlmf",LOG,"psnup failed...");
			system_return("rm","tmp.ps","zgrlmf",LOG,"Cannot remove tmp.ps...");
		}
		## }}}
		## Printing PDF from PS, removing PS {{{
		@pspdf = ("ps2pdf","-sPAPERSIZE=$paper_format[$ix]");
		if($no_rotate[$ix] != 0) {
			$no_rot_arg = "-dAutoRotatePages=/None";
			push(@pspdf,$no_rot_arg);
			print LOG "-  No auto rotation\n";
		}
		push(@pspdf,"$filename.ps");
		if(defined($output_filename[$ix])) {
			push(@pspdf,$output_filename[$ix]);
			print LOG "\$  Printing $output_filename[$ix] file on $paper_format[$ix] paper...\n";
		} else {
			print LOG "\$  Printing .pdf file on $paper_format[$ix] paper...\n";
		}
		#print "  Converting the PS to PDF...\n";
		print "-> ";
		system_return(@pspdf,"zgrlmf",LOG,"ps2pdf failed...");
		print LOG "\$  Removing .ps file...\n";
		print "PDF\n";
		system_return("rm","$filename.ps","zgrlmf",LOG,"Cannot remove PS file...");
		## }}}
	}
   ## Back up bib to check if has changed {{{
	if(-e "$filename.bib") {
		print LOG "\$  Backup of .bib file.\n";
		system_return("cp","$filename.bib","$bktex_dir/$filename.bib","zgrlmf",LOG,"Cannot copy bib file to $bktex_dir...");
	}
	## }}}
	## Copy the PDF if asked to do so {{{
	if($cp_path[$ix] ne "") {
		if($chmod[$ix]) {
			#print LOG "\$  Setting chmod u+w to $cp_path[$ix]/$output_filename[$ix]\n";
			#system_return("chmod", "-v", "u+w", "$cp_path[$ix]/$output_filename[$ix]", "zgrlmf", LOG, "Cannot chmod the copy file destination to +w");
		}
		print LOG "\$  Copying PDF to $cp_path[$ix]\n";
		system_return("cp",$output_filename[$ix],$cp_path[$ix],"zgrlmf",LOG,"Cannot copy the PDF to the desired path...");
		if($chmod[$ix]) {
			#print LOG "\$  Setting chmod a-w to $cp_path[$ix]/$output_filename[$ix]\n";
			#system_return("chmod", "-v", "a-w", "$cp_path[$ix]/$output_filename[$ix]", "zgflmf", LOG, "Cannot chmod the copy file destination to -w");
		}
	}
	## }}}
	## Move the PDF if asked to do so {{{
	if($mv_path[$ix] ne "") {
		if($chmod[$ix]) {
			#print LOG "\$  Setting chmod u+w to $mv_path[$ix]/$output_filename[$ix]\n";
			#system_return("chmod", "-v", "u+w", "$mv_path[$ix]/$output_filename[$ix]", "zgrlmf", LOG, "Cannot chmod the move file destination to +w");
		}
		print LOG "\$  Moving PDF to $mv_path[$ix]\n";
		system_return("mv",$output_filename[$ix],$mv_path[$ix],"zgrlmf",LOG,"Cannot move the PDF to the desired path...");
		if($chmod[$ix]) {
			#print LOG "\$  Setting chmod a-w to $mv_path[$ix]/$output_filename[$ix]\n";
			#system_return("chmod", "-v", "a-w", "$mv_path[$ix]/$output_filename[$ix]", "zgflmf", LOG, "Cannot chmod the move file destination to -w");
		}
	}
	## }}}
	print LOG "#  $output_filename[$ix] ready !\n";
	print "\n       ** $output_filename[$ix] ready ! See $bktex_dir/$filename.plg for more details. **\n\n";

	## Open up, open up {{{
	if($do_open[$ix]) {
		if($OS =~ /darwin/i) {
			$open_cmd = "open";
		} else {
			$check_acro = `command -v acroread`;
			if($check_acro == "") {
				$check_gnome = `command -v gnome-open`;
				if($check_gnome == "") {
					$open_cmd = "evince";
				} else {
					$open_cmd = "gnome-open";
				}
			} else {
				$open_cmd = "acroread";
			}
		}
		$open_file = $output_filename[$ix];
		system("$open_cmd $open_file 2> /dev/null &") == 0 or open_failed_die(LOG, "open", $open_file);
	}
	## }}}
	## Unset some vars for the next run (this should be improved when the my whill be set)
	undef @psnup, @pspdf, $nup;
}
## }}}
close(LOG);

sub open_failed_die
{
	my $log_handle = shift(@_);
	my $log_text   = shift(@_);
	my $file       = shift(@_);
	print $log_handle "xx Cannot $log_text $file!\n";
	close($log_handle);
	die(" Cannot $log_text $file...\n");
}

exit 0;
