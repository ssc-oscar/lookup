#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");

use strict;
use warnings;


my $str = $ARGV[0];

my %match;
open A, "gunzip -c $str|";
while(<A>){
  chop();
  if ($_ =~ s|^([^;]*);||){
    $match{$1}=$_;
  }
}

my $line = 0;
while(<STDIN>){
  chop();
  $line ++;
  my ($k, @x) = split(/\;/, $_, -1);
  if (defined $match{$k}){
    print "$k;$match{$k}\n";
  }else{
    print "$_\n";
  }
}

