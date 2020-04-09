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
my $type = "blob";
my $fbasec="All.sha1c/bdiff_";
my $fbasecB="All.sha1o/sha1.blob_";
for my $sec (0 .. ($sections-1)){
  my $h = ($sec % 8) + 1; 
  my $pre = "/woc${h}_fast/";
  tie %{$fhoscB{$sec}}, "TokyoCabinet::HDB", "$pre/${fbasecB}$sec.tch", TokyoCabinet::HDB::OREADER,  
         16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
              or die "cant open $pre/$fbasecB$sec.tch\n";
  open $fhob{$sec}, "/woc${h}_data/All.blobs/blob_$sec.bin" or die "cant open /woc${h}_data/All.blobs/blob_$sec.bin\n";
}

my $pch = "";
my $res = "";
while(<STDIN>){
  chop();
  my ($ch, $f, $nb, $ob) = split (/;/, $_, -1);
  if ($ch !~ /^[0-9a-f]{40}$/ || $nb !~ /^[0-9a-f]{40}$/ || $ob !~ /^[0-9a-f]{40}$/){
	if (defined $badCmt{$ch}){
		print STDERR "nasty test commit $ch: ignoring\n";
	}
	$pch = $ch;
	next;
  }
  if ($pch ne $ch && $pch ne ""){
    output ($pch, $res);
	$res = "";
  }
  $res .= "$f;$nb;$ob\n";
  $pch = $ch;
}
output ($pch, $res);

sub output {
  my ($ch, $el) = @_;
  $el =~ s/\n$//;
  my @res = split(/\n/, $el, -1);
  print "theDiffFor\;$ch;$#res\n";
  for my $el (@res){
    my ($f, $bn, $bo) = split (/;/, $el, -1);
    if ($bo =~ /^[0-9a-f]{40}$/ && $bn =~ /^[0-9a-f]{40}$/){
	  my $bot = getBlob($bo);
	  my $bnt = getBlob($bn);
	  next if $bot eq "" || $bnt eq "";
	  #my @bos = split (/\n/, $bot, -1);
	  #my @bns = split (/\n/, $bnt, -1);
	  #my @diff = compact_diff (\@bos,   \@bns);
	  my $diff = diff (\$bot,   \$bnt);
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

