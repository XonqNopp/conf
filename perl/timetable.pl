#!/usr/bin/perl
require "convert.pl";
$output = "timetable.sql";
$master = "tt_ma.txt";
open( IN_MA, "<" . $master ) or die( "Can't open $master...\n" );
unlink( $output );
open( OUT, ">>" . $output ) or die( "Can't write file $output...\n" );
$idx = 0;
@txt = ();
while( $i = <IN_MA> ) {
	$i =~ s/'/ /g;
	@txt[ $idx ] = $i;
	$idx++;
}
close( IN_MA );
@normal = normalchars( @txt );
$next = "";
foreach $n( @normal ) {
	$next .= $n;
}
$next =~ s/^(.*\n){5}//;
$next =~ s/C(E|M)(1)1([0-9]{2})/C\1\2\3/g;
$monday = $next;
$monday =~ s/^(.*\n)*LUNDI.*\n//;
$monday =~ s/MARDI.*\n(.*\n)*$//;
#$monday .= "\n";
$tuesday = $next;
$tuesday =~ s/^(.*\n)*MARDI.*\n//;
$tuesday =~ s/MERCREDI.*\n(.*\n)*$//;
#$tuesday .= "\n";
$wednesday = $next;
$wednesday =~ s/^(.*\n)*MERCREDI.*\n//;
$wednesday =~ s/JEUDI.*\n(.*\n)*$//;
#$wednesday .= "\n";
$thursday = $next;
$thursday =~ s/^(.*\n)*JEUDI.*\n//;
$thursday =~ s/VENDREDI.*\n(.*\n)*$//;
#$thursday .= "\n";
$friday = $next;
$friday =~ s/^(.*\n)*VENDREDI.*\n//;
#$friday =~ s/MARDI.*\n(.*\n)*$//;
#$friday .= "\n";

############ Problem with the lines between utils informations... Try to erase each line that is not SQL... ######################
$monday =~ s/([0-9]{2}):[0-9]{2}-([0-9]{2}):[0-9]{2}\s+([A-Za-z0-9-]*(\n[A-Za-z0-9-]+)*)\s*(T|E|C)\s+[A-Z]{3}\s+(.*)\n/INSERT INTO `master` VALUES( NULL, '\6', '\5', 'monday', \1, \2, '\3' );\n/g;
$monday =~ s/(INSERT INTO.*, )'' \);/\1NULL );/g;
$monday =~ s/\n[^0-9]+\n/\n/g;
$monday =~ s/\n([^I].*\n)/-\1/g;
#$monday =~ s/\n\n/\n/g;
$tuesday =~ s/([0-9]{2}):[0-9]{2}-([0-9]{2}):[0-9]{2}\s+([A-Za-z0-9-]*(\n[A-Za-z0-9-]+)*)\s*(T|E|C)\s+[A-Z]{3}\s+(.*)\n/INSERT INTO `master` VALUES( NULL, '\6', '\5', 'tuesday', \1, \2, '\3' );\n/g;
$tuesday =~ s/(INSERT INTO.*, )'' \);/\1NULL );/g;
#$tuesday =~ s/([0-9]{2}):[0-9]{2}-([0-9]{2}):[0-9]{2}\s+SHS.*\n/INSERT INTO `master` VALUES( NULL, 'SHS', 'C', 'tuesday', \1, \2 );\n/g;# Be careful if SHS timetable changes...
$tuesday =~ s/\n[^0-9]+\n/\n/g;
$tuesday =~ s/\n([^I].*\n)/-\1/g;
#$tuesday =~ s/\n\n/\n/g;
$wednesday =~ s/([0-9]{2}):[0-9]{2}-([0-9]{2}):[0-9]{2}\s+([A-Za-z0-9-]*(\n[A-Za-z0-9-]+)*)\s*(T|E|C)\s+[A-Z]{3}\s+(.*)\n/INSERT INTO `master` VALUES( NULL, '\6', '\5', 'wednesday', \1, \2, '\3' );\n/g;
$wednesday =~ s/(INSERT INTO.*, )'' \);/\1NULL );/g;
$wednesday =~ s/([0-9]{2}):[0-9]{2}-([0-9]{2}):[0-9]{2}\s+SHS.*\n/INSERT INTO `master` VALUES( NULL, 'SHS', 'P', 'wednesday', \1, \2, NULL );\n/g;# Be careful if SHS timetable changes...
$wednesday =~ s/\n[^0-9]+\n/\n/g;
$wednesday =~ s/\n([^I].*\n)/-\1/g;
#$wednesday =~ s/\n\n/\n/g;
$thursday =~ s/([0-9]{2}):[0-9]{2}-([0-9]{2}):[0-9]{2}\s+([A-Za-z0-9-]*(\n[A-Za-z0-9-]+)*)\s*(T|E|C)\s+[A-Z]{3}\s+(.*)\n/INSERT INTO `master` VALUES( NULL, '\6', '\5', 'thursday', \1, \2, '\3' );\n/g;
$thursday =~ s/(INSERT INTO.*, )'' \);/\1NULL );/g;
$thursday =~ s/\n[^0-9]+\n/\n/g;
$thursday =~ s/\n([^I].*\n)/-\1/g;
#$thursday =~ s/\n\n/\n/g;
$friday =~ s/([0-9]{2}):[0-9]{2}-([0-9]{2}):[0-9]{2}\s+([A-Za-z0-9-]*(\n[A-Za-z0-9-]+)*)\s*(T|E|C)\s+[A-Z]{3}\s+(.*)\n/INSERT INTO `master` VALUES( NULL, '\6', '\5', 'friday', \1, \2, '\3' );\n/g;
$friday =~ s/(INSERT INTO.*, )'' \);/\1NULL );/g;
$friday =~ s/\n[^0-9]+\n/\n/g;
$friday =~ s/\n([^I].*\n)/-\1/g;
#$friday =~ s/\n\n/\n/g;

@week = ();
@week[ 0 ] = $monday;
@week[ 1 ] = $tuesday;
@week[ 2 ] = $wednesday;
@week[ 3 ] = $thursday;
@week[ 4 ] = $friday;
print OUT "-- File created by timetable.pl to create one's own timetable (only available for master degree)\n\n";
print OUT "--\n-- Cleaning database : removing existing table `master`\n--\n\n";
print OUT "DROP TABLE `master`;\n\n";
print OUT "--\n-- Structure de la table `master`\n--\n\n";
print OUT "CREATE TABLE `master` (\n";
print OUT "  `id` int(100) NOT NULL auto_increment,\n";
print OUT "  `name` varchar(100) NOT NULL,\n";
print OUT "  `type` enum('T','P','E','C') NOT NULL,\n";
print OUT "  `day` enum('monday','tuesday','wednesday','thursday','friday') NOT NULL,\n";
print OUT "  `timestart` int(10) NOT NULL,\n";
print OUT "  `timestop` int(10) NOT NULL,\n";
print OUT "  `location` varchar(20) NULL,\n";
print OUT "  PRIMARY KEY (`id`)\n";
print OUT ");\n";
print OUT "\n--\n-- Contenu de la table `master`\n--\n\n";
print OUT @week;
close( OUT );
#foreach $w( @week ) {
#}

exit 0;

