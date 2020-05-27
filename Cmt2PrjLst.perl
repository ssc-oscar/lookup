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


my $detail = 0;
$detail = $ARGV[1] if defined $ARGV[1];

my %p2c;
tie %p2c, "TokyoCabinet::HDB", "$ARGV[0]", TokyoCabinet::HDB::OREADER | TokyoCabinet::HDB::ONOLCK,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $ARGV[0]\n";

while (my ($p, $v) = each %p2c){
  list ($p, $v);
}
untie %p2c;


sub list {
  my ($c, $v) = @_;
  my $c1 = toHex($c);
  my $v1 = safeDecomp ($v);
  my @ps = split(/\;/, $v1, -1);
  
  print "$c1;".($#ps+1);

  if ($detail){
    print ";$v1";
  }
  print "\n";
}


