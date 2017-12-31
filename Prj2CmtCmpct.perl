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

my %p2c2;
tie %p2c2, "TokyoCabinet::HDB", "$ARGV[0]", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $ARGV[0]\n";

while (my ($p, $v) = each %p2c){
  list ($p, $v);
}
untie %p2c;
untie %p2c2;


sub list {
  my ($p, $v) = @_;
  my $p0 = $p;
  my $ns = length($v)/20;
  my %tmp = ();
  $p =~ s/.*github.com_(.*_.*)/$1/;
  $p =~ s/^bitbucket.org_/bb_/;
  $p =~ s/\.git$//;
  $p =~ s|/*$||;
  $p =~ s/\;/SEMICOLON/g;
  $p = "EMPTY" if $p eq "";
  if ($p0 ne $p){
    if (defined $p2c{$p}){
      my %tmp = ();
      my $v1 = $p2c{$p};    
      for my $i (0..($ns-1)){
        my $c = substr ($v, 20*$i, 20);
        $tmp{$c}++;
      }
      for my $i (0..(length($v1)/20-1)){
        my $c = substr ($v1, 20*$i, 20);
        $tmp{$c}++;
      }
      $v = join '', keys %tmp;
    }
  }
  $p2c2{$p} = $v;
}

