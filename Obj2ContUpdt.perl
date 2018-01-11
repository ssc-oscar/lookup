#!/usr/bin/perl -I /home/audris/lib64/perl5
use strict;
use warnings;
use Error qw(:try);

use TokyoCabinet;
use Compress::LZF;

sub toHex { 
        return unpack "H*", $_[0]; 
} 

sub fromHex { 
        return pack "H*", $_[0]; 
} 

my $sections = 128;

my $type = $ARGV[0];

my $fbase="All.sha1c/${type}_";
my $fbasei ="/data/All.blobs/${type}_";
my $fbaseOld ="/data/All.blobs.old/${type}_";

my (%fhos);
my $sec = $ARGV[1];
my $nTot = -1;
$nTot = $ARGV[2] if defined $ARGV[2];
{
  my $lhash;
  if ( -f "$fbaseOld$sec.idx"){
     open A, "tac $fbaseOld$sec.idx|head -1|" or die ($!);
     while (<A>){
       chop ();
       my ($nn, $of, $len, $hash) = split (/\;/, $_, -1);
       $lhash = $hash;
     }
  }else{
    die "No old idx: $fbaseOld$sec.idx\n";
  }
  print "up to $lhash\n";

  my $count = 0;
  my $pre = "/fast1";
  tie %{$fhos{$sec}}, "TokyoCabinet::HDB", "$pre/${fbase}$sec.tch", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $pre/$fbase$sec.tch\n";  
  open (FD, "$fbasei$sec.bin") or die "$!";
  binmode(FD);
  if ( -f "$fbasei$sec.idx"){
    open A, "tac $fbasei$sec.idx|" or die ($!);
    my $boff = 0;
    while (<A>){
      chop ();
      my ($nn, $of, $len, $hash) = split (/\;/, $_, -1);
      my $h = fromHex ($hash);
      if ($nTot < 0 && $lhash eq $hash){
        print STDERR "found $lhash on line $count $boff\n";
        last;
      }
      if ($nTot > 0 && $count > $nTot+1){
        print STDERR "reached $count at $boff\n";
        last;
      }
      $count ++;
      my $codeC = "";
      #seek (FD, $of, 0);
      $boff -= $len;
      seek (FD, $boff, 2);
      my $rl = read (FD, $codeC, $len);
      $fhos{$sec}{$h} = $codeC;      
    }
  }else{
    die "no $fbasei$sec.idx\n";
  }
  print "$count ${type}s added\n";
  untie %{$fhos{$sec}};
}
