#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl");
############
############ See accurate diff ib cmputeDiff.perl
############ this is 40X faster but may miss renamed files under renamrd subflders
############ treating some as adds: see commit 0010db3b9a569500a8974bb680acaad12e72a72b
############ Not clear what git diff does here
############
use strict;
use warnings;
use Time::Local;

use Text::Diff qw(diff);

while(<STDIN>){
  chop();
	my ($bn, $bo) = split(/;/, $_, -1);
	if ($bo =~ /^[0-f]{40}$/ && $bn =~ /^[0-f]{40}$/){
	  my ($bos, $bns) = ("", "");
		open A, "echo $bo ".'| ~/lookup/showCnt blob|';
	  my $first = 1;
		while (<A>){ $bos .= $_ if !$first; $first = 0}
		$first = 1;
		open A, "echo $bn ".'| ~/lookup/showCnt blob|';
		while (<A>){ $bns .= $_ if !$first; $first = 0;}
		my $diff = diff (\$bos,   \$bns);
    print "theDiffFor\;$bo;$bn\n$diff";
	}
}


