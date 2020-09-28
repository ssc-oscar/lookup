#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");

use strict;
use warnings;
use Error qw(:try);
use woc;
use TokyoCabinet;

my $debug = 0;
my $sections = 128;
my $parts = 2;

my $type = $ARGV[0];

my $fbase="All.sha1/sha1.${type}_";
my $fbasei ="/data/All.blobs/${type}_";

my (%size, %cnt, %fhob, %fhoi, %fhov, %fhos);
for my $sec (0 .. ($sections-1)){
  my $off = 0;
  my $n = 0;
  if ( -f "$fbasei$sec.idx"){
    open A, "tail -1 $fbasei$sec.idx|" or die ($!);
    my $str = <A>;
    close A;
    if (defined $str){
      chop ($str);
      my ($nn, $of, $len, @rest) = split (/\;/, $str, -1);
      if (defined $len){
        $off = $of + $len;
        $n = $nn + 1;
      }else{
        die "bad format in $fbasei$sec.idx\n";
      }
    }else{
      die "empty $fbasei$sec.idx\n";
    }
  }else{
    $off = 0;
    $n = 0;
  }

  $size{$sec} = $off;
  $cnt{$sec} = $n;
	
  my $pre = "/fast";
  #$pre = "/fast" if $type eq "tag" || $type eq "commit";
  #$pre = "/fast" if $sec % $parts;
  tie %{$fhos{$sec}}, "TokyoCabinet::HDB", "$pre/${fbase}$sec.tch", TokyoCabinet::HDB::OWRITER | 
     TokyoCabinet::HDB::OCREAT, 16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
        or die "cant open $pre/$fbase$sec.tch\n";
  open $fhoi{$sec}, ">>$fbasei$sec.idx" or die ($!);
  open $fhob{$sec}, ">>$fbasei$sec.bin" or die ($!);
  open $fhov{$sec}, ">>$fbasei$sec.vs" or die ($!);
}


open BIGI, ">BigChunks.$type.idx"; 
open BIGB, ">BigChunks.$type.bin"; 
my $BOFF = 0;

sub isGarbage {
	my ($t, $p) = @_;
   if ($t eq "tree" || $t eq "blob"){
     return 1 if defined $largeTreePrj{$p} && $largeTreePrj{$p} > 31333583176;
   }
   if ($t eq "blob"){
     return 1 if defined $largeBlobPrj{$p} && $largeBlobPrj{$p} > 31333583176;
   }
   return 0;
}

while (<STDIN>){
  chop();
  $_ =~ s/\.bin$//;
  my $readFileBase = $_;
  my %id2n = ();	
  open IDXR, "$readFileBase.idx" or die ($!);
  my $base = $readFileBase;
  $base =~ s|^.*/||;
  #$base =~ s|\..*$||;
  $base =~ s|\.[^\.]*$||;$base =~ s|\.[^\.]*$||;#for, e.g., sources.git.github.com.2.18.blob.bin
  open my $fh, '<', "$readFileBase.bin" or die ($!);
  while(<IDXR>){
    chop();
    my ($offset, $siz, $sec, $hsha1Full, @p) = split(/\;/, $_, -1);
    next if (!defined $offset);
    next if isGarbage ($type, $p[0]);
    my $path = join ';', @p;
    my $codeC = "";
    seek ($fh, $offset, 0);
    my $rl = read($fh, $codeC, $siz);
    if ($siz == 0){
      print STDERR "zero length for: $offset\;$siz;@p\;$readFileBase\n";
      next;
    }
    if ($siz >= 2147483647){
      print BIGI "$BOFF;$siz;$readFileBase;$offset;$sec;$hsha1Full;$path\n";
      print BIGB $codeC;
      my $BOFF += $siz;
      print STDERR "uncompressable object: too large: $siz\n";
      next;
    }

    if ($type eq "blob" && $p[0] =~ /^cryptobigbro_/){
      # Ignore massive csv files of traiding data
      print BIGI "$BOFF;$siz;$readFileBase;$offset;$sec;$hsha1Full;$path\n";
      print BIGB $codeC;
      my $BOFF += $siz;
      print STDERR "ignoring cryptobigbro\n";
      next;
    }

    my $sha1Full = fromHex ($hsha1Full);
    my $id = $size{$sec};
    my $n = $cnt{$sec};
    my $fb = $fhob{$sec};
    my $fi = $fhoi{$sec};
    my $fv = $fhov{$sec};

    if (defined $fhos{$sec}{$sha1Full}){
      my $nn = unpack "w", $fhos{$sec}{$sha1Full};
      print $fv "$nn:$sec;$siz;$sec;$hsha1Full;$base;$path\n";		
    }else{
      $fhos{$sec}{$sha1Full} = pack "w", $n;
      print $fv "$n:$sec;$siz;$sec;$hsha1Full;$base;$path\n";
      print $fi "$n;$id;$siz;$hsha1Full\n";
      print $fb "$codeC";			
      $size{$sec} += $siz;
      $cnt{$sec} ++;
    }	
  }
}

for my $sec (0 .. ($sections-1)){
  untie %{$fhos{$sec}};
}
close BIGB;
close BIGI;

