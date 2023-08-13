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
my $start = defined $ARGV[1] ? $ARGV[1] : 0;
my $end = defined $ARGV[2] ? $ARGV[2] : -1;
{
  open (FD, "$fbasei$sec.bin") or die "$!";
  binmode(FD);
  if ( -f "$fbasei$sec.idx"){
    open A, "$fbasei$sec.idx" or die ($!);
    while (<A>){
      chop ();
      my ($nn, $of, $len, $hash) = split (/\;/, $_, -1);
      next if $start > $nn;
      exit if $end < $nn && $end >= 0;
      seek (FD, $of, 0);
      my $h = pack 'H*', $hash;
      my $codeC = "";
      my $rl = read (FD, $codeC, $len);
      $trees ++;
      if ($rl == $len){
        my $to = safeDecomp ($codeC);
        while ($to =~ s/^([0-7]+) (.+?)\0(.{20})//s) {
          $lines ++;
          if (!($lines%10000000)){
            print STDERR "$lines lines and $trees trees done\n";
            #goto DONE;
          }
          my ($mode, $name, $bytes) = (oct($1),$2,$3);
          if ($mode == 040000){
	    my $bH = unpack "H*", $bytes;
	    print "$bH;$hash;$name\n";
            #print "$name\n";
          }
        }
      }else{
        exit (-1);
      }
    }
  }
}


