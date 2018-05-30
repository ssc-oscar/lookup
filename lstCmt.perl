#!/usr/bin/perl -I /home/audris/lib64/perl5 -I /da3_data/lookup
use strict;
use warnings;
use Error qw(:try);
use cmt;
use Compress::LZF;

my $debug = 0;
$debug = $ARGV[0]+0 if defined $ARGV[0];
my $sections = 128;

my $fbase="/data/All.blobs/commit_";
for my $s (0..($sections-1)){
  open A, "$fbase$s.idx";
  open FD, "$fbase$s.bin";
  binmode(FD);
  while (<A>){
    chop();
    my ($nn, $of, $len, $hash) = split (/\;/, $_, -1);
    my $h = fromHex ($hash);
    #seek (FD, $bof, 2);
    #seek (FD, $of, 0);
    my $codeC = "";
    my $rl = read (FD, $codeC, $len);
    cleanCmt ($codeC, $hash, $debug);
  }
}

1;
