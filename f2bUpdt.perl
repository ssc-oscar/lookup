#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");

use strict;
use warnings;
use Compress::LZF;
use TokyoCabinet;
use Time::Local;



my $lines = 0;
my $trees = 0;
my %f2b = ();
my $fbasei ="/data/All.blobs/tree_";
my $fbaseio ="/data/All.blobs.old/tree_";
my $outN = $ARGV[0];
my $type = "file";
my $cnst = 0100644;
if (defined $ARGV[1]){
  $type = $ARGV[1];
  $cnst = 040000 if $type eq "tree" || "t2pt"; 
}

while (<STDIN>){
  chop();
  my $sec = $_;
  print STDERR "doing $sec\n";
  open (FD, "$fbasei$sec.bin") or die "$!";
  binmode(FD);
  if ( -f "$fbasei$sec.idx" && -f "$fbaseio$sec.idx"){
    open A, "tail -1 $fbaseio$sec.idx|" or die ($!);
    my $str = <A>;
    chop ($str);
    my ($last_nn, $last_of, $last_len, $last_hash) = split (/\;/, $str, -1);    
    open A, "tac $fbasei$sec.idx|" or die ($!);
    my $bof = 0;
    while (<A>){
      chop ();
      my ($nn, $of, $len, $hash) = split (/\;/, $_, -1);
      my $h = pack "H*", $hash;
      #now check if it has been processed
      if ($hash eq $last_hash){
         if ($nn ne $last_nn || $of ne $last_of || $len ne $last_len){
            print STDERR "mismatch $nn, $of, $len, $hash vs $last_nn, $last_of, $last_len, $last_hash\n";
         }
			last;
      }
      $bof -= $len;
      my $codeC = "";
      seek (FD, $bof, 2);
      my $rl = read (FD, $codeC, $len);
      $trees ++;
      if ($rl == $len){
        my $to = decompress ($codeC);
        while ($to =~ s/^([0-7]+) (.+?)\0(.{20})//s) {
          $lines ++;
          if (!($lines%100000000)){
            print STDERR "$lines lines and $trees trees done\n";
            #goto DONE;
          }
          my ($mode, $name, $bytes) = (oct($1),$2,$3);
          my ($key, $val) = ($name, $bytes);
          ($key, $val) = ($bytes, $h) if $type eq "t2pt" || $type eq "b2pt";
          if ($mode == $cnst && ! defined $f2b{$key}{$val}){
            $f2b{$key}{$val} = 1;
            #print "$name\n";
          }
        }
      }else{
        print STDERR "problem reading at nn=$nn, of=$of, len=$len, got $rl\n";
        exit (-1);
      }
    }
  }
}

DONE: 

print STDERR "writing\n";
my %out;
tie %out, "TokyoCabinet::HDB", "$outN", TokyoCabinet::HDB::OWRITER |  TokyoCabinet::HDB::OCREAT,
  16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
  or die "cant open $outN\n";

while (my ($k, $v) = each %f2b){
  $out{$k} = join "", sort keys %{$v};
  #my $b = unpack "H*", $k;
  #print "$b\;".(join "", sort keys %{$v})."\n";
}
untie %out;

