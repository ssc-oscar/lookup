#!/bin/perl -I /home/audris/lib64/perl5

use strict;
use warnings;
use Error qw(:try);

use TokyoCabinet;
use Compress::LZF;

sub toHex { 
        return unpack "H*", $_[0]; 
} 

sub fromHex { 
        return pack "H*", $_[0]; 
} 

my %b2c;
my $sec;
my $nsec = 16;
$nsec = $ARGV[1] if defined $ARGV[1];

for $sec (0..($nsec -1)){
  my $fname = "$ARGV[0].$sec.tch";
  $fname=$ARGV[0] if $nsec == 1;
  tie %{$b2c{$sec}}, "TokyoCabinet::HDB", $fname, TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $fname\n";
}

my %b2c1;
my $lines = 0;
while (<STDIN>){
  chop();
  my ($c, $f, $bb, $p) = split(/\;/, $_, -1);
  next if length ($c) != 40 || length ($bb) != 40 || $c !~ /^[0-9a-f]{40}$/ || $bb !~ /^[0-9a-f]{40}$/;
  my $cmt = fromHex ($c);
  my $b = fromHex ($bb);
  $b2c1{$cmt}{$b}++;
  $lines ++;
  print STDERR "$lines read\n" if (!($lines%100000000));
}

output ();

for $sec (0..($nsec -1)){
  untie %{$b2c{$sec}};
}

sub output {
  while (my ($k, $v) = each %b2c1){
    my $sec = (unpack "C", substr ($k, 0, 1))%$nsec;
    my %vs = ();
    if (defined $b2c{$sec}{$k}){
		my $v0 = $b2c{$sec}{$k};
      my $ns = length($v0)/20;
      for my $i (0..($ns-1)){
        my $c0 = substr ($v0, 20*$i, 20);      
        $vs{$c0}++ if $c0 ne $k;
      }
      for my $vv (keys %{$v}){
        $vs{$vv}++ if $vv ne $k;
      }
    }else{
		 %vs = %{$v};
    }
    my @shas = sort keys %vs;
    my $v1 = join '', @shas;
    $b2c{$sec}{$k} = $v1;
  }
}

