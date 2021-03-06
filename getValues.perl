#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
#
use strict;
use warnings;
use Error qw(:try);
use cmt;
use Getopt::Long qw(GetOptions);

use TokyoCabinet;
use Compress::LZF;
my $flat="n"; 
GetOptions('flat=s' => \$flat);



my $fname="$ARGV[0]";
my (%clones);
my $hdb = TokyoCabinet::HDB->new();

my $f1 = "h";
my $f2 = "h";

my $split = 32;



my $offset = 0;
my $types = $fname;
$types =~ s|.*/||;
$types =~ s|Full[A-Z]$||;
my ($t1, $t2) = split(/2/, $types);
$f1 = "s" if ($t1 =~ /^[afpP]$/);

$f2 = "cs" if ($t2 =~ /^[afpP]$/);

$f1 = "h" if ($t1 =~ /^[cb]$/ || $t1 =~ /^(ob|td)$/);
$f2 = "h" if ($t2 =~ /^[cb]$/ || $t2 =~ /^(cc|pc|ob|td)$/);

$f2 = "sh" if $types eq "b2a";
$f2 = "s" if $t2 =~ /^ta$/;
$f2 = "s" if $types eq "b2tk"; 
$f2 = "s" if $types eq "td2f"; 
$f2 = "r" if $types =~ /^c2[hr]$/;

$f1 = "s" if ($t1 eq "PS" || $t1 eq "PF" || $t1 eq "PFS"); 
$f2 = "s" if ($t2 eq "PS" || $t2 eq "PF" || $t2 eq "PFS"); 

$f1 = $ARGV[1] if defined $ARGV[1];
$f2 = $ARGV[2] if defined $ARGV[2];

if ($types eq "p2P" || $types eq "P2p" ||  $types eq "a2A" || $types eq "A2a"){
  $split = 1;
  $f1 = "s";
  $f2 = "cs";
  $f2 = "cs" if ($types eq "P2p" ||$types eq "A2a");
}
$split = $ARGV[3] if defined $ARGV[3];

sub get {
  my ($c, $s) = @_;
  return $clones{$s}{$c} if defined $clones{$s};
  if ($split > 1){
    if(!tie(%{$clones{$s}}, "TokyoCabinet::HDB", "$fname.$s.tch",
       TokyoCabinet::HDB::OREADER | TokyoCabinet::HDB::ONOLCK)){
      die "tie error for $fname.$s.tch\n";
    }
  }else{
    if(!tie(%{$clones{"0"}}, "TokyoCabinet::HDB", "$fname.tch", 
        TokyoCabinet::HDB::OREADER | TokyoCabinet::HDB::ONOLCK)){
      die "tie error for $fname.tch\n";
    }
  }
  return $clones{$s}{$c};
}

while (<STDIN>){
  chop();
  my $large = 0;
  my ($ch, @rest) = split(/;/, $_, -1);
  my $extra = "";
  $extra = join ';', @rest if $#rest >= 0;
  my $l = length($ch);
  my $c = $ch;
  my $s = segH ($c, $split);
  if ($f1 =~ /h/){
    $c = fromHex($ch);
  }else{
    $s = sHash ($c, $split);
    $c = safeComp ($ch) if $f1 =~ /c/;
  }
  my $v = get ($c, $s);
  if (!defined $v){
    my $lF = "$fname.$s.tch.large.";
    if ($f1 =~ /h/){
      $lF .= $ch;
    }else{
      $lF .= sprintf "%.8x", sHashV ($c);
    }
    if (-f $lF){
      $large = 1;
      my $len = -s $lF;
      if ($f2 =~ /h/){
        open VAL, $lF;
        $v="";
        read (VAL, $v, $len);
      }else{
        open VAL, "zcat $lF|";
        <VAL>; #drop first line: it is just the key
        $v="";
        while (<VAL>){ $v .= $_; }
      } 
      #print STDERR "big file\n";
      #print "$ch\n";
    }else{
      #print "$ch\n";
      print STDERR "no $ch in $fname\n";
      next;
    }
  }
  if ($f2 =~ /r/){
    my $h = toHex (substr($v, 0, 20));
    my $d = unpack 'w', (substr($v, 20, length($v) - 20));
    print "$ch\;$h\;$d\n";
  }else{
    my $res = ";$v";
    if ($f2 =~ /cs/){
      if ($large){
        $res = ";".$v;
      }else{
        $res = ';'.safeDecomp ($v);
      }
    }      
    if ($f2 eq "h"){
      my $n = length($v)/20;
      $res="";
      for my $i (0..($n-1)){
        $res .= ";" . toHex (substr($v, $i*20, 20));
      }
    }
    if ($f2 eq "sh"){
      my $c = toHex(substr($v, length($v)-20, 20));
      my ($t, $a) = split(/;/, substr($v, 0, length($v)-20));
      $res = ";$t;$a;$c"; 
    }
	  if ($flat eq "n"){
      if ($extra eq  ""){
		    print "$ch$res\n";
	    }else{ 
        print "$ch;$extra$res\n";
      }
    }else{
      $res =~ s/^;//;
	  $ch .= ";$extra" if $extra ne "";
      for my $vv (split(/;/, $res, -1)){
        print "$ch;$vv\n";
      }
    }
	}
  $offset++;
}
for my $s (0..($split-1)){
  untie %{$clones{$s}} if defined $clones{$s};
}

