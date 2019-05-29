#!/usr/bin/perl -I /home/audris/lib64/perl5 -I /home/audris/lib/x86_64-linux-gnu/perl
use strict;
use warnings;


my $bp = "";

my $n = $ARGV[0];
open A,  'zcat /da0_data/basemaps/gz/b2cFullO'.$n.'.s|cut -d\; -f1 | uniq|'; 
while (<STDIN>){
  chop();
  my  ($bh, $t, $au, $ch) = split(/\;/, $_, -1);
  my $b = <A>;
  chop($b);
  if ($b ne $bp && $bp ne ""){
    print "bad sequence $bp:$b\n";
  }else{
    print "$b;$t;$au;$ch\n";
  }
  $bp = $bh;
};




