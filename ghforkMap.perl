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

open A, "zcat extraForks.gz|";
while (<A>){
  chop();
  s|/|_|g;
  my ($r, $f) = split (/;/);
  $r2cr{$r} = $r;
  $r2cr{$r} = $f if defined $f && $f =~ /_/;
}

print STDERR "forks: read\n";

my %cr2r;
for my $r (keys %r2cr){
  my $cr = $r2cr{$r};
  next if $r eq $cr || $cr eq "";
  my $ccr = $cr;
  while (defined $r2cr{$ccr} && $ccr ne $r2cr{$ccr} &&  $r2cr{$ccr} ne ""){
    $r2cr{$ccr} = $ccr;
  }
  $r2cr{$r} = $ccr;
  $cr2r{$ccr}{$r}++;
}

while (my ($k, $v) = each %cr2r){
  my @ps = sort mCmp (keys %$v);
  for my $p (@ps){
    print "$p;$k\n";
  }
}

sub mCmp {
  return -1 if length($a) < length($b);
  if (length($a) == length($b)){
    return $a cmp $b;
  }
  return 1;
}
