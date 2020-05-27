#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");

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

my %c2b;
tie %c2b, "TokyoCabinet::HDB", $ARGV[0], TokyoCabinet::HDB::OREADER,
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $ARGV[0]\n";

my %b2c;
my $lines = 0;
while (my ($c, $v) = each %c2b){
  my $ns = length($v)/20;
  for my $i (0..($ns-1)){
    my $b = substr ($v, 20*$i, 20);
    $b2c{$b}{$c}++;
  }
  $lines ++;
  print STDERR "$lines done\n" if (!($lines%500000)); 
  #last if $lines > 100000; 
}  
untie %c2b;


my $sec;
my %b2c1;

for $sec (0..15){
  tie %{$b2c1{$sec}}, "TokyoCabinet::HDB", "$ARGV[1].$sec.tch", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $ARGV[1].$sec.tch\n";
}

output ();

for $sec (0..15){
  untie %{$b2c1{$sec}};
}

sub output {
  while (my ($k, $v) = each %b2c){
    my @shas = sort keys %{$v};
    my $v1 = join '', @shas;
    my $sec = (unpack "C", substr ($k, 0, 1))%16;
    $b2c1{$sec}{$k} = $v1;
  }
}




