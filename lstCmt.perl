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
    my ($tree, $parents, $auth, $cmtr, $ta, $tc, @rest) = extrCmt ($codeC,"$s:$nn");
    my $msg = join '\n\n', @rest;
    if ($debug){
      $msg =~ s/[\r\n;]/ /g;
      $msg =~ s/^\s*//;
      $msg =~ s/\s*$//;
      $auth =~ s/;/ /g;
      print "$msg;$auth;$ta;$msg\n";
    }else{
      $msg =~ s/[\r\n]*$//;
      $msg =~ s/\r/__CR__/g;
      $msg =~ s/\n/__NEWLINE__/g; 
      $msg =~ s/;/SEMICOLON/g; 
      $auth =~ s/;/SEMICOLON/g; 
      $cmtr =~ s/;/SEMICOLON/g;
      my ($a, $e) = git_signature_parse ($auth, $msg);
      print "$msg;$tree;$parents;$a;$e;$auth;$cmtr;$ta;$tc;$msg\n";
    }
  }
}

1;
