#!/usr/bin/perl -I /home/audris/lib64/perl5 -I /da3_data/lookup
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
  # three types of match
  my %matches = ();
  #my $flag = 0;
  #install\.packages\(.*"data.table".*\);
  #library\(.*[\"']*?data\.table[\"']*?.*\);
  #require\(.*[\"']*?data\.table[\"']*?.*\);
  # only consider the case where one package is installed at a time
  # one case c(a,b,d) ... 
  # another case, multiple packages in one statement
  while ($code =~ /install\.packages\(.*?"([^\"',\)]+)".*?\)/g) {
        $matches{$1} = 1;
        #print $1."\n";
        #$flag = 1;
  }
  while ($code =~ /library\([\"']*?([^\"',\)]+)[\"']*?.*?\)/g) {
        #print $1;
        $matches{$1} = 1;
  }
  while ($code =~ /require\([\"']*?([^\"',\)]+)[\"']*?.*?\)/g) {
        $matches{$1} = 1;
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





