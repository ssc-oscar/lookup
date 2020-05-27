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


my %p2c;
my $sec;
my $nsec = 8;
$nsec = $ARGV[1] if defined $ARGV[1];

for $sec (0..($nsec -1)){
  my $fname = "$ARGV[0].$sec.tch";
  tie %{$p2c{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $fname\n";
}

my (%fix, %bad);
while (<STDIN>){
  chop();
  my ($p, $pc) = split (/\;/, $_, -1);
  $fix{$pc}{$p}++ if $p ne $pc;
  $bad{$p}++ if $p ne $pc;
}

my %vres;
while (my ($k, $v) = each %fix){
  my %tmp = ();
  for my $p (keys %{$v}, $k){
    my $sec = (unpack "C", substr ($p, 0, 1))%$nsec;
    my $v1 = $p2c{$sec}{$p};
    my $ns = length($v1)/20;
    for my $i (0..($ns-1)){
      my $c = substr ($v, 20*$i, 20);
      $tmp{$c}++;
    }
  }
  $vres{$k} = join '', keys %tmp;
}
print STDERR "created a patch\n";


while (my ($k, $v) = each %vres){
  my $sec = (unpack "C", substr ($k, 0, 1))%$nsec;
  $p2c{$sec}{$k} = $v;
}
while (my ($k, $v) = each %bad){
  my $sec = (unpack "C", substr ($k, 0, 1))%$nsec;
  undef $p2c{$sec}{$k};
}

for $sec (0..($nsec -1)){
  untie %{$p2c{$sec}};
}

