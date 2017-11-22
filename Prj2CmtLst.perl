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


my %p2c;
tie %p2c, "TokyoCabinet::HDB", "/fast1/All.sha1c/project_commit.tch", TokyoCabinet::HDB::OREADER,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open project_commit.tch\n";

while (my ($p, $v) = each %p2c){
  list ($p, $v);
}
untie %p2c;


sub list {
  my ($p, $v) = @_;
  my $ns = length($v)/20;
  my %tmp = ();
  print "$p;$ns";
  #for my $i (0..($ns-1)){
  #  my $c = substr ($v, 20*$i, 20);
  #  print ";".(toHex($c));
  #}
  print "\n";
}


