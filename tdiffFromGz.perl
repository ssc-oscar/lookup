#!/usr/bin/perl -I /home/audris/share/perl5/ -I /da3_data/lookup -I /home/audris/lib64/perl5
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
use Text::Diff qw(diff);
use Algorithm::Diff qw(compact_diff);
#sub fromHex { 	return pack "H*", $_[0]; } 

#sub toHex { return unpack "H*", $_[0]; } 

my (%fhosc, %fhoscB, %fhob);

my $sections = 128;
my $type = "tkns";
my $outbase = "/data/All.blobs/tdiff_".$ARGV[0];
my $fbasecB="All.sha1c/tkns_";
for my $sec (0 .. ($sections-1)){
  my $h = ($sec % 8) + 1; 
  #my $pre = "/woc${h}_fast/";
  my $pre = "/fast/";
  tie %{$fhoscB{$sec}}, "TokyoCabinet::HDB", "$pre/${fbasecB}$sec.tch", TokyoCabinet::HDB::OREADER,  
         16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
              or die "cant open $pre/$fbasecB$sec.tch\n";
}

my $pch = "";
open OUTB, ">$outbase.bin";
open OUTI, ">$outbase.idx";
my $off = 0;
my $n = 0;
while(<STDIN>){
  chop();
  my ($ob, $nb) = split (/;/, $_, -1);
  if ($nb =~ /^[0-9a-f]{40}$/ && $ob =~ /^[0-9a-f]{40}$/){
    next if $pch eq "$ob;$nb" || $ob eq $nb; #in case of repeats or no change
    $pch = "$ob;$nb";
    my $diff = output ($ob, $nb);
    $diff =~ s/\n$//;
    my $l = length ($diff);
    if ($l > 0){
      my $diffc = safeComp ($diff);
      my $lc = length ($diffc);
      my $hash = sha1_hex ("tdiff $l\0$diff");
      print OUTI "$n;$off;$lc;$hash;$nb;$ob\n";
      print OUTB $diffc;
      $off += $lc;
      $n++;
    }else{
      print OUTI "$n;$off;0;;$nb;$ob\n";
      $n++;
    }
  }
}


sub output {
  my ($bo, $bn) = @_;
	my $bot = getTkns ($bo);
	my $bnt = getTkns ($bn);
	next if $bot eq "" || $bnt eq "";
  my $diff;

#no sort
#$diff = diff (\$bot, \$bnt);
#return $diff;

  my %bos; for my $b (split (/\n/, $bot, -1)) { $bos{$b}++; };
  my %bns; for my $b (split (/\n/, $bnt, -1)) { $bns{$b}++; };
  $bot = (join "\n", sort keys %bos)."\n";
  $bnt = (join "\n", sort keys %bns)."\n";
  $diff = diff (\$bot, \$bnt);
  return $diff;
  
  if (0){
    open BO, ">$bo";for my $l (sort (keys %bos)){ print BO "$l\n";}
    open BN, ">$bn";for my $l (sort (keys %bns)){ print BN "$l\n";}
    #open BO, '|$HOME/bin/lsort 10M -u > '."$bo"; print BO $bot;
    #open BN, '|$HOME/bin/lsort 10M -u >'." $bn"; print BN $bnt;
    close BN;
    close BO;

    my $cmd = '$HOME/bin/myTimeout 100s diff '."$bo $bn|";
    open IND, $cmd or die "$_";
    while(<IND>){
      if (/^TIMEOUT_TIMEOUT_TIMEOUT/){
        $diff = "";
        last;
      }
      $diff .= $_;
    }
    unlink $bo;
    unlink $bn;
  }
  return $diff;
}

sub getTkns {
  my ($ch) = $_[0];
  my $sec = hex (substr($ch, 0, 2)) % $sections;
  my $cB = fromHex ($ch);
  if (! defined $fhoscB{$sec}{$cB}){
    print STDERR "no token for $ch in $sec\n";
    return "";
  }
  my $codeC = $fhoscB{$sec}{$cB};
  return (safeDecomp ($codeC, "$sec;$ch"));
}

for my $sec (0 .. ($sections-1)){
  untie %{$fhoscB{$sec}};
}


