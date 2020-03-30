use strict;
use warnings;
my (%r2cr, %cr2r);

open A, "zcat ghForkMap.gz|";
while (<A>){
  chop();
  my ($r, $f) = split (/;/);
  $r2cr{$r} = $f;
  $cr2r{$f}{$r}++ if $r ne $f;
  if (!defined $r2cr{$f} && $r ne $f){ $r2cr{$f} = $f; }
}
my %r2tcr;
open A, "cat test.extra|";
while (<A>){
  chop();
  my ($r, $f) = split (/;/);
  if (defined $r2cr{$f}){
    $f = $r2cr{$f};
  }else{
    $r2cr{$f} = $f;
  }  
  $r2tcr{$r} = $f;
}


sub mCmp {
  return -1 if length($a) < length($b);
  if (length($a) == length($b)){
    return $a cmp $b;
  }
  return 1;
}
my %r2ccr;
my %ccr2r;
my %r2fcr;
my $pid = "";
my %tmp = ();
#for my $i ("1", "2", "3", "4", "5", "6", "7", "8", "9", "mmbrship"){
for my $i ("mmbrship"){
  $pid = "";
  %tmp = ();
  open A, "zcat $ARGV[0].$i|";
  while (<A>){
    chop();
    my ($p, $id) = split (/;/);
    if ($pid ne $id && $pid ne ""){
      output();
    }
    $tmp{$p}++ if $p ne ""; 
    $pid = $id;
  }
  output();
}

sub output {
  my @pp = sort mCmp (keys %tmp);
  my %fcr = ();
  for my $p (@pp){
    $fcr{$r2cr{$p}}++ if defined $r2cr{$p};
    $r2ccr{$p} = $pp[0];
    $ccr2r{$pp[0]}{$p}++;
  }
  my @top = keys %fcr;
  @top = sort {$fcr{$b}+0 <=> $fcr{$a}+0} @top if $#top > 0;
  #$r2fcr{$pp[0]} = join '|', @top if $#top >= 0;
  %tmp = ();
}


while (<STDIN>){
  chop();
  my ($cr, $r) = split (/;/, $_, -1);
  my ($ccr, $cr1, $fcr) = ("", "", "");
  $ccr = $r2ccr{$r} if defined $r2ccr{$r};
  #$fcr = $r2fcr{$ccr} if defined $r2fcr{$ccr};
  $cr1 = $r2cr{$r} if defined $r2cr{$r};
  my $test = "none";
  if (defined $r2tcr{$r}){
    if (defined $ccr2r{$ccr} && defined $ccr2r{$ccr}{$r2tcr{$r}}){
      $test = "success=$r2tcr{$r}=".(join '|', keys %{$ccr2r{$ccr}});
    }else{
      $test = "$r2tcr{$r}=".(join '|', keys %{$ccr2r{$ccr}});
    }
  }
  print "$r;$cr;$cr1;$ccr;$test\n";
}
  

