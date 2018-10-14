#!/usr/bin/perl -I /home/audris/lib64/perl5 -I /da3_data/lookup
use strict;
use warnings;
use Error qw(:try);

use TokyoCabinet;
use Compress::LZF;
use cmt;

sub extrPar {
  my $codeC = $_[0];
  my $code = safeDecomp ($codeC);

  my $parent = "";
  my ($pre, @rest) = split(/\n\n/, $code, -1);
  for my $l (split(/\n/, $pre, -1)){
     $parent .= ":$1" if ($l =~ m/^parent (.*)$/);
  }
  $parent =~ s/^:// if defined $parent;
  return $parent;
}

my $part = 0;
$part = $ARGV[0] if defined $ARGV[0];

my %c2cc;
for my $s (0..31){
  tie %{$c2cc{$s}}, "TokyoCabinet::HDB", "c2cc.$s.tch", TokyoCabinet::HDB::OREADER,
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open c2cc.$s.tch\n";
}
tie %c2pc, "TokyoCabinet::HDB", "c2pc.$part.tch", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open c2pc.$part.tch\n";

my (%c2p);
my $sections = 128;
my $fbase="/data/All.blobs/commit_";
for my $s ($part){
 print STDERR "reading $s\n";
 open A, "$fbase$s.idx";
 open FD, "$fbase$s.bin";
 binmode(FD);
 while (<A>){
  chop();
  my ($nn, $of, $len, $hash) = split (/\;/, $_, -1);
  my $h = fromHex ($hash);
  my $sec = (unpack "C", substr ($h, 0, 1)) % 32;
  if (!defined $c2cc{$sec}{$h}){
    print "$hash\n"; #no child
  } 
  # seek (FD, $of, 0);
  my $codeC = "";
  my $rl = read (FD, $codeC, $len);

  my ($parent) = extrPar ($codeC);
  if ($parent eq ""){
    print "$hash\n"; #no parent
    next;
  }
  for my $p (split(/:/, $parent)){
    my $pbin = fromHex ($p);
    $c2p{$pbin}++;
  }
}


while (my ($c, $v) = each %c2p){
  my $v1 = join '', sort keys %{$v};
  $c2pc{$c} = $v1;
}
untie %c2pc;

