#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
use strict;
use warnings;
use Error qw(:try);

use TokyoCabinet;
use Compress::LZF;
use cmt; 


my $split = 1;
$split = $ARGV[1] + 0 if defined $ARGV[1];

my (%p2c, %p2c1);
for my $sec (0..($split-1)){
  my $fname = "$ARGV[0].$sec.tch";
  $fname = $ARGV[0] if ($split == 1);
  tie %{$p2c{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fname\n";
}
if (defined $ARGV[2]){
  for my $sec (0..($split-1)){
    my $fname = "$ARGV[2].$sec.tch";
    $fname = $ARGV[2] if ($split == 1);
    tie %{$p2c1{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER, 16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
       or die "cant open $fname\n";
  }
}

my %p2c0;

while (<STDIN>){
  chop();
  my ($p, $type, $hash) = split (/\;/);
  next if $type ne "commit";
  my $c = fromHex ($hash);
  if (! defined $p2c0{$p}){
    my $sec = sHash ($p, $split);
    list ($p, $p2c{$sec}{$p});
    list ($p, $p2c1{$sec}{$p}) if defined $ARGV[2];
  }
  if (!defined  $p2c0{$p}{$c}){
    print "$p;$hash\n";
    $p2c0{$p}{$c}++;
  }
}


for my $sec (0..($split-1)){
  untie %{$p2c{$sec}};
}
if (defined $ARGV[2]){
  for my $sec (0..($split-1)){
    untie %{$p2c1{$sec}};
  }
}


sub list {
  my ($p, $v) = @_;
  if (!defined $v){
    $p2c0{$p}{""}++;
    return;
  }
  my $ns = length($v)/20;
  my %tmp = ();
  $p =~ s/\n$//;
  for my $i (0..($ns-1)){
    my $c = substr ($v, 20*$i, 20);
    $p2c0{$p}{$c}++;
  }
}


