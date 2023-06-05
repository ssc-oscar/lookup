#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
use strict;
use warnings;

use utf8;
no utf8;
use JSON;

my $counter = 0;
my @docs;

my $s = $ARGV[0];
my $str = "zcat Pkg2stat$s.gz|";
my $c = JSON->new;
open A, $str;
while (<A>){
  chop(); 
  my ($a, $fr, $to, $nc, $na, $np) = split (/;/);
  my ($l, $pkg) = split (/:/, $a, -1);
  my $doc = {
    API => $a,
    NumCommits => $nc,
    NumAuthors => $na, 
    NumProjects => $np,
    Lang => $l
  };
  print "".($c->encode( $doc ))."\n";
}
