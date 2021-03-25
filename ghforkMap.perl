use strict;
use warnings;
my %r2cr;
my %rstar;
my $nr = 0;
open A, "zcat projectstr2.gz|";
while (<A>){
  chop();
  my ($r, $cd, $ud, $f, $del, $stars) = split (/;/);
  $r2cr{$r} = $r if !defined $r2cr{$r};
  $r2cr{$r} = $f if $f =~ /_/;
  #print STDERR "$r;$r2cr{$r}\n" if $r eq "tosch_ruote-kit" || $f eq "tosch_ruote-kit";
  $rstar{$r} = $stars;
  $nr ++;
}
print STDERR "read projectstr2.gz $nr\n";
open A, "zcat extraForks.gz|";
while (<A>){
  chop();
  s|/|_|g;
  my ($r, $f) = split (/;/);
  $r2cr{$r} = $r if !defined $r2cr{$r};
  $r2cr{$r} = $f if defined $f && $f =~ /_/;
  #print STDERR "$r;$r2cr{$r}\n" if $r eq "tosch_ruote-kit" || $f eq "tosch_ruote-kit";
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
  $r2cr{$r} = $r if !defined $r2cr{$r};
  $r2cr{$r} = $f if defined $f;
  #print STDERR "$r;$r2cr{$r}\n" if $r eq "tosch_ruote-kit" || $f eq "tosch_ruote-kit";
  $nr++;
}
print STDERR "all forks: read $nr\n";

$nr = -1;
my %cr2r;
my %r2cr1;
while (my ($r, $cr) = each %r2cr){ $r2cr1{$r} = $cr; $nr++}
print STDERR "cloned r2cr $nr\n";
$nr = -1;
while (my ($r, $cr) = each %r2cr1){
  $nr ++;
  #print STDERR "$r;$cr $nr\n";# if $r eq "tosch_ruote-kit" || $cr eq "tosch_ruote-kit";
  next if $r eq $cr || $cr eq "";
  my $ccr = $cr;
  my %seen;
  $seen{$r}++;
  $seen{$cr}++;
  while (defined $r2cr{$ccr} && $r2cr{$ccr} ne "" && $ccr ne $r2cr{$ccr} 
       && !defined $seen{$r2cr{$ccr}} # break the cycle
    ){
    $ccr = $r2cr{$ccr};
    $seen{$ccr}++;
    # print STDERR "correcting:$r;$cr;$ccr\n";
  }
  $r2cr{$r} = $ccr;
  print STDERR "corrected for $r from $cr to $r2cr{$r}; $nr done\n" if $cr ne $ccr; # || $r eq "tosch_ruote-kit" || $cr eq "tosch_ruote-kit" || $ccr eq "tosch_ruote-kit";
  $cr2r{$ccr}{$r}++;
}

while (my ($k, $v) = each %cr2r){
  my $ks = "";
  $ks = $rstar{$k} if defined $rstar{$k};
  my @ps = sort mCmp (keys %$v);
  for my $p (@ps){
    my $ps = "";
    $ps = $rstar{$p} if defined $rstar{$p};
    print "$p;$k;$ps;$ks\n";
  }
}

sub mCmp {
  return -1 if length($a) < length($b);
  if (length($a) == length($b)){
    return $a cmp $b;
  }
  return 1;
}
