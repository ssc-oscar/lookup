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

sub extrCmt {
  my ($codeC, $par) = @_;
  my $code = safeDecomp ($codeC, $par);

  my ($tree, $parent, $auth, $cmtr, $ta, $tc) = ("","","","","","");
  my ($pre, @rest) = split(/\n\n/, $code, -1);
  for my $l (split(/\n/, $pre, -1)){
     #print "$l\n";
     $tree = $1 if ($l =~ m/^tree (.*)$/);
     $parent .= ":$1" if ($l =~ m/^parent (.*)$/);
     #($auth, $ta) = ($1, $2) if ($l =~ m/^author (.*)\s([0-9]+\s[\+\-]*\d+)$/);
     #($cmtr, $tc) = ($1, $2) if ($l =~ m/^committer (.*)\s([0-9]+\s[\+\-]*\d+)$/);
     ($auth) = ($1) if ($l =~ m/^author (.*)$/);
     ($cmtr) = ($1) if ($l =~ m/^committer (.*)$/);
  }
  ($auth, $ta) = ($1, $2) if ($auth =~ m/^(.*)\s(-?[0-9]+\s+[\+\-]*\d+)$/);
  ($cmtr, $tc) = ($1, $2) if ($cmtr =~ m/^(.*)\s(-?[0-9]+\s+[\+\-]*\d+)$/);
  $parent =~ s/^:// if defined $parent;
  return ($tree, $parent, $auth, $cmtr, $ta, $tc, @rest);
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
    my ($tree, $parent, $auth, $cmtr, $ta, $tc, @rest) = extrCmt ($codeC, $hash);
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


