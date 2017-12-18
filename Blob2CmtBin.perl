#!/usr/bin/perl -I /home/audris/lib64/perl5
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

for $sec (0..15){
  tie %{$b2c{$sec}}, "TokyoCabinet::HDB", "$ARGV[0].$sec.tch", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $ARGV[0].$sec.tch\n";
}

my %b2c1;
my $lines = 0;
while (<STDIN>){
  chop();
  my ($c, $f, $bb, $p) = split(/\;/, $_, -1);
  next if length ($c) != 40 || length ($bb) != 40;
  my $cmt = fromHex ($c);
  my $b = fromHex ($bb);
  $b2c1{$b}{$cmt}++;
  $lines ++;
  print STDERR "$lines read\n" if (!($lines%100000000));
}

output ();

for $sec (0..15){
  untie %{$b2c{$sec}};
}

sub output {
  while (my ($k, $v) = each %b2c1){
    my @shas = sort keys %{$v};
    my $v1 = join '', @shas;
    my $sec = (unpack "C", substr ($k, 0, 1))%16;
    $b2c{$sec}{$k} = $v1;
  }
}




