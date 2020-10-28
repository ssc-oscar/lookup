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
my $ver = $ARGV[1];
my $sections = 32;

my (%c2cc);

for my $i (0..($sections-1)){
  tie %{$c2cc{$i}}, "TokyoCabinet::HDB", "/fast/c2ccFull$ver.$i.tch", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT 
     or die "cant open /fast/c2ccFull$ver.$i.tch\n";
}

my %tmp;
open FD, "$f0";
binmode(FD);
while (<STDIN>){
  chop();
  my ($nn, $of, $len, $hash) = split (/\;/, $_, -1);
  my $h = fromHex ($hash);
  my $sec = (unpack "C", substr ($h, 0, 1)) % $sections;
  my $codeC = "";
  seek (FD, $of, 0);
  my $rl = read (FD, $codeC, $len);
  my ($parent) = extrPar ($codeC);
  if ($parent eq ""){
    print "$hash\n"; #no parent
    next;
  }
  for my $p (split(/:/, $parent)){
    next if $p !~ /^[0-9a-f]{40}$/;
    my $pbin = fromHex ($p);
    my $sec = (unpack "C", substr ($pbin, 0, 1)) % $sections;
    if (defined $c2cc{$sec}{$pbin}){
      my $v = $c2cc{$sec}{$pbin};
      for my $i (0..(length($v)/20)){
        my $cbin = substr ($v, $i*20, 20);
        $tmp{$sec}{$pbin}{$cbin}++;
      }
    }
    $tmp{$sec}{$pbin}{$h} ++;
  }
}

for my $sec (keys %tmp){
  for my $p (keys %{$tmp{$sec}}){
    my $v = join '', sort keys %{$tmp{$sec}{$p}};
    $c2cc{$sec}{$p} = $v;
  }
}

for my $i (0..($sections-1)){
  untie %{$c2cc{$i}};
}

