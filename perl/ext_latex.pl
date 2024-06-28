sub latex_kept_exts()
{
	return ("aux","toc","idx","log");
}

sub latex_tmp_exts()
{
	@back = ();
	push(@back, "out");
	push(@back, "blg");
	push(@back, "bbl");
	push(@back, "ilg");
	push(@back, "ind");
	push(@back, "snm");
	push(@back, "nav");
	push(@back, "tns");
	#push(@back, "mtc");
	push(@back, "mtc[0-9]*");
	#push(@back, "stc");
	push(@back, "stc[0-9]*");
	push(@back, "maf");
	push(@back, "brf");
	## To be completed...
	## dvi and ps have to be kept for further treatement... Think I must add another sub...
	return @back;
}

sub latex_half_exts()
{
	return ("dvi","ps");
}

sub latex_bktex_dir()
{
	return ".texst";
}

sub regex2shell_ext()
{
	my $regex = $_[0];
	my $shex = $regex;
	$shex =~ s/(\.|\[[^\]]+\])[\*\?\+]?/*/g;
	return $shex;
}




sub latex_getback_exts() {
	return ("aux","toc","idx","log");
}

sub latex_moveaway_exts() {
	@back = ();
	push(@back, "out");
	push(@back, "blg");
	push(@back, "bbl");
	push(@back, "ilg");
	push(@back, "ind");
	push(@back, "snm");
	push(@back, "nav");
	push(@back, "tns");
	push(@back, "mtc[0-9]*");
	push(@back, "stc[0-9]*");
	push(@back, "maf");
	push(@back, "brf");
	## To be completed...
	return @back;
}

sub latex_delete_exts() {
	return ("dvi","ps");
}

return 1;
