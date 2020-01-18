#!/usr/bin/perl -I  /home/audris/lookup -I /home/audris/lib64/perl5 -I /home/audris/lib/x86_64-linux-gnu/perl

use strict;
use warnings;
use Error qw(:try);
use Compress::LZF;
use TokyoCabinet;
use cmt;

my (%tmp, %b2a);

my $fname = "$ARGV[0]";
tie %b2a, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
    507377777, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
   or die "cant open $fname\n";

my $lines = 0;
my $phb = "";

while (<STDIN>){
  chop();
  $lines ++;
  my ($hb, $t, $a, $hc) = split (/\;/, $_);
  if ($hb !~ m|^[0-9a-f]{40}$|){
    print STDERR "bad sha:$_\n";
    next;
  }
  if ($phb ne $hb && $phb ne ""){
    output();
    %tmp = ();
  }
  my $ps = "$t;$a;$hc";
  $tmp{$t}{$ps}++;
  $phb = $hb; 
  if (!($lines%100000000)){
    print STDERR "$lines done\n";
  }
}
output();

sub output {
  my @ts = sort { $a+0 <=> $b+0 } (keys %tmp);
  my $t0 = "";
  #get first nonempty time
  while ($t0 eq "" && $#ts >= 0) { $t0 = shift @ts };
  if ($t0 eq ""){
    print STDERR "no time for $phb\n";
  }
  my @ps = sort keys %{$tmp{$t0}};
  if ($#ps > 0){
    print STDERR "several=$#ps first=$t0 for $phb: @ps\n";
  }  
  my $b = fromHex($phb);
  $b2a{$b} = $ps[0];
}

untie %b2a;

print STDERR "read $lines\n";

