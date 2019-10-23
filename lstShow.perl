#!/usr/bin/perl -I /home/audris/lib64/perl5 -I /home/audris/lib/x86_64-linux-gnu/perl
#
use strict;
use warnings;
use Error qw(:try);

use TokyoCabinet;
use Compress::LZF;

my $fname="$ARGV[0]";
my (%clones);
my $hdb = TokyoCabinet::HDB->new();

my $f1 = "h";
my $f2 = "h";
$f1 = $ARGV[1] if defined $ARGV[1];
$f2 = $ARGV[2] if defined $ARGV[2];


if(!tie(%clones, "TokyoCabinet::HDB", "$fname",
                  TokyoCabinet::HDB::OREADER | TokyoCabinet::HDB::ONOLCK)){
        print STDERR "tie error for $fname\n";
}
sub toHex { 
   return unpack "H*", $_[0]; 
} 
sub fromHex { 
   return pack "H*", $_[0]; 
} 

my $offset = 0;

while (<STDIN>){
  chop();
  my $ch = $_;
  my $l = length($ch);
  my $c = $ch;
  $c = safeComp ($ch) if $f1 =~ /c/;
  $c = fromHex($ch) if $f1 =~ /h/;
  my $v = $clones{$c};
  if ($f2 =~ /r/){
    my $h = toHex (substr($v, 0, 20));
    my $d = unpack 'w', (substr($v, 20, length($v) - 20));
    print "$offset\;$l\;$ch\;$h\;$d\n";
  }else{
    my $res = ";$v";
    if ($f2 =~ /cs/){
      $res = ";".$v;
      $res = ';'.safeDecomp ($v);
    }      
    if ($f2 =~ /h/){
      my $n = length($v)/20;
      $res="";
      for my $i (0..($n-1)){
        $res .= ";" . toHex (substr($v, $i*20, 20));
      }
    }
    print "$ch$res\n";
  }
  $offset++;
}
untie %clones;

sub safeDecomp {
  my ($codeC, $msg) = @_;
  try {
    my $code = decompress ($codeC);
    return $code;
  } catch Error with {
    my $ex = shift;
    print STDERR "Error: $ex, $msg\n";
    return "";
  }
}
sub safeComp {
  my ($codeC, $msg) = @_;
  try {
    my $code = compress ($codeC);
    return $code;
  } catch Error with {
    my $ex = shift;
    print STDERR "Error: $ex, $msg\n";
    return "";
  }
}
