#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
use strict;
use warnings;
use Error qw(:try);
use cmt;

use Digest::MD5 qw(md5 md5_hex md5_base64);
use TokyoCabinet;
use Compress::LZF;

#my $fname="$ARGV[0]";
my (%clones);
my $hdb = TokyoCabinet::HDB->new();

my $sec = $ARGV[0];
my (%fhob, %fhosc);
open $fhob{$sec}, "/data/All.blobs/blob_$sec.bin";
tie %{$fhosc{$sec}}, "TokyoCabinet::HDB", "/fast/All.sha1o/sha1.blob_$sec.tch", TokyoCabinet::HDB::OREADER,  
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open /fast/All.sha1o/sha1.blob_$sec.tch\n";

my $offset = 0;
while (<STDIN>){
  chop ();
  next if defined $badBlob{$_};
  my $b2 = fromHex($_);
  my $codeC = getBlob ($b2);
  my $hh = $b2;
  $hh = unpack 'H*', $b2 if length($b2) == 20;
  my $code = $codeC;
  $code = safeDecomp ($codeC, "$offset;$hh");
  $code =~ s/\r//g;
  # two types of match
  my %matches = ();
  $code =~ s|//[^\n]*\n|\n|g;
  $code =~ s|;\n|;|g;
  $code =~ s|\n| |g;
  for my $l (split(/;/, $code, -1)){
#$l =~ s/\s*$//;
#   $l =~ s/^\s*//;
#    for my $l (split(/;/, $lm, -1)){
      if ($l =~ m/^import\s+(.*)$/) {
        my $m = $1;
        if (defined $m){
          if ($m =~ s/\s+as\s+(.*)//){
            my $mm = $1;
            $mm =~ s/['"]//g; 
            $m =~ s/['"]//g; 
            if ($mm =~ s/\s+show\s+(.*)//){
              $mm = $1;
              $mm =~ s/\s+hide\s+.*//;
              for my $s (split(/,/, $1, -1)){
                $s =~ s/^\s*//; $s =~ s/\s*$//;
                $matches{"$m.$s"}++;
              }
            }else{
              $m =~ s/\s+hide\s+.*//;
              $m =~ s/['"]//g;
              $m =~ s/\s+(show|deferred)$//;
              $m =~ s/^\s*//; $m =~ s/\s*$//;
              $matches{"$m"}++;
            }
          }else{
            $m =~ s/['"]//g;
            if ($m =~ s/\s+show\s+(.*)//){
              for my $s (split(/,/, $1, -1)){
                $s =~ s/^\s*//; $s =~ s/\s*$//;
                $matches{"$m.$s"}++;
              }
            }else{
              $m =~ s/\s+hide\s+.*//;
              $m =~ s/\s+(show|deferred)$//;
              $m =~ s/^\s*//; $m =~ s/\s*$//;
              $matches{"$m"}++;
            }
          }  
        }
#     }
    }
  }  
  if (%matches){
    print $_;
    for my $elem (keys %matches) {
      print ';'.$elem;
    }
    print "\n";
  }
  $offset++;
}

untie %clones;

untie %{$fhosc{$sec}};
my $f = $fhob{$sec};
close $f;


sub getBlob {
  my ($bB) = $_[0];
  if (! defined $fhosc{$sec}{$bB}){
     print STDERR "no blob ".(toHex($bB))." in $sec\n";
     return "";
  }
  my ($off, $len) = unpack ("w w", $fhosc{$sec}{$bB});
  my $f = $fhob{$sec};
  seek ($f, $off, 0);
  my $codeC = "";
  my $rl = read ($f, $codeC, $len);
  return ($codeC);
}





