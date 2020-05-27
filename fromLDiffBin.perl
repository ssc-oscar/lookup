#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl");
use strict;
use warnings;
use Compress::LZF ();

sub fromHex {
  return pack "H*", $_[0];
}

sub toHex {
  return unpack "H*", $_[0];
}

open BIN, "$ARGV[0]";
binmode (BIN);


my $off = 0;
while (<STDIN>){
  chop();
  my ($o, $l, $ll, $hline, $hblob, $c) = split (/;/, $_, -1);
  seek (BIN, $o, 0);
  my $buff;
  my $x = read (BIN, $buff, $l);
  $buff = safeDecomp ($buff);
  my ($bo, $bn);
  while ($buff =~ s/^(.+?)\0//s){
    my $n = $1;
    my $h = "";
    if (length ($buff) >= 41){
      $bo = substr($buff, 0, 20);
      $buff = substr ($buff, 20, length($buff) - 20);
      $bn = substr($buff, 0, 20);
      $buff = substr ($buff, 20, length($buff) - 20);
    }else{
      print STDERR "$o: no hash at $n\n";
      exit ();
    }
	if ($buff =~ s/^(.+?)\0//s){
	  my $diff = $1;
      print "$hline;$hblob;$c;$n;".toHex($bo).";".toHex($bn)."\n";
#print "$diff\n";
	}else{
      print STDERR "no diff at $o;$l;$n;".length($buff).";\n$buff\n"; 
    }
  }
}

sub safeDecomp {
 my ($codeC, @rest) = @_;
 my $len = length($codeC);
 if ($len >= 2147483647){
   return $codeC;
 }else{
    try {    
     return Compress::LZF::decompress ($codeC);
    } catch Error with {
     my $ex = shift;
     print STDERR "Error: $ex, for parameters @rest\n";
     return "";
    }
  }
}

sub safeComp {
 my ($code, @rest) = @_;
 try {
  my $len = length($code);
  if ($len >= 2147483647){
    print STDERR "Too large to compress: $len\n";
    return $code;
  }else{
    return Compress::LZF::compress ($code);
  }
 } catch Error with {
  my $ex = shift;
  print STDERR "Error: $ex, for parameters @rest\n";
  return "";
 }
}

