#!/usr/bin/perl
$input_m = "isaca_m.txt";
$input_b = "isaca_b.txt";
#############################
######### MASTER ############
#############################
open( IN, "<" . $input_m ) or die( "Can't open $input_m...\n" );
$store = "";
while( $i = <IN> ) {
	$i =~ s/é/e/g;
	$i =~ s/è/e/g;
	$i =~ s/ê/e/g;
	$i =~ s/ë/e/g;
	$i =~ s/à/a/g;
	$i =~ s/á/a/g;
	$i =~ s/â/a/g;
	$i =~ s/ä/a/g;
	$i =~ s/ï/i/g;
	$i =~ s/î/i/g;
	$i =~ s/ì/i/g;
	$i =~ s/í/i/g;
	$i =~ s/ñ/n/g;
	$i =~ s/ó/o/g;
	$i =~ s/ò/o/g;
	$i =~ s/ô/o/g;
	$i =~ s/ö/o/g;
	$i =~ s/ü/u/g;
	$i =~ s/û/u/g;
	$i =~ s/ç/c/g;
	$i =~ s/\t//g;
	$i =~ s/'//g;
	$i =~ s/ \/ /-/g;
	$store .= $i;
}
$store =~ s/^(.*\n){6}//;
$store =~ s/Salle.*\nEnseignants?\n(.+\n){0,4}Expert-observateurs?\n(.+\n){0,4}Remarques.*//g;
$store =~ s/\n\n(Inscrit.*\n)/\n\1\n/g;
$store =~ s/Sections?\n(.+\[[0-9]+\]\n)*Inscrit/Inscrit/g;
$store =~ s/ \(Oral\)//g;
$store =~ s/ \(Ecrit\)/-ECRIT/g;
$store =~ s/\n\n+$/\n/;
$store .= "\n ";
#print $store;
@store_array = split( "\n", $store );
foreach $s( @store_array ) {
	$s .= "\n";
}
#print @store_array;
@all = ();
$k = 0;
@in = ();
$j = 0;
#while( $i = <> ) {
foreach $i( @store_array ) {
	$i =~ s/^Matiere//g;
	$i =~ s/://g;
	$i =~ s/;/,/g;
	$i =~ s/^Inscrits \[[0-9]*\] //g;
	if( $i =~ m/^\n/ ) {
		@in[ 1 ] =~ s/ /_/g;
		chomp( @in[ 1 ] );
		@in[ 1 ] =~ s/,//g;
		$output = @in[ 1 ] . ".txt";
		$already = 0;
		foreach $o( @all ) {
			if( $o eq $output ) {
				$already = 1;
			}
		}
		if( !$already ) {
			unlink( $output );
			@all[ $k ] = $output;
			$k++;
		}
		open( OUT, ">>" . $output );
		if( !$already ) {
			print OUT @in[ 1 ] . "\n";
			print OUT @in[ 2 ];
		}
		print OUT @in[ 0 ];
		close( OUT );
		@in = ();
		$j = 0;
	} else {
		@in[ $j ] = $i;
		$j++;
	}
}

$output = "isaca.sql";
unlink( $output );
open( OUTSQL, ">>" . $output );
print OUTSQL "-- File created by sort.pl to help Romaine and Fred doing the oral exams lists\n\n";
print OUTSQL "--\n-- Cleaning database\n--\n\n";
print OUTSQL "DROP TABLE `lectures_m`, `lectures_b`, `students_m`, `students_b`;\n\n";
print OUTSQL "--\n-- Master\n--\n\n";
print OUTSQL "--\n-- Structure de la table `lectures_m`\n--\n\n";
print OUTSQL "CREATE TABLE `lectures_m` (\n";
print OUTSQL "  `id` int(100) NOT NULL auto_increment,\n";
print OUTSQL "  `lecture` varchar(100) NOT NULL,\n";
print OUTSQL "  `students` text NOT NULL,\n";
print OUTSQL "  `howmanydates` tinyint(4) NOT NULL default '1',\n";
print OUTSQL "  `date1` date NOT NULL,\n";
print OUTSQL "  `date2` date default NULL,\n";
print OUTSQL "  `date3` date default NULL,\n";
print OUTSQL "  `date4` date default NULL,\n";
print OUTSQL "  `date5` date default NULL,\n";
print OUTSQL "  PRIMARY KEY (`id`),\n";
print OUTSQL "  UNIQUE KEY `lecture` (`lecture`)\n";
print OUTSQL ");\n";
print OUTSQL "\n--\n-- Contenu de la table `lectures_m`\n--\n\n";
@lectures = sort( @all );
foreach $c( @lectures ) {
	$back = "INSERT INTO `lectures_m` VALUES( NULL, ";
	open( IN, "<" . $c );
	$j = 0;
	@dates = ();
	$which = '';
	while( $l = <IN> ) {
		chomp( $l );
		if( $j == 0 ) {
			$l =~ s/_/ /g;
			$which = $l;
			$back .= "'" . $l . "', ";
		} elsif( $j == 1 ) {
			$back .= "'" . $l . ", - Tous les examens -', ";
		} else {
			$l =~ s/^[A-Z]* //g;
			$l =~ s/ de [0-9]{4} a [0-9]{4}$//g;
			$l =~ s/([0-9]{2})\.([0-9]{2})\.([0-9]{4})/\3-\2-\1/g;
			push( @dates, $l );
		}
		$j++;
	}
	close( IN );
	$ndate = $#dates + 1;
	$back .= $ndate . ", ";
	foreach my $i (1..5) {
		if( $i <= $ndate ) {
			$back .= "'" . @dates[ $i - 1 ] . "', ";
		} else {
			$back .= "NULL, ";
		}
	}
	$back = substr( $back, 0, length( $back ) - 2 );
	$back .= " );\n";
	print OUTSQL $back;
}
@students = ();
foreach $c( @lectures ) {
	open( IN, "<" . $c );
	@reading = <IN>;
	close( IN );
	@these = split( ", ", @reading[ 1 ] );
	foreach $ts( @these ) {
		$already = 0;
		chomp( $ts );
		foreach $s( @students ) {
			if( $s eq $ts ) {
				$already = 1;
			}
		}
		if( !$already ) {
			push( @students, $ts );
		}
	}
}
@st = sort( @students );
print OUTSQL "\n\n--\n-- Structure de la table `students_m`\n--\n\n";
print OUTSQL "CREATE TABLE `students_m` (\n";
print OUTSQL "  `id` int(100) NOT NULL auto_increment,\n";
print OUTSQL "  `student` varchar(100) NOT NULL,\n";
print OUTSQL "  PRIMARY KEY (`id`),\n";
print OUTSQL "  UNIQUE KEY `student` (`student`)\n";
print OUTSQL ");\n";
print OUTSQL "\n--\n-- Contenu de la table `students_m`\n--\n\n";
print OUTSQL "INSERT INTO `students_m` VALUES( NULL, '- Tous les examens -' );\n";
foreach $s( @st ) {
	print OUTSQL "INSERT INTO `students_m` VALUES( NULL, '$s' );\n";
}

print OUTSQL "\n\n";

foreach $f( @lectures ) {
	unlink( $f );
}

#########################
####### BACHELOR ########
#########################

open( IN, "<" . $input_b ) or die( "Can't open $input_b..." );
$store = "";
while( $i = <IN> ) {
	$i =~ s/é/e/g;
	$i =~ s/è/e/g;
	$i =~ s/ê/e/g;
	$i =~ s/ë/e/g;
	$i =~ s/à/a/g;
	$i =~ s/á/a/g;
	$i =~ s/â/a/g;
	$i =~ s/ä/a/g;
	$i =~ s/ï/i/g;
	$i =~ s/î/i/g;
	$i =~ s/ì/i/g;
	$i =~ s/í/i/g;
	$i =~ s/ñ/n/g;
	$i =~ s/ó/o/g;
	$i =~ s/ò/o/g;
	$i =~ s/ô/o/g;
	$i =~ s/ö/o/g;
	$i =~ s/ü/u/g;
	$i =~ s/û/u/g;
	$i =~ s/ç/c/g;
	$i =~ s/'//g;
	$i =~ s/\t//g;
	$i =~ s/ \/ /-/g;
	$store .= $i;
}
$store =~ s/^(.*\n){6}//;
$store =~ s/Salle.*\nEnseignants?\n(.+\n){0,4}Expert-observateurs?\n(.+\n){0,4}Remarques.*//g;
#$store =~ s/\t//g;
$store =~ s/\n\n(Inscrit.*\n)/\n\1\n/g;
$store =~ s/Section(s?)\n(.+\n)*Inscrit/Inscrit/g;
$store =~ s/ \(Oral\)//g;
$store =~ s/ \(Ecrit\)/-ECRIT/g;
$store =~ s/\n\n+$/\n/;
$store .= "\n ";
#print $store;
@store_array = split( "\n", $store );
foreach $s( @store_array ) {
	$s .= "\n";
}
@all = ();
$k = 0;
@in = ();
$j = 0;
foreach $i( @store_array ) {
	$i =~ s/^Matiere//g;
	$i =~ s/://g;
	$i =~ s/;/,/g;
	$i =~ s/^Inscrits \[[0-9]*\] //g;
	if( $i =~ m/^\n/ ) {
		@in[ 1 ] =~ s/ //g;
		chomp( @in[ 1 ] );
		@in[ 1 ] =~ s/,//g;
		$output = @in[ 1 ] . ".txt";
		$already = 0;
		foreach $o( @all ) {
			if( $o eq $output ) {
				$already = 1;
			}
		}
		if( !$already ) {
			unlink( $output );
			@all[ $k ] = $output;
			$k++;
		}
		open( OUT, ">>" . $output );
		if( !$already ) {
			print OUT @in[ 1 ] . "\n";
			print OUT @in[ 2 ];
		}
		print OUT @in[ 0 ];
		close( OUT );
		@in = ();
		$j = 0;
	} else {
		@in[ $j ] = $i;
		$j++;
	}
}

print OUTSQL "--\n-- Bachelor\n--\n\n";
print OUTSQL "--\n-- Structure de la table `lectures_b`\n--\n\n";
print OUTSQL "CREATE TABLE `lectures_b` (\n";
print OUTSQL "  `id` int(100) NOT NULL auto_increment,\n";
print OUTSQL "  `lecture` varchar(100) NOT NULL,\n";
print OUTSQL "  `students` text NOT NULL,\n";
print OUTSQL "  `howmanydates` tinyint(4) NOT NULL default '1',\n";
print OUTSQL "  `date1` date NOT NULL,\n";
print OUTSQL "  `date2` date default NULL,\n";
print OUTSQL "  `date3` date default NULL,\n";
print OUTSQL "  `date4` date default NULL,\n";
print OUTSQL "  `date5` date default NULL,\n";
print OUTSQL "  PRIMARY KEY (`id`),\n";
print OUTSQL "  UNIQUE KEY `lecture` (`lecture`)\n";
print OUTSQL ");\n";
print OUTSQL "\n--\n-- Contenu de la table `lectures_b`\n--\n\n";
@lectures = sort( @all );
foreach $c( @lectures ) {
	$back = "INSERT INTO `lectures_b` VALUES( NULL, ";
	open( IN, "<" . $c );
	$j = 0;
	@dates = ();
	$which = '';
	while( $l = <IN> ) {
		chomp( $l );
		if( $j == 0 ) {# Course title
			$which = $l;
			$back .= "'" . $l . "', ";
		} elsif( $j == 1 ) {# Students
			$back .= "'" . $l . ", - Tous les examens -', ";
		} else {
			$l =~ s/^[A-Z]* //g;
			$l =~ s/ de [0-9]{4} a [0-9]{4}$//g;
			$l =~ s/([0-9]{2})\.([0-9]{2})\.([0-9]{4})/\3-\2-\1/g;
			push( @dates, $l );
		}
		$j++;
	}
	close( IN );
	$ndate = $#dates + 1;
	$back .= $ndate . ", ";
	foreach my $i (1..5) {
		if( $i <= $ndate ) {
			$back .= "'" . @dates[ $i - 1 ] . "', ";
		} else {
			$back .= "NULL, ";
		}
	}
	$back = substr( $back, 0, length( $back ) - 2 );
	$back .= " );\n";
	print OUTSQL $back;
}
@students = ();
foreach $c( @lectures ) {
	open( IN, "<" . $c );
	@reading = <IN>;
	close( IN );
	@these = split( ", ", @reading[ 1 ] );
	foreach $ts( @these ) {
		$already = 0;
		chomp( $ts );
		foreach $s( @students ) {
			if( $s eq $ts ) {
				$already = 1;
			}
		}
		if( !$already ) {
			push( @students, $ts );
		}
	}
}
@st = sort( @students );
print OUTSQL "\n\n--\n-- Structure de la table `students_b`\n--\n\n";
print OUTSQL "CREATE TABLE `students_b` (\n";
print OUTSQL "  `id` int(100) NOT NULL auto_increment,\n";
print OUTSQL "  `student` varchar(100) NOT NULL,\n";
print OUTSQL "  PRIMARY KEY (`id`),\n";
print OUTSQL "  UNIQUE KEY `student` (`student`)\n";
print OUTSQL ");\n";
print OUTSQL "\n--\n-- Contenu de la table `students_b`\n--\n\n";
print OUTSQL "INSERT INTO `students_b` VALUES( NULL, '- Tous les examens -' );\n";
foreach $s( @st ) {
	print OUTSQL "INSERT INTO `students_b` VALUES( NULL, '$s' );\n";
}

print OUTSQL "\n\n";

foreach $f( @lectures ) {
	unlink( $f );
}
############################
########## BOTH ############
############################
close( OUTSQL );

exit 0;

