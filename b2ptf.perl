#!/usr/bin/perl -I /home/audris/lib64/perl5 -I /home/audris/lookup -I /home/audris/lib/x86_64-linux-gnu/perl

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
$to = $ARGV[2] if defined $ARGV[2];
$from = $ARGV[1] if defined $ARGV[1];
{
  open (FD, "$fbasei$sec.bin") or die "$!";
  binmode(FD);
  if ( -f "$fbasei$sec.idx"){
    open A, "$fbasei$sec.idx" or die ($!);
    while (<A>){
      chop ();
      $lines ++;
      next if $lines < $from;
      next if $to >= 0 && $lines > $to;
      my ($nn, $of, $len, $hash) = split (/\;/, $_, -1);
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
          if ($mode == 0100644){
	    my $bH = unpack "H*", $bytes;
            $name =~ s/\n/__NEWLINE__/g;
            $name =~ s/\r/__CR__/g;
            $name =~ s/;/__SEMICOLON__/g;
	    print "b;$bH;$hash;$name\n";
            #print "$name\n";
          }else{
	    if ($mode == 040000){
	      my $bH = unpack "H*", $bytes;
	      print "t;$bH;$hash;$name\n";
	    }
	  }
        }
      }else{
        exit (-1);
      }
    }
  }
}


