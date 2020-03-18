#!/usr/bin/perl -I /home/audris/lib64/perl5 -I /home/audris/lib/x86_64-linux-gnu/perl
#
use strict;
use warnings;
use Error qw(:try);

use TokyoCabinet;

my $fname="$ARGV[0]";
my (%clones);
my $hdb = TokyoCabinet::HDB->new();

if(!tie(%clones, "TokyoCabinet::HDB", "$fname",
                  TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT | TokyoCabinet::HDB::ONOLCK)){
        print STDERR "tie error for $fname\n";
}

my ($lk, $lv);
while (read (STDIN, $lk, 4) == 4){
  $lk = unpack 'l', $lk;
  if (read (STDIN, $lv, 4) == 4){
    $lv = unpack 'l', $lv;
    #print "$lk;$lv\n";
    my ($k, $v);
    read (STDIN, $k, $lk);
    if (read (STDIN, $v, $lv) == $lv){
      #do stuff, e.g., put into tch;
      $clones{$k} = $v;
    }
  }
}
untie %clones;
