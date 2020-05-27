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


my $detail = 0;
$detail = $ARGV[1]+0 if defined $ARGV[1];
my $split = 32;
$split = $ARGV[2] + 0 if defined $ARGV[2];

my (%has, %c2cc);


for my $sec (0..($split-1)){
  tie %{$c2cc{$sec}}, "TokyoCabinet::HDB", "/fast/All.sha1c/c2cc.$sec.tch", TokyoCabinet::HDB::OREADER,
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open /da4_data/basemaps/c2cc.$sec.tch\n";
}

for my $sec (0..127){
  tie %{$has{$sec}}, "TokyoCabinet::HDB", "/fast/All.sha1/sha1.commit_$sec.tch", TokyoCabinet::HDB::OREADER,
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
        or die "cant open /da4_data/basemaps/c2cc.$sec.tch\n";
}

my $pp = "";
my %tmp = ();
while (<STDIN>){
  chop();
  my ($p, $ch) = split(/\;/, $_, -1);
  if ($pp eq $p || $pp eq ""){
    $tmp{$ch}++;
  }else{
    out ($pp);
    %tmp = ();
    $tmp{$ch}++;
  }
  $pp=$p;
}
out ($pp);

sub out {
  my $p = $_[0];
  my @t = keys %tmp;
  print "$p;$#t";
  for my $ch (@t){
    my $c = fromHex ($ch);
    my $sb = unpack "C", substr ($c, 0, 1);
    my $s1 = $sb % 128;
    if (defined $has{$s1}{$c}){
      my $s = $sb % $split;
      if (!defined $c2cc{$s}{$c}){
        print ";$ch";
      }
    }else{
      print ";-$ch";
    }
  }
  print "\n";
}


for my $sec (0..($split-1)){
  untie %{$c2cc{$sec}};
}
for my $sec (0..127){
  untie %{$has{$sec}};
}

