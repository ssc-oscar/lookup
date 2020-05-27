#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl");
use strict;
use warnings;
use Error qw(:try);
use cmt;
use TokyoCabinet;

my $debug = 0;
$debug = $ARGV[0]+0 if defined $ARGV[0]; #select output format based on the cleantCmt function in cmt.pm
my $sections = 128;
my $raw = ""; #produce .idx/.bin database as in All.blobs
$raw = $ARGV[2] if defined $ARGV[2];

my $fbasec="All.sha1c/commit_";

my $ss = -1; #input is from from any of the 128 databases; if $ss >= 0: opens only the corrresponding database
$ss = $ARGV[1]+0 if defined $ARGV[1];
my (%fhob, %fhost, %fhosc);
for my $sec (0 .. ($sections-1)){
  my $pre = "/fast/";
  next if $ss > 0 && $sec != $ss;
  tie %{$fhosc{$sec}}, "TokyoCabinet::HDB", "$pre/${fbasec}$sec.tch", TokyoCabinet::HDB::OREADER,  
	16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $pre/$fbasec$sec.tch\n";
}

my $off = 0;
if ($raw ne ""){
  open A, ">$raw.idx";
  open B, ">$raw.bin";
}

while (<STDIN>){
  chop();
  my ($cmt, $rest) = split(/;/, $_, -1);
  my $sec = hex (substr($cmt, 0, 2)) % $sections;
  my $cB = fromHex ($cmt);
  if (! defined $fhosc{$sec}{$cB}){
     print STDERR "no commit $cmt in $sec\n";
  }else{
    if ($raw ne ""){
      my $cont = safeDecomp ($fhosc{$sec}{$cB});
      my $len = length($cont);
      print A "$cmt;$rest;$off;$len\n";
      $off+= $len;
      print B "$cont";
    }else{
      cleanCmt ($fhosc{$sec}{$cB}, $cmt, $debug);
    }
  }
}

for my $sec (0 .. ($sections-1)){
  next if $ss > 0 && $sec != $ss;
  untie %{$fhosc{$sec}};
}

