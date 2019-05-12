#!/usr/bin/perl -I /home/audris/lib64/perl5 -I /home/audris/lib/x86_64-linux-gnu/perl
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

#BEGIN { $SIG{'__WARN__'} = sub { print STDERR $_[0]; } };

my $split = 32;

my (%c2ta);
my $sec = $ARGV[0];

for my $s (0..($split-1)){ 
  tie %{$c2ta{$s}}, "TokyoCabinet::HDB", "/fast/c2taFO.$s.tch", TokyoCabinet::HDB::OREADER,
      16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open /fast/c2taFO.$s.tch\n";
}
my $bp = "";
my %as = (); 
while (<STDIN>){
  chop();
  my ($bh, $ch) = split(/\;/, $_, -1);
  my $bb = toHex($bh);
  if ($bp ne "" && $bp ne $bb){
    my $f = (sort { $a+0 <=> $b +0 } keys %as)[0];
    my @aa = sort keys %{$as{$f}};
    print STDERR "same time $bh;$ch;@aa\n" if $#aa>0;
    my ($ch0, $a) = split (/;/, $aa[0], -1);
    print "$bh;$f;$a;$ch0\n";
    %as = ();
  }
  my $c = fromHex ($ch);
  my $s = (unpack "C", substr ($c, 0, 1)) % $split;
  if (defined $c2ta{$s}{$c}){
    my ($t, $a) = split (/;/, $c2ta{$s}{$c});
    $as{$t}{"$ch;$a"}++;
  }else{
    print STDERR "no time for $ch in $bh\n";
  }
  $bp = $bb;  
}

for my $s (0..($split-1)){ 
  untie %{$c2ta{$s}};
};




