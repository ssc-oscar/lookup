#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
use strict;
use warnings;
#########################
# create code to versions database
#########################
use Compress::LZF;
use TokyoCabinet;

my $tch="delta";

my %delta;
if(!tie(%delta, "TokyoCabinet::HDB", "$tch.tch",
		  TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,
		  505569432, -1, -1, TokyoCabinet::TDB::TLARGE)){
	print STDERR "tie error for $tch.tch\n";
}

my $idx = -1;
open A, "$tch.idx.last";
while(<A>){
        chop();
        $idx = $_;
}
print STDERR "starting from idx=$idx\n";

my $prest = "";
open IDX, ">>$tch.idx";
open IDXL, ">>$tch.idx.last";
while(<STDIN>){
	chop();
	my @x = split (/\;/, $_, -1);
	my ($cmt) = shift @x;
	my $rest = join ';', @x;
	my $zcmt = compress ($cmt);
	my $len = length ($cmt);
	if (defined $delta{$zcmt}){
		my $ind = $delta{$zcmt};
		my $prt = "$ind\;$len;$rest\n";
		if ($prt ne $prest){
			print IDX "$prt";
			$prest = $prt;
		}
	}else{
		$idx++;
		my $ind = $idx;
		$delta{$zcmt} = $ind;
		my $prest = "$ind\;$len;$rest\n";
		print IDX "$prest";
		print IDXL "$idx\n";
	}
}
untie %delta;

