#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");

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

sub extrAuth {
  my ($codeC, $par) = @_;
  my $code = safeDecomp ($codeC, $par);

  my ($tree, $parent, $auth, $cmtr, $ta, $tc) = ("","","","","","");
  my ($pre, @rest) = split(/\n\n/, $code, -1);
  for my $l (split(/\n/, $pre, -1)){
     ($auth) = ($1) if ($l =~ m/^author (.*)$/);
  }
  ($auth, $ta) = ($1, $2) if ($auth =~ m/^(.*)\s(-?[0-9]+\s+[\+\-]*\d+)$/);
  return ($auth);
}

sub safeDecomp {
  my ($codeC, $par) = @_;
  try {
    my $code = decompress ($codeC);
    return $code;
  } catch Error with {
    my $ex = shift;
    print STDERR "Error: $ex par=$par\n";
    return "";
  }
}

my %fhoa;
my $sections = 128;
my %map;
my $fbase="/data/All.blobs/commit_";
for my $s (0..127){
  print STDERR "reading $s\n";
  open A, "$fbase$s.idx";
  open FD, "$fbase$s.bin";
  binmode(FD);
  while (<A>){
    chop();
    my ($nn, $of, $len, $hash) = split (/\;/, $_, -1);
    my $h = fromHex ($hash);
    # seek (FD, $of, 0);
    my $codeC = "";
    my $rl = read (FD, $codeC, $len);
    my ($auth) = extrAuth ($codeC, $hash);
    $map{$auth}{$h}++;
  }
}

tie %fhoa, "TokyoCabinet::HDB", "$ARGV[0]", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,
   16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $ARGV[0]\n";
while (my ($a, $v) = each %map){
  my $v1 = join "", sort keys %{$v};
  $fhoa{$a}=$v1;
}
untie %fhoa;


