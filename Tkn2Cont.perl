#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");

use strict;
use warnings;
use Error qw(:try);

use TokyoCabinet;
use Compress::LZF;
use cmt;
my $sections = 128;

my $fbaseo="All.sha1c/tkns_";
my $fbasei ="/data/All.blobs/tkns";

my (%fhoso);
my $pre = "/fast";
for my $sec (0..127){
  tie %{$fhoso{$sec}}, "TokyoCabinet::HDB", "$pre/${fbaseo}$sec.tch", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,
      16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
   or die "cant open $pre/$fbaseo$sec.tch\n";
}
  my $nn = 0;
for my $i (0..127){
  print STDERR "starting $i\n";
  open A, "zcat $fbasei$i.idx.gz|" or die ($!);
  open B, "$fbasei$i.bin" or die ($!);
  while (<A>){
    chop ();
    my @x = split (/\;/, $_, -1);
    my $of = $x[1];
    my $len = $x[2];
    my $hash = $x[4];
    next if !defined $hash || $hash !~ /^[0-9a-h]{40}$/;
    my $h = fromHex ($hash);
    my $sec = segB ($h, 128);
    if (defined $fhoso{$sec}{$h}){
       #print "done/updated $nn\n";
    }else{
      seek (B, $of, 0);
      my $codeC = "";
      my $rl = read (B, $codeC, $len);
      $fhoso{$sec}{$h} = $codeC if $len == $rl;
      $nn++;
    }
  }
}
for my $sec (0..127){
  untie %{$fhoso{$sec}};
}

