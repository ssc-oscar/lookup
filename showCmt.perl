#!/usr/bin/perl -I /home/audris/lib64/perl5 -I /da3_ddata/lookup
use strict;
use warnings;
use Error qw(:try);
use cmt;
use TokyoCabinet;

my $debug = 0;
$debug = $ARGV[0]+0 if defined $ARGV[0];
my $sections = 128;
my $parts = 2;

my $fbasec="All.sha1c/commit_";

my (%fhob, %fhost, %fhosc);
for my $sec (0 .. ($sections-1)){
  my $pre = "/fast1/";
  $pre = "/fast1" if $sec % $parts;
  tie %{$fhosc{$sec}}, "TokyoCabinet::HDB", "$pre/${fbasec}$sec.tch", TokyoCabinet::HDB::OREADER,  
	16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $pre/$fbasec$sec.tch\n";
}

while (<STDIN>){
  chop();
  my $cmt = $_;
  my $sec = hex (substr($cmt, 0, 2)) % $sections;
  my $cB = fromHex ($cmt);
  if (! defined $fhosc{$sec}{$cB}){
     print STDERR "no commit $cmt in $sec\n";
  }else{
    cleanCmt ($fhosc{$sec}{$cB}, $cmt, $debug);
  }
}

for my $sec (0 .. ($sections-1)){
  untie %{$fhosc{$sec}};
}

