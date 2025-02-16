#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
use strict;
use warnings;
use Error qw(:try);

use Digest::SHA qw (sha1_hex sha1);
use Compress::LZF;

my $type = $ARGV[0];
my $ncheck = 1;
$ncheck = $ARGV[2] if defined $ARGV[2];

sub safeDecomp {
  my ($codeC, $msg) = @_;
  try {
    my $code = decompress ($codeC);
    return $code;
  } catch Error with {
     my $ex = shift;
     print STDERR "Error: $ex in $msg\n";
     return "";
  }
}
my $fname = $ARGV[1];
open (FD, "$fname.bin") or die "$!";
binmode(FD);
my @stat = stat "$fname.bin";

open A, "tac $fname.idx|";
my $lst = <A>;
my ($nnn, @rest) = split(/;/, $lst, -1);
$lst = $nnn-$ncheck;

open A, "$fname.idx";
#my $oback = 0;
while (<A>){
  chop();
  my @x = split(/\;/);
  my ($o, $l, $s, $hsha, @rest) = @x;
  $hsha = $rest[0] if $type eq "blob" && $#rest > 0;
  next if $o < $lst;
  if ($l+$s > $stat[7]){
    print STDERR "overflow for  $stat[7] at o=$o, l=$l, s=$s, hsha=$hsha, @rest\n";
    exit();
  }
  seek (FD, $l, 0) if $lst == $o;
  #$oback -= $s;
  my $sha = fromHex ($hsha);
  my $codeC = "";
  #seek (FD, $oback, 2);
  my $rl = read (FD, $codeC, $s);

  #my $off = tell (FD);

  my $msg = "s=$s, hsha=$hsha, o=$o, l=$l";
  my $code = safeDecomp ($codeC, $msg);
  my $len = length ($code);
  #print "$code\n";
  my $hsha1 = sha1_hex ("$type $len\0$code");
  print STDERR "$hsha != $hsha1;decomp len=$len;$msg\n" if $hsha ne $hsha1 || $len == 0;
}

sub toHex { 
  return unpack "H*", $_[0]; 
} 

sub fromHex { 
  return pack "H*", $_[0]; 
} 

