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
use Text::Diff qw(diff);
#sub fromHex { 	return pack "H*", $_[0]; } 

#sub toHex { return unpack "H*", $_[0]; } 

my (%fhosc, %fhob);

my $sections = 128;
my $type = "blob";
my $fbasec="All.sha1c/${type}_";
$fbasec="All.sha1o/sha1.${type}_";
for my $sec (0 .. ($sections-1)){
  my $pre = "/fast/";
  tie %{$fhosc{$sec}}, "TokyoCabinet::HDB", "$pre/${fbasec}$sec.tch", TokyoCabinet::HDB::OREADER,  
         16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
              or die "cant open $pre/$fbasec$sec.tch\n";
  open $fhob{$sec}, "/data/All.blobs/blob_$sec.bin" or die "$!";
}


while(<STDIN>){
  chop();
  my ($ch, $f, $bn, $bo) = split (/;/, $_, -1);
  next if length($ch) ne 40; 
  if (defined $badCmt{$ch}){
    print STDERR "nasty test commit $ch: ignoring\n";
    next;
  }   	
	if ($bo =~ /^[0-9a-f]{40}$/ && $bn =~ /^[0-9a-f]{40}$/){
		my ($bos, $bns) = (getBlob($bo), getBlob($bn));
		my $diff = diff (\$bos,   \$bns);
    print "theDiffFor\;$ch;$f\n$diff";
	}
}


sub getBlob {
  my ($blob) = $_[0];
  my $sec = hex (substr($blob, 0, 2)) % $sections;
  my $bB = fromHex ($blob);
  if (! defined $fhosc{$sec}{$bB}){
     print STDERR "no blob $blob in $sec\n";
     return "";
  }
  my ($off, $len) = unpack ("w w", $fhosc{$sec}{$bB});
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
}
