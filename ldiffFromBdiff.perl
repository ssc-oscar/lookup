#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
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

my (%fhosc, %fhoscB, %fhob);

my $sections = 128;
my $type = "blob";
my $fbasec="All.sha1c/bdiff_";
my $fbasecB="All.sha1o/sha1.blob_";
for my $sec (0 .. ($sections-1)){
  my $pre = "/fast/";
  tie %{$fhosc{$sec}}, "TokyoCabinet::HDB", "$pre/${fbasec}$sec.tch", TokyoCabinet::HDB::OREADER,  
         16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
              or die "cant open $pre/$fbasec$sec.tch\n";
  tie %{$fhoscB{$sec}}, "TokyoCabinet::HDB", "$pre/${fbasecB}$sec.tch", TokyoCabinet::HDB::OREADER,  
         16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
              or die "cant open $pre/$fbasecB$sec.tch\n";
  open $fhob{$sec}, "/data/All.blobs/blob_$sec.bin" or die "$!";
}


while(<STDIN>){
  chop();
  my ($ch) = split (/;/, $_, -1);
  next if length($ch) ne 40; 
  if (defined $badCmt{$ch}){
    print STDERR "nasty test commit $ch: ignoring\n";
    next;
  }
  my @res = getBdiff ($ch);
  print "theDiffFor\;$ch;$#res\n";
  for my $el (@res){
    my ($f, $bn, $bo) = split (/;/, $el, -1);
    if ($bo =~ /^[0-9a-f]{40}$/ && $bn =~ /^[0-9a-f]{40}$/){
		  my ($bos, $bns) = (getBlob($bo), getBlob($bn));
		  my $diff = diff (\$bos,   \$bns);
      print "$f\n$diff";
    }
	}
}


sub getBlob {
  my ($blob) = $_[0];
  my $sec = hex (substr($blob, 0, 2)) % $sections;
  my $bB = fromHex ($blob);
  if (! defined $fhoscB{$sec}{$bB}){
     print STDERR "no blob $blob in $sec\n";
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

sub getBdiff {
  my ($ch) = $_[0];
  my $sec = hex (substr($ch, 0, 2)) % $sections;
  my $cB = fromHex ($ch);
  if (! defined $fhosc{$sec}{$cB}){
    print STDERR "no bdiff for commit $ch in $sec\n";
    return "";
  }
  my $buff = safeDecomp ($fhosc{$sec}{$cB}, "sec;$ch");
  my @res = ();
  while ($buff =~ s/^(.+?)\0//){
    my $n = $1;
    my $h = ""; 
    if (length($buff)>=20){
      $h = substr($buff, 0, 20);
      $buff = substr($buff, 20, length($buff) - 20);
    } else {
      print STDERR "no hash: $sec;$ch\n";
      exit();
    }
    my $t = substr ($n, 0, 1);
    $n = substr ($n, 1, length($n)-1);
                      #print STDERR "$c;$t;$n;".(toHex($h)).";".length($buff)."\n";
    my $new = "";
    my $old = "";
    if ($t =~ /[crm]/){
      $new = toHex ($h);
      if ($t eq "r"){
        $old = $1 if ($buff =~ s/^(.+?)\0//);
      }else{
        if ($t eq "m"){
          if (length($buff) >= 20){
            $old = toHex (substr($buff,0,20));
            $buff = substr($buff,20,length($buff) - 20);
          }else{
            print STDERR "1:$n;$ch;".(length($buff))."\n";
            exit ();
          }
        }
      }
    }else{
      $old = toHex ($h);
    }
    #print STDERR "$n;$new;$old\n";
    push @res, "$n;$new;$old";
  }
  return @res;
}

