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

my $sections = 128;

my $fbase="/fast1/All.sha1c/commit_";

my (%fhos, %fhoc, %fhoc1);

for my $sec (0..127){
  tie %{$fhos{$sec}}, "TokyoCabinet::HDB", "${fbase}$sec.tch", TokyoCabinet::HDB::OREADER,
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $pre/${fbase}$sec.tch\n";

  while (my ($sha, $v) = each %{$fhos{$sec}}){
    my ($parent) = extrPar ($v);
    next if $parent eq "";
    for my $p (split(/:/, $parent)){
      my $par = fromHex ($p);
      $fhoc{$par}{$sha}++;
    } 
  }
  untie %{$fhos{$sec}};
}

tie %fhoc1, "TokyoCabinet::HDB", "$ARGV[0]", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $ARGV[0]\n";
while (my ($sha, $v) = each %fhoc){
  my $v1 = join '', sort keys %{$v};
  $fhoc1{$k} = $v1;
}
untie %fhoc1;

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

sub extrCmt {
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

