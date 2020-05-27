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

my %p2c;
tie %p2c, "TokyoCabinet::HDB", $ARGV[1], TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
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
    my $nread = read (A, $buffer, 2, 0);
    my $lk = unpack 'S', $buffer;
    $nread = read (A, $buffer, $lk, 0); 
    my $prj = $buffer;
    $nread = read (A, $buffer, 4, 0);
    my $ns = unpack 'L', $buffer;
    $nread = read (A, $buffer, 20*$ns, 0);
    $p2c{$prj} = $buffer;
    $lines ++;
    print STDERR "$lines done\n" if (!($lines%5000000)); 
  }
}  

untie %p2c;






