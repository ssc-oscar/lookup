#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");

use warnings;
use strict;


open A, "|gzip>$ARGV[0].names";
open B, "|gzip>$ARGV[0].versions";
my (%f2num);
my $i = 0;
while(! eof(STDIN)){
  my ($a, $b);
  read STDIN, $a, 20;
  read STDIN, $b, 20;
  for my $v ($a, $b){
	  if (!defined $f2num{$v}){
		  $f2num{$v} = pack "w", ($i+0);
		  print A "$v";
		  $i++;
	  }
  }
	print B $f2num{$a}.$f2num{$b};
}
