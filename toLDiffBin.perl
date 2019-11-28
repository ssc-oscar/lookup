#!/usr/bin/perl -I /home/audris/lookup/ -I /home/audris/lib64/perl5 -I /home/audris/share/perl5/
use strict;
use warnings;
use File::Temp qw/ tempfile tempdir /;
use Compress::LZF ();
use Text::Diff qw(diff);
use Digest::SHA qw (sha1_hex sha1);
use TokyoCabinet;

sub fromHex {
  return pack "H*", $_[0];
}

sub toHex {
  return unpack "H*", $_[0];
}

my $sections = 128;
my (%fhob, %fhost, %fhosc);
my $fbasec="All.sha1o/sha1.blob_";
for my $sec (0 .. ($sections-1)){
  my $pre = "/fast/";
  tie %{$fhosc{$sec}}, "TokyoCabinet::HDB", "$pre/${fbasec}$sec.tch", TokyoCabinet::HDB::OREADER,  
   16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
   or die "cant open $pre/$fbasec$sec.tch\n";
  open $fhob{$sec}, "/data/All.blobs/blob_$sec.bin" or die "$!";
}

open BIN, "$ARGV[0]";
open BOUT, ">$ARGV[1].bin";
open IOUT, ">$ARGV[1].idx";
binmode (BIN);
binmode (BOUT);


my $off = 0;
while (<STDIN>){
  chop();
  my ($o, $l, $ll, $d, $c) = split (/;/, $_, -1);
  seek (BIN, $o, 0);
  my $buff;
  my $x = read (BIN, $buff, $l);
  $buff = safeDecomp ($buff);
  my $res = "";
  while ($buff =~ s/^(.+?)\0//){
    my $n = $1;
    my $h = "";
    if (length ($buff) >= 20){
      $h = substr($buff, 0, 20);
      $buff = substr ($buff, 20, length($buff) - 20);
    }else{
      print STDERR "$o: no hash at $n\n";
      exit ();
    }
    my $t = substr ($n, 0, 1);
    $n = substr ($n, 1, length($n)-1);
#print STDERR "$c;$t;$n;".(toHex($h)).";".length($buff)."\n";
    my $new = "";
    my $old = "";
    if ($t =~ /[cmr]/){
      $new = toHex ($h);
      if ($t eq "r"){
        $old = $1 if ($buff =~ s/^(.+?)\0//);
      }else{
        if ($t eq "m"){
          if (length($buff) >= 20){
            $old = toHex (substr($buff,0,20));
            $buff = substr($buff,20,length($buff) - 20);
          }else{
            print STDERR "1:$n;$o;$c;".(length($buff))."\n";
            exit ();
	      }
        }  
      }
    }
	if ($t =~ /m/){
	  my $bos = getBlob($old);
	  my $bns = getBlob($new);
	  next if $bos eq "" || $bns eq ""; #in case we have no blob or if it is empty
      my ($fho, $fo) = tempfile ( "tmpfileXXXXX", DIR => ".");
      my ($fhn, $fn) = tempfile ( "tmpfileXXXXX", DIR => ".");
	  print $fho $bos;
	  print $fhn $bns;
	  open A, "diff $fo $fn|";
	  my $diff = "";
      while(<A>){
        $diff .= $_;
	  }
	  unlink $fn;
	  unlink $fo;
      # This may be super slow on some cases
      #my $diff = diff (\$bos, \$bns);
      #print "$diff\n";
	  $res .= "$n\0".(fromHex($new)).(fromHex($old))."$diff\0";
	}
  }
  if ($res ne ""){
    my $l = length($res);
    my $h = sha1_hex ("ldiff $l\0$res");  
    my $resC = safeComp ($res);
    my $lc = length($resC);
    print IOUT "$off;$lc;$l;$h;$d;$c\n";
    $off += $lc;
    syswrite BOUT, $resC, $lc;
  }
}

sub safeDecomp {
 my ($codeC, @rest) = @_;
 my $len = length($codeC);
 if ($len >= 2147483647){
   return $codeC;
 }else{
    try {    
     return Compress::LZF::decompress ($codeC);
    } catch Error with {
     my $ex = shift;
     print STDERR "Error: $ex, for parameters @rest\n";
     return "";
    }
  }
}

sub safeComp {
 my ($code, @rest) = @_;
 try {
  my $len = length($code);
  if ($len >= 2147483647){
    print STDERR "Too large to compress: $len\n";
    return $code;
  }else{
    return Compress::LZF::compress ($code);
  }
 } catch Error with {
  my $ex = shift;
  print STDERR "Error: $ex, for parameters @rest\n";
  return "";
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
