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

my $debug = 0;
my $sections = 128;
my $parts = 2;

my $fbasec="All.sha1o/sha1.blob_";

my (%fhob, %fhost, %fhosc);
for my $sec (0 .. ($sections-1)){
  my $pre = "/fast";
  $pre = "/fast" if $sec % $parts;
  tie %{$fhosc{$sec}}, "TokyoCabinet::HDB", "$pre/${fbasec}$sec.tch", TokyoCabinet::HDB::OREADER,  
	16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $pre/$fbasec$sec.tch\n";
  open $fhob{$sec}, "/data/All.blobs/blob_$sec.bin" or die "$!"
}

sub safeDecomp {
        my ($codeC, $n) = @_;
        try {
                my $code = decompress ($codeC);
                return $code;
        } catch Error with {
                my $ex = shift;
                print STDERR "Error: $ex; $n\n";
                return "";
        }
}

while (<STDIN>){
  chop();
  my $cmt = $_;
  getBlob ($cmt);
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
  print "blob;$sec;$rl;$curpos;$off;$len\;$blob\n$code\n";
}

for my $sec (0 .. ($sections-1)){
	untie %{$fhosc{$sec}};
        my $f = $fhob{$sec};
        close $f;
}
