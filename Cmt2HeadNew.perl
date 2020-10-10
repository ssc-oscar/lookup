#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
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
BEGIN { $SIG{'__WARN__'} = sub { if (0) { print STDERR $_[0] } } };

my $split = 32;

my (%c2r, %c2pc);
my $ver = $ARGV[0];
my $K = 0;
$K = $ARGV[1] if defined $ARGV[1];

for my $s (0..($split-1)){ 
  tie %{$c2r{$s}}, "TokyoCabinet::HDB", "/fast/c2hFull$ver.$s.tch", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,
   or die "cant open /fast/c2hFull$ver.$s.tch\n";
}

if ($K == 0){
  for my $s (0..($split-1)){
    open A, "zcat cnoccFull$ver.$s|";
    while (<A>){
      chop ();
      my $rch = $_;
      my $rc = fromHex ($rch);
      my $s1 = (unpack "C", substr ($rc, 0, 1)) % $split;
      my $d = 0; my $dp = pack 'w', $d;
      $c2r{$s1}{$rc} = $rc.$d if (!defined $c2r{$s1}{$rc});
    }
  }
}

for my $s (0..($split-1)){
  open A, "zcat c2h$K$ver$s.s|";
  while (<A>){
    chop ();
    my ($ch, $rch) = split (/;/, $_, -1);
    my $c = fromHex ($ch);
    my $rc = fromHex ($rch);
    my $d = $K + 1;
    my $dp = pack 'w', $d;
    my $s0 = (unpack "C", substr ($c, 0, 1)) % $split;
    if (defined $c2r{$s0}{$c}){
       #print STDERR "$ch;$d\n";    
       my $v = $c2r{$s0}{$c};
       my $rcp = toHex(substr($v, 0, 20));
       my $pd = unpack "w", substr($v, 20, length($v)-20);
       if ($pd > $d){
         print STDERR "for $ch the head $rcp is at depth $pd which is higher than for $rch which is at depth $d\n";
	 exit;
       }
    }else{
      $c2r{$s0}{$c} = $rc.$dp;
    }
    #print "$s1;$s0;$rch;$ch\n";
  }
}

for my $s (0..($split-1)){ 
  untie %{$c2r{$s}};
};


