use strict;
use warnings;
my %r2cr;
my $nr = 0;
open A, "zcat projectstr2.gz|";
while (<A>){
  chop();
  my ($r, $cd, $ud, $f, $del, $stars) = split (/;/);
  $r2cr{$r} = $r;
  $r2cr{$r} = $f if $f =~ /_/;
  $nr ++;
}
print STDERR "read projectstr2.gz $nr\n";
open A, "zcat extraForks.gz|";
while (<A>){
  chop();
  s|/|_|g;
  my ($r, $f) = split (/;/);
  $r2cr{$r} = $r;
  $r2cr{$r} = $f if defined $f && $f =~ /_/;
  $nr ++;
}
print STDERR "read  extraForks.gz $nr\n";

#add for version R
#mongoexport -h da1 -d gh202003 -c frk --type=csv --fields nameWithOwner,parent.nameWithOwner | gzip > gh202003.frk.gz
#zcat gh202003.frk.gz|head
#nameWithOwner,parent.nameWithOwner
open A, "zcat gh202003.frk.gz|";
while (<A>){
  chop();
  s|/|_|g;
  my ($r, $f) = split(/,/, $_, -1);
  next if $r eq 'nameWithOwner';
  $f =~ s/^parent\.//;
  if (defined $r2cr{$r}){
    my $ff = "";
    $ff = $f if defined $f;
    print STDERR "seen $r as $r2cr{$r} now $ff\n" if $r2cr{$r} ne $ff && $r2cr{$r} ne $r;
  }
  $r2cr{$r} = $r;
  $r2cr{$r} = $f if defined $f;
  $nr++;
}
print STDERR "all forks: read $nr\n";

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
