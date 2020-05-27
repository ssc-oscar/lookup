#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl");

use strict;
use warnings;
use Error qw(:try);
use Compress::LZF;
use TokyoCabinet;
use cmt;

my (%tmp, %c2p, %c2p1);

my $fname = "$ARGV[0]";
tie %c2p, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
      16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $fname\n";

my $lines = 0;
while (<STDIN>){
  chop();
  $lines ++;
  my ($hb, $t, $a, $hc) = split (/\;/, $_);
  if ($hb !~ m|^[0-9a-f]{40}$|){
    print STDERR "bad b sha:$_\n";
    next;
  }
  my $b = fromHex ($hb);
  if ($hc !~ m|^[0-9a-f]{40}$|){
    print STDERR "bad c sha:$_\n";
    next;
  }
  my $c = fromHex ($hc);
  $c2p{$c} = "$t;$a;$c";
  if (!($lines%100000000)){
    print STDERR "$lines done\n";
  }
}

print STDERR "read $lines\n";

