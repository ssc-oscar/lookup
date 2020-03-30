#!/usr/bin/perl -I  /home/audris/lookup -I /home/audris/lib64/perl5 -I /home/audris/lib/x86_64-linux-gnu/perl

use strict;
use warnings;
use Error qw(:try);
use Compress::LZF;
use TokyoCabinet;
use cmt;

my ($tmp, %b2a);

my $fname = "$ARGV[0]";
tie %b2a, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
    507377777, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
   or die "cant open $fname\n";

my $tt = 2000000000;   
my $lines = 0;
my $phb = "";
my $l = <STDIN>;
chop($l);
my ($hb, $t, $a, $hc) = split (/\;/, $l);
$phb = $hb;
$tmp = "$a;".fromHex($hc);
if ($t ne ""){
  $tt = $t;
}

while (<STDIN>){
  chop();
  $lines ++;
  ($hb, $t, $a, $hc) = split (/\;/, $_);
  if ($hb !~ m|^[0-9a-f]{40}$|){
    print STDERR "bad sha:$_\n";
    next;
  }
  if ($phb ne $hb){
    output();
    if ($t ne ""){
      $tt = $t + 0;
    }else{
      $tt = 2000000000;
    }
    $tmp = "$a;".fromHex($hc);
    $phb = $hb;
  }else{   
    if ($t ne "" && $tt > $t){
      $tmp = "$a;".fromHex($hc);
      $tt = $t;
    }
  }
  if (!($lines%100000000)){
    print STDERR "$lines done\n";
  }
}
output();

sub output {
  if ($tt == 2000000000){
    print STDERR "zero time for $phb\n";
    $tt = "";
  }
  my $b = fromHex($phb);
  $b2a{$b} = "$tt;$tmp";
}

untie %b2a;

print STDERR "read $lines\n";

