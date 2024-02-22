#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");

use strict;
use warnings;
use Compress::LZF;
use TokyoCabinet;
use Time::Local;
use Error qw(:try);
use cmt;

my $lines = 0;
my $trees = 0;
my $fbasei ="tree_";
my $sec = $ARGV[0];
my $from = 0;
my $to = -1;
my $start = defined $ARGV[1] ? $ARGV[1] : 0;
my $end = defined $ARGV[2] ? $ARGV[2] : -1;

#$to = $ARGV[2] if defined $ARGV[2];
#$from = $ARGV[1] if defined $ARGV[1];
{
  open (FD, "$fbasei$sec.bin") or die "$! $fbasei$sec.bin";
  binmode(FD);
  if ( -f "$fbasei$sec.idx"){
    open A, "$fbasei$sec.idx" or die ("$! $fbasei$sec.idx");
    while (<A>){
      chop ();
      my ($nn, $of, $len, $hash) = split (/\;/, $_, -1);
      next if $start > $nn;
      exit if $end < $nn && $end >= 0;
      #print "$nn, $of, $len, $hash\n";
      #next if $trees < $from;
      #next if $to >= 0 && $trees > $to;
      #my ($nn, $of, $len, $hash) = split (/\;/, $_, -1);
      my $h = pack 'H*', $hash;
      my $codeC = "";
      seek (FD, $of, 0);
      my $rl = read (FD, $codeC, $len);
      $trees ++;
      if ($rl == $len){
        my $to = safeDecomp ($codeC);
        while ($to =~ s/^([0-7]+) (.+?)\0(.{20})//s) {
          $lines ++;
          if (!($lines%100000000)){
            print STDERR "$lines lines and $trees trees done\n";
            #goto DONE;
          }
          my ($mode, $name, $bytes) = (oct($1),$2,$3);
	  if ($mode == 040000){
            my $bH = unpack "H*", $bytes;
            $name =~ s/\n/__NEWLINE__/g;
            $name =~ s/\r/__CR__/g;
            $name =~ s/;/SEMICOLON/g;
            print "$bH;$hash;$name\n";
          }
        }
      }else{
        exit (-1);
      }
    }
  }
}



