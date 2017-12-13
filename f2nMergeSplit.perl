#!/usr/bin/perl -I/home/audris/lib64/perl5

use strict;
use warnings;
use Compress::LZF;
use TokyoCabinet;
use Time::Local;



my $outN = $ARGV[0];


my %out;
my $sec;
my %in;
my %res;
my $lines = 0;

my $nParts = 16;
$nParts = $ARGV[1]+0 if defined $ARGV[1];

for $sec (0..($nParts-1)){
  tie %{$out{$sec}}, "TokyoCabinet::HDB", "$outN.$sec.tch", TokyoCabinet::HDB::OWRITER |  TokyoCabinet::HDB::OCREAT,
    16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
    or die "cant open $outN.$sec.tch\n";
}


sub get {
  my ($k, $v, $res) = @_;
  my @vs = split (/\;/, safeDecomp($v), -1);
  for my $n (@vs){
    $n =~ s/;/SEMICOLON/g;
    $res->{$n}++;
  }
}


my $j  = 0;
while (<STDIN>){
  chop();
  my $fname = $_;
  print STDERR "processing $fname\n";
  tie %in, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER,
     16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $fname\n";
  while (my ($k, $v) = each %in){
    print STDERR "$lines done\n" if (!(($lines++)%100000000));
    get ($k, $v, \%{$res{$k}});
  }
  untie %in;
}

print STDERR "writing $lines\n";
$lines = 0;
while (my ($k, $v) = each %res){
  $lines++;
  my $s = (unpack "C", substr ($k, 0, 1))%$nParts;
  $out{$s}{$k} = safeComp(join ";", sort keys %{$v});  
}
print STDERR "done $lines\n";

for $sec (0..($nParts-1)){
  untie %{$out{$sec}};
}


sub safeComp {
  my $code = $_[0];
  try {
    my $codeC = compress ($code);
    return $codeC;
  } catch Error with {
    my $ex = shift;
    print STDERR "Error: $ex\n$code\n";
    return "";
  }
}

sub safeDecomp {
  my $code = $_[0];
  try {
    my $codeC = decompress ($code);
    return $codeC;
  } catch Error with {
    my $ex = shift;
    print STDERR "Error: $ex\n$code\n";
    return "";
  }
}
