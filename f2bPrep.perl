#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
use strict;
use warnings;
use Error qw(:try);

use Digest::MD5 qw(md5 md5_hex md5_base64);
use TokyoCabinet;
use Compress::LZF;

my $fname="$ARGV[0]";
my (%clones);
my $hdb = TokyoCabinet::HDB->new();

if(!tie(%clones, "TokyoCabinet::HDB", "$fname",
                  TokyoCabinet::HDB::OREADER)){
        print STDERR "tie error for $fname\n";
}


# Need to run on da4 or make sure that All.sha1o/sha1.blob_ and All.blobs/blob_$sec.bin are there
my $sections = 128;
my $parts = 2;
my $fbasec="All.sha1o/sha1.blob_";
my (%fhob, %fhost, %fhosc);
for my $sec (0 .. ($sections-1)){
  my $pre = "/fast1";
  open $fhob{$sec}, "/data/All.blobs/blob_$sec.bin";
  $pre = "/fast1" if $sec % $parts;
  tie %{$fhosc{$sec}}, "TokyoCabinet::HDB", "$pre/${fbasec}$sec.tch", TokyoCabinet::HDB::OREADER,  
	16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $pre/$fbasec$sec.tch\n";
}

sub safeDecomp {
        my $codeC = $_[0];
        try {
                my $code = decompress ($codeC);
                return $code;
        } catch Error with {
                my $ex = shift;
                print STDERR "Error: $ex\n";
                return "";
        }
}

my $offset = 0;
while (<STDIN>){
  chop ();
  my $k = $_;
  my $vs = $clones{$k};
  my $l = length($vs);
  my %list = ();
  for my $i (0..($l/20-1)){
    my $hb = substr($vs, $i*20, 20);
    my $sec = hex(unpack "H*", substr($hb, 0, 1)) % $sections;
    $list{$sec}{$hb}++;
  }
  for my $sec (keys %list){
    for my $hb (keys %{$list{$sec}}){
      print "$sec;".(toHex($hb))."\n";
    }
  }
} 
untie %clones;

sub toHex { 
	return unpack "H*", $_[0]; 
} 
sub fromHex { 
	return pack "H*", $_[0]; 
} 

for my $sec (0 .. ($sections-1)){
	untie %{$fhosc{$sec}};
        my $f = $fhob{$sec};
        close $f;
}


