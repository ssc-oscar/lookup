#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");

use warnings;
use strict;
use TokyoCabinet;

open A, ">$ARGV[0].names";
open B, "|gzip>$ARGV[0].versions";
my (%f2num);
#tie %f2num, "TokyoCabinet::HDB", "f2num.tch", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
#  507377777, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
#  or die "cant open f2num.tch\n";

my $i = 0;
while(<STDIN>){
  chop ();
  my ($a, $b) = split (/;/);
  $a = pack "H*", $a;
  $b = pack "H*", $b;
  for my $v ($a, $b){
	  if (!defined $f2num{$v}){
		  $f2num{$v} = pack "w", ($i+0);
		  print A "$v";
		  $i++;
      print STDERR "$i nodes done\n" if ! (($i+1)%100000000);
	  }
  }
	print B $f2num{$a}.$f2num{$b};
}

#untie %f2num;
