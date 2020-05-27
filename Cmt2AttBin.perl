#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl");

use strict;
use warnings;
use Error qw(:try);
use cmt;
use TokyoCabinet;
use Compress::LZF;


my %b2c;
my $sec;
my $nsec = 16;
$nsec = $ARGV[1] if defined $ARGV[1];

for $sec (0..($nsec -1)){
  my $fname = "$ARGV[0].$sec.tch";
  $fname=$ARGV[0] if $nsec == 1;
  tie %{$b2c{$sec}}, "TokyoCabinet::HDB", $fname, TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT #, 16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "can't open $fname\n";
}


#ENHANCED: CLP(FD): Propagation for disjunctive equalities. Roberto Bagnara.;00ec86f9e2f6e89fec4ee96f6b23b3903f012db3;Markus Triska;markus.triska@gmx.at;1303441528 +0200;Markus Triska <markus.triska@gmx.at>
my %b2c1;
my $lines = 1;
while (<STDIN>){
  chop();
  my ($msg, $c, $an, $ae, $at, $a) = split(/\;/, $_, -1);
  if ($at ne ""){
    $at =~ s/ .*//;
    $at = pack "L*", $at;
    my $c1 = fromHex ($c);
    my $v = "$at$a";
    $b2c1{$c1} = $v;
  }
  $lines ++;
  output ($lines) if ! $lines%10000000;
} 
output($lines);

for $sec (0..($nsec -1)){
  untie %{$b2c{$sec}};
}

sub output {
  print STDERR "read $_[0] lines\n";
  while (my ($k, $v) = each %b2c1){
    my $sec = (unpack "C", substr ($k, 0, 1))%$nsec;
    $b2c{$sec}{$k} = $v;
  }
  %b2c1 = ();
}




