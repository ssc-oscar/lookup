#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
use strict;
use warnings;
use Error qw(:try);

use TokyoCabinet;
use Compress::LZF;
use cmt;


my $split = 32;

my %p2c;
for my $sec (0..($split-1)){
  my $fname = "p2cFullN.$sec.tch";
  tie %{$p2c{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fname\n";
}


my %c2p;
for my $sec (0..($split-1)){
  my $fname = "c2pFullN.$sec.tch";
  tie %{$c2p{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER,
         16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fname\n";
}

my $p1 = "";
$p1 = $ARGV[0] if defined $ARGV[0];

my $sec1 = 0;
my %ps = ();
my %cs0 = ();
my %csE = ();
my %psE = ();
my $nps = 0;
$sec1 = sHash ($p1, $split) if $split > 1;
$psE{$p1}++;
if (defined $p2c{$sec1}{$p1}){
  list ($p2c{$sec1}{$p1}, \%cs0, \%csE);
  my @cs3 = keys %cs0;
  for my $c (@cs3){
    $csE{$c}++;
    my $secc = segB ($c, $split);
    if (defined $c2p{$secc}{$c}){
      list1 ($c2p{$secc}{$c}, \%ps, \%psE);
    }
    my $ch= toHex($c);
    my $n = scalar (keys %ps);
    print "0;$p1;$ch;$n".($n-$nps)."\n" if $n > $nps;
    $nps = $n;
  }
}

$nps = scalar (keys %ps);
my $ncs0 = scalar (keys %cs0);
print STDERR "$p1;nps=$nps;ncs0=$ncs0\n";
my %ps1;
my %cs1 = ();
for my $p (keys %ps){
  $psE{$p}++;
  my $sec = 0;
  $sec = sHash ($p, $split) if $split > 1;
  if (defined $p2c{$sec}{$p}){
    list ($p2c{$sec}{$p}, \%cs1, \%csE);
  }
}
my $nps1 = scalar (keys %ps1);
for my $c (keys %cs1){
  $csE{$c}++;
  my $secc = segB ($c, $split);
  if (defined $c2p{$secc}{$c}){
    list1 ($c2p{$secc}{$c}, \%ps1, \%psE);
  }
  my $n = scalar (keys %ps1);  
  my $ch= toHex($c);
  print "1;$p1;$ch;$n".($n-$nps1)."\n" if $n > $nps1;
  $nps1 = $n;
}
$nps1 = scalar (keys %ps1);
my $ncs1 = scalar (keys %cs1);
print STDERR "$p1;nps=$nps;ncs0=$ncs0;nps1=$nps1;ncs1=$ncs1\n";

my %cs2 = ();
for my $p (keys %ps1){ 
  $ps{$p}++;
  my $sec = 0;
  $sec = sHash ($p, $split) if $split > 1;
  list ($p2c{$sec}{$p}, \%cs2, \%csE);
  my %psp = ();
  for my $c (keys %cs2){
    $csE{$c}++;
    my $secc = segB ($c, $split);
    if (defined $c2p{$secc}{$c}){
      list1 ($c2p{$secc}{$c}, \%psp, \%psE);
    }
  }
  my $npsp = scalar (keys %psp);
  print "a;$p1;$p;$npsp\n";
  for my $pa (keys %psp){ $psE{$pa}++};
  %cs2 = ();
}
my $npsE = scalar(keys %psE);
my $ncsE = scalar(keys %csE);
print STDERR "npsE=$npsE;ncsE=$ncsE\n";

exit();
my %ps2;
%ps1 = ();
for my $c (keys %cs2){
  my $secc = segB ($c, $split);
  if (defined $c2p{$secc}{$c}){
    for my $p (split(/\;/, safeDecomp ($c2p{$secc}{$c}))){
      $ps1{$p}++ if !defined $ps{$p};
    }
  }
}
my $nps2 = scalar (keys %ps1);
my $ncs2 = scalar (keys %cs2);
print STDERR "$p1;$nps;$ncs0;$nps1;$ncs1\;$ncs2\n";



for my $sec (0..($split-1)){
  untie %{$p2c{$sec}};
  untie %{$c2p{$sec}};
}


sub list {
  my ($v, $cs, $csE) = @_;
  my $ns = length($v)/20;
  for my $i (0..($ns-1)){
    my $c = substr ($v, 20*$i, 20);
    $cs ->{$c}++ if !defined $csE ->{$c};
  }
}

sub list1 {
  my ($v, $p) = @_;
  my $v1 = safeDecomp ($v);
  my @ps = split(/\;/, $v1, -1);
  for my $p0 (@ps) { $p ->{$p0}++; };
}


