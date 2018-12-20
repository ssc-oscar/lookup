#!/usr/bin/perl -I /home/audris/lookup -I /home/audris/lib64/perl5
use strict;
use warnings;
use Error qw(:try);

use TokyoCabinet;
use Compress::LZF;
use cmt;


my $detail = 0;
$detail = $ARGV[1]+0 if defined $ARGV[1];
my $split = 1;
$split = $ARGV[2] + 0 if defined $ARGV[2];

my %p2c;
for my $sec (0..($split-1)){
  my $fname = "$ARGV[0].$sec.tch";
  $fname = $ARGV[0] if ($split == 1);
  tie %{$p2c{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fname\n";
}

while (<STDIN>){
  chop();
  my $p = $_;
  #my $sec = (unpack "C", substr ($p, 0, 1))%$split;
  my $sec = 0;
  $sec = sHash ($p, $split) if $split > 1;
  #print "$sec;$p\n";
  if (defined $p2c{$sec}{$p}){
    list ($p, $p2c{$sec}{$p});
  }else{
    print STDERR "no $p in $sec\n";
  }
  
  list ("$p\n", $p2c{$sec}{"$p\n"}) if defined $p2c{$sec}{"$p\n"};
}
for my $sec (0..($split-1)){
  untie %{$p2c{$sec}};
}


sub list {
  my ($p, $v) = @_;
  my $ns = length($v)/20;
  my %tmp = ();
  print "$p;$ns";
  if ($detail != 0){
    for my $i (0..($ns-1)){
      my $c = substr ($v, 20*$i, 20);
      print ";".(toHex($c));
    }
  }
  print "\n";
}


