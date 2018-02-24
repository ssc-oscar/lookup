#!/usr/bin/perl -I /home/audris/lib64/perl5
use strict;
use warnings;
use Error qw(:try);

use Digest::SHA qw (sha1_hex sha1);
use TokyoCabinet;
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
                #print STDERR "Error: $ex in $msg\n";
                return "";
        }
}
  

my $sections = 128;

#for my $s (0..($sections-1)){
  my $fname = $ARGV[1];
  open (FD, "$fname.bin") or die "$!";
  binmode(FD);
  my @stat = stat "$fname.bin";
  my $lmax = $stat[7];

  open A, "cat $fname.idx|";
  #open B, ">$fname.idx1";
  my $oback = 0;
  my $lfix  = 0;
  while (<A>){
    chop();
    my $str = $_;
    my @x = split(/\;/, $str);
    my ($l, $s, $sec0, $hsha, @rest) = @x;
    $l += $lfix;
    if ($l + $s > $lmax){
      print STDERR "exceeds size $. l=$l lmax=$lmax lfix=$lfix s=$s hsha=$hsha\n";
      exit();
    }
    my $sha = fromHex ($hsha);
    my $sec = hex (substr($hsha, 0, 2)) % $sections;
    my $codeC = "";
    seek (FD, $l, 0);
    my $rl = read (FD, $codeC, $s);
    my $msg = "s=$s, hsha=$hsha, l=$l sec=$sec";
    my $code = $codeC;
    if ($s < 2147483647){# longer than that is not compressed
      $code = safeDecomp ($codeC, $msg);
    }
    my $len = length ($code);
    my $hsha1 = sha1_hex ("$type $len\0$code");
    if ($code eq "" || $hsha ne $hsha1 || $l != $oback){
      print STDERR "$hsha != $hsha1;$l ne $oback;$msg len=$len\n" if $code ne "";
      if ($code eq "" || $l != $oback){
        my ($ch, $cd) = experiment ($l, $s, $lmax);
        $hsha1 = sha1_hex ("$type $ch\0$cd");
        print STDERR "$hsha != $hsha1\n" if $hsha ne $hsha1;
        my $diff = $ch - $s;
        $s = $ch;
        $lfix += $diff;
        print STDERR "$ch;$diff;$lfix;$l\n";
      }
    }
    #print B "$l;$s;$hsha\n";
    $oback = $l+$s;
  }
#}
#
sub experiment {
  my ($l, $s, $lmax) = @_;
  my $smax = $s + 16001;
  $smax = $lmax-$l if $smax > $lmax-$l; 
  seek (FD, $l, 0);
  my $codeC;
  my $rl = read (FD, $codeC, $smax);
  for my $area (10, 30, 100, 200, 1000, 2000, 4000, 16000){
    my ($res, $code) = exSmall ($codeC, $s, $area); 
    return ($res, $code) if $res > 0;
  }
  print STDERR "could not find $l, $s\n";
  exit ();
}

sub exSmall {
  my ($codeC, $s, $area) = @_;
  my $sfr = $s-$area;
  $sfr = 1 if $sfr < 1;
  my $sto = $s+$area;  
  for my $s0 ($sfr..$sto){
    my $tmp = substr($codeC, 0, $s0);
    my $code = safeDecomp ($tmp, "");
    return ($s0, $code) if length($code) > 0;
  }
  return 0;
}
#
sub toHex { 
        return unpack "H*", $_[0]; 
} 

sub fromHex { 
        return pack "H*", $_[0]; 
} 

