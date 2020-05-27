#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl");
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
  tie %{$b2c{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $fname\n";
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
    my $sec = (unpack "C", substr ($k, 0, 1))%$nsec;
    $b2c{$sec}{$k} = $v1;
  }
}




