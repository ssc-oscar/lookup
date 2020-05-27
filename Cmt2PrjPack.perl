#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl");

use strict;
use warnings;
use Error qw(:try);
use Compress::LZF;
use TokyoCabinet;

sub toHex { 
        return unpack "H*", $_[0]; 
} 

sub fromHex { 
        return pack "H*", $_[0]; 
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


my %c2p;
tie %c2p, "TokyoCabinet::HDB", $ARGV[1], TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $ARGV[1]\n";


my $lines = 0;
procBin ($ARGV[0]);

sub procBin {
  my $fname = $_[0];
  print "processing $fname\n";  
  open A, "<$fname";
  binmode(A); 
  until (eof(A))
  {
    my $buffer;
    my $nread = read (A, $buffer, 20, 0);
    my $c = $buffer;
    $nread = read (A, $buffer, 4, 0);
    my $ns = unpack 'L', $buffer;
    $nread = read (A, $buffer, $ns, 0);
    $c2p{$c} = $buffer;
    $lines ++;
    print STDERR "$lines done\n" if (!($lines%5000000)); 
  }
}  


untie %c2p;






