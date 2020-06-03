#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
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
sub safeComp {
  my ($codeC, $n) = @_;
  try {
    my $code = compress ($codeC);
    return $code;
  } catch Error with {
    my $ex = shift;
    print STDERR "Error: $ex; $n\n";
    return "";
  }
}



my %p2c;
tie %p2c, "TokyoCabinet::HDB", "$ARGV[0]", TokyoCabinet::HDB::OREADER,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $ARGV[0]\n";
my %p2c1;
tie %p2c1, "TokyoCabinet::HDB", "$ARGV[1]", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $ARGV[1]\n";

while (my ($p, $v) = each %p2c){
  list ($p, $v);
}
untie %p2c;
untie %p2c1;


sub list {
  my ($c, $v) = @_;
  my $v1 = safeDecomp ($v);
  my @ps = split(/\;/, $v1, -1);
  my %tmp; 
  for my $p (@ps){
    $p =~ s/.*github.com_(.*_.*)/$1/;
    $p =~ s/^bitbucket.org_/bb_/;
    $p =~ s/\.git$//;
    $p =~ s|/*$||;
    $p =~ s/\;/SEMICOLON/g;
    $p = "EMPTY" if $p eq "";
    $tmp{$p}++;
  }
  $v1 = safeComp (join ';', keys %tmp);
  $p2c1{$c} = $v1;
}


