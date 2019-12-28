use strict;
use warnings;

my %r2cr;
open A, "zcat projectstr2.gz|";
while (<A>){
  chop();
  my ($r, $cd, $ud, $f, $del, $stars) = split (/;/);
  $r2cr{$r} = $r;
  $r2cr{$r} = $f if $f =~ /_/;  
}

my @res;
my %d;
while(<STDIN>){
  my ($c, @x) = split(/;/);
  my %tmp; 
  for my $p (@x) {
	 if (defined  $r2cr{$p}){
      $tmp{$r2cr{$p}}++;
	 }else{ $tmp{$p} ++ }
  }
  my $s = join ";", (sort keys %tmp); 
  push @res, $s if !defined $d{$s}; 
  $d{$s}++;
}
for my $s (@res){print "$d{$s};$s"}