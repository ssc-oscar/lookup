#!/usr/bin/perl -I/home/audris/lib64/perl5

use strict;
use warnings;
use Compress::LZF;
use TokyoCabinet;
use Time::Local;



my $outN = $ARGV[0];


my %out;
my $sec;
my %in;
my %res;
my $lines = 0;

my $nParts = 16;
my $doPart = -1;

$nParts = $ARGV[1]+0 if defined $ARGV[1];
$doPart = $ARGV[2]+0 if defined $ARGV[2];

for $sec (0..($nParts-1)){
  next if $doPart >= 0 && $sec != $doPart;
  tie %{$out{$sec}}, "TokyoCabinet::HDB", "$outN.$sec.tch", TokyoCabinet::HDB::OWRITER |  TokyoCabinet::HDB::OCREAT,
    16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
    or die "cant open $outN.$sec.tch\n";
}

sub get {
  my ($k, $v, $res) = @_;
  my $l = length($v);
  for my $i (0..($l/20)){
    $res->{substr($v, $i*20, 20)}++;
  }
}


my $j  = 0;
while (<STDIN>){
  chop();
  my $fname = $_;
  print STDERR "processing $fname\n";
  tie %in, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER,
     16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $fname\n";
  while (my ($k, $v) = each %in){
    print STDERR "$lines done\n" if (!(($lines++)%100000000));
    my $sec =  (unpack "C", substr ($k, 0, 1))%$nParts
    next if $doPart >= 0 && $sec != $doPart;
    get ($k, $v, \%{$res{$k}});
  }
  untie %in;
}

print STDERR "writing $lines\n";
$lines = 0;
while (my ($k, $v) = each %res){
  $lines++;
  my $s = (unpack "C", substr ($k, 0, 1))%$nParts;
  $out{$s}{$k} = join "", sort keys %{$v};  
}
print STDERR "done $lines\n";

for $sec (0..($nParts-1)){
  next if $doPart >= 0 && $sec != $doPart;
  untie %{$out{$sec}};
}


