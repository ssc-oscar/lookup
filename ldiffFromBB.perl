#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
############
############ See accurate diff ib cmputeDiff.perl
############ this is 40X faster but may miss renamed files under renamrd subflders
############ treating some as adds: see commit 0010db3b9a569500a8974bb680acaad12e72a72b
############ Not clear what git diff does here
############
use strict;
use warnings;
use Compress::LZF;
use Digest::SHA qw (sha1_hex sha1);
use Time::Local;
use cmt;

#########################
# create code to versions database
#########################
use TokyoCabinet;
#use Text::Diff qw(diff);
#use Algorithm::Diff qw(compact_diff);

my (%fhosc, %fhoscB, %fhob);
my $outbase = "/data/All.blobs/".$ARGV[0];
my $sections = 128;
my $type = "blob";
my $fbasecB="All.sha1o/sha1.blob_";
for my $sec (0 .. ($sections-1)){
  my $h = ($sec % 8) + 1; 
  my $pre = "/woc${h}_fast/";
  tie %{$fhoscB{$sec}}, "TokyoCabinet::HDB", "$pre/${fbasecB}$sec.tch", TokyoCabinet::HDB::OREADER,  
         16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
              or die "cant open $pre/$fbasecB$sec.tch\n";
  open $fhob{$sec}, "/woc${h}_data/All.blobs/blob_$sec.bin" or die "cant open /woc${h}_data/All.blobs/blob_$sec.bin\n";
  
}

open OUTB, ">$outbase.bin";
open OUTI, ">$outbase.idx";
my $off = 0;
my $n = 0;
while(<STDIN>){
  chop();
  my ($nb, $ob) = split (/;/, $_, -1);
  if ($nb eq "" || !defined $ob || $ob eq "" || $nb !~ /^[0-9a-f]{40}$/ || $ob !~ /^[0-9a-f]{40}$/){
    next;
  }
  my $bot = getBlob($ob);
  my $bnt = getBlob($nb);
  next if $bot eq "" || $bnt eq "";
  open BO, ">$ob";
  open BN, ">$nb";
  print BO $bot;
  print BN $bnt;
  if (length ($bot) > 10000 || length ($bnt) > 10000){
    open A, '$HOME/bin/myTimeout 500s diff --speed-large-files '."$ob $nb|";
  }else{
    open A, '$HOME/bin/myTimeout 100s diff '."$ob $nb|";
  }
  my $diff = "";
  while(<A>){
    if (/^TIMEOUT_TIMEOUT_TIMEOUT/){
      $diff = "";
      last;
    }
    $diff .= $_;
  }
  unlink $ob;
  unlink $nb;

  #my $diff = diff (\$bot,   \$bnt);
  my $l = length($diff);
  next if $l == 0;

  my $diffc = safeComp ($diff);
  my $lc = length($diffc);

  my $hash = sha1_hex ("ldiff $l\0$diff");
  print OUTI "$n;$off;$lc;$nb;$ob;$hash\n";
  print OUTB $diffc;
  $n++;
  $off += $lc;
}


sub getBlob {
  my ($blob) = $_[0];
  my $sec = hex (substr($blob, 0, 2)) % $sections;
  my $bB = fromHex ($blob);
  if (! defined $fhoscB{$sec}{$bB}){
	  #print STDERR "no blob $blob in $sec\n";
     return "";
  }
  my ($off, $len) = unpack ("w w", $fhoscB{$sec}{$bB});
  my $f = $fhob{$sec};
  seek ($f, $off, 0);
  my $curpos = tell($f);
  my $codeC = "";
  my $rl = read ($f, $codeC, $len);
  my $code = safeDecomp ($codeC, "$sec;$curpos;$blob");
  return $code;
}


for my $sec (0 .. ($sections-1)){
  untie %{$fhosc{$sec}};
  untie %{$fhoscB{$sec}};
}


