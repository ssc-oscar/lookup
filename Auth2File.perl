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
     ($auth, $ta) = ($1, $2) if ($l =~ m/^author (.*)\s([0-9]+\s[\+\-]+\d+)$/);
     ($cmtr, $tc) = ($1, $2) if ($l =~ m/^author (.*)\s([0-9]+\s[\+\-]+\d+)$/);
  }
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
sub safeComp {
  my ($codeC, $par) = @_;
  try {
    my $code = compress ($codeC);
    return $code;
  } catch Error with {
    my $ex = shift;
    print STDERR "Error: $ex par=$par\n";
    return "";
  }
}

my $fbase="/data/All.sha1c/";
my %a2c;
tie %a2c, "TokyoCabinet::HDB", "$fbase/Auth2Cmt.tch", TokyoCabinet::HDB::OREADER,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $fbase/Auth2Cmt.tch\n";
my %c2f;
tie %c2f, "TokyoCabinet::HDB", "$fbase/Cmt2File.tch", TokyoCabinet::HDB::OREADER,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $fbase/Cmt2File.tch\n";

my %a2f;
while (my ($a, $v) = each %a2c){
  my $ns = length ($v)/20;
  for my $i (0..($ns-1)){
	 my $c = substr ($v, $i*20, 20);
    my @fs = split(/\;/, safeDecomp($c2f{$c}, $a), -1);
    for my $f (@fs){
      $a2f{$a}{$f}++;
    }
  } 
}
untie %a2c;
untie %c2f;


my %a2f1;
tie %a2f1, "TokyoCabinet::HDB", "$ARGV[0]", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $ARGV[0]\n";
while (my ($a, $v) = each %a2f){
  my $v1 = safeComp(join ";", sort keys %{$v}, $a);
  $a2f1{$a}=$v1;
}
untie %a2f1;


