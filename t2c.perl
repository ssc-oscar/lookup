#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");

use strict;
use warnings;
use Error qw(:try);

use TokyoCabinet;
use Compress::LZF;
use cmt;

my $sec = $ARGV[0];
my $fbase="/data/All.blobs/commit_$sec";

sub extrTree {
  my $code = $_[0];
  my $tree = "";
  my ($pre, @rest) = split(/\n\n/, $code, -1);
  for my $l (split(/\n/, $pre, -1)){
    if ($l =~ m/^tree (.*)$/){
      $tree = $1;
      last;
    }
  }    
  return $tree;
}


open (FD, "$fbase.bin") or die "$!";
binmode(FD);
if ( -f "$fbase.idx"){
  open A, "$fbase.idx" or die ($!);
  while (<A>){
    chop ();
    my ($nn, $of, $len, $hash) = split (/\;/, $_, -1);
    my $h = pack 'H*', $hash;
    my $codeC = "";
    seek (FD, $of, 0);
    my $rl = read (FD, $codeC, $len);
    if ($rl == $len){
      my $to = safeDecomp ($codeC);
      my $tree = extrTree ($to);
      print "$tree;$hash\n";
    }
  }
}


