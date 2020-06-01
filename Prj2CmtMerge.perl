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

my %p2c;
tie %p2c, "TokyoCabinet::HDB", "$ARGV[0]", TokyoCabinet::HDB::OREADER,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $ARGV[0]\n";


open B, '>:raw', "$ARGV[2]";
open A, "<$ARGV[1]";
binmode(A); 


my $lines = 0;
my %touched;
procBin ($ARGV[1]);
while (my ($k, $v) = each %p2c){
  if (!defined ($touched{$k})){
    out ($k, $v);
  }
}
sub procBin {
  print "processing $ARGV[1]\n";  
  until (eof(A))
  {
    my $buffer;
    my $nread = read (A, $buffer, 2, 0);
    my $lk = unpack 'S', $buffer;
    my $prj = "EMPTY";
    if ($lk > 0){
      $nread = read (A, $buffer, $lk, 0); 
      $prj = $buffer;
      $prj =~ s/\.git$//;
    }
    $lk = length($prj);

    $nread = read (A, $buffer, 4, 0);
    my $ns = unpack 'L', $buffer;
    my $found = 0;
    if (defined $p2c{$prj}){
      $touched{$prj}++;
      #if (defined $p2c{"$prj.git"}){
      #  $touched{"$prj.git"}++;
      #  collect ($prj, merge ($p2c{$prj}, $p2c{"$prj.git"}), $ns);
      #}else{
        collect ($prj, $p2c{$prj}, $ns);
      #}
    }else{
      #if (defined $p2c{"$prj.git"}){
      #  collect ($prj, $p2c{"$prj.git"}, $ns);
      #}else{
        $nread = read (A, $buffer, 20*$ns, 0);
        out ($prj, $buffer);
      #}
    }
    $lines ++;
    print STDERR "$lines done\n" if (!($lines%5000000)); 
  }
}


sub merge {
  my ($v0, $v1) = @_;
  my $ns0 = length($v0)/20;
  my $ns1 = length($v1)/20;
  my %sa = ();
  for my $i (0..($ns0-1)){
    $sa{(substr ($v0, 20*$i, 20))}++;
  }
  for my $i (0..($ns1-1)){
    $sa{(substr ($v1, 20*$i, 20))}++;
  }
  return join '', (sort keys %sa);
}


sub collect {
  my ($prj, $v0, $ns) = @_;
  
  my $l0 = length($v0)/20;
  my %sa = ();
  for my $i (0..($l0-1)){
    $sa{substr ($v0, 20*$i, 20)}++;    
  }
  for my $i (0..($ns-1)){
    my $buffer;
    my $nread = read (A, $buffer, 20, 0);
    $sa{$buffer}++ if ( !defined ($sa{$buffer}));
  }
  out ($prj, (join "", sort keys %sa));
}

untie %p2c;

sub out {
  my ($k, $v) = @_;
 
  my $l = length($v)/20;
  my $nsha = pack "L", $l;
  my $lp = pack "S", length($k);
  print B $lp;
  print B $k;
  print B $nsha;
  print B $v;
}






