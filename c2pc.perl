#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
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
if (! defined $ARGV[1]){
	print STDERR "usage: segment version\n";
	exit (-1);
}
my $f0 = $ARGV[0];
my $fname = $ARGV[1];

my (%c2pc);

tie %c2pc, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT | TokyoCabinet::HDB::ONOLCK
     or die "cant open $fname\n";

my (%c2p);
my $sections = 128;
open FD, "$f0";
binmode(FD);
while (<STDIN>){
  chop();
  my ($nn, $of, $len, $hash) = split (/\;/, $_, -1);
  my $h = fromHex ($hash);
  next if defined $c2pc{$h};
  my $sec = (unpack "C", substr ($h, 0, 1)) % 32;
  my $codeC = "";
  seek (FD, $of, 0);
  my $rl = read (FD, $codeC, $len);
  my ($parent) = extrPar ($codeC);
  if ($parent eq ""){
    print "$hash\n"; #no parent
    next;
  }
  my %tmp;
  for my $p (split(/:/, $parent)){
    my $pbin = fromHex ($p);
    $tmp{$pbin}++;
  }
  my $v1 = join '', sort keys %tmp;
  $c2pc{$h} = $v1;
}

untie %c2pc;

