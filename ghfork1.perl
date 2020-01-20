use strict;
use warnings;
my (%r2cr, %cr2r);

open A, "zcat ghForkMap.gz|";
while (<A>){
  chop();
  my ($r, $f) = split (/;/);
  $r2cr{$r} = $f;
  $cr2r{$f}{$r}++;
}

sub mCmp {
  return -1 if length($a) < length($b);
  if (length($a) == length($b)){
    return $a cmp $b;
  }
  return 1;
}

my %r2ccr;
my $pid = "";
my %tmp;
open A, "zcat $ARGV[1]|";
while (<A>){
  chop();
  my ($p, $id) = split (/;/);
  if ($pid ne $id){
    output();
  }
  $tmp{$p}++; 
  $pid = $id;
}
output();

sub output {
  for my $pp (keys %tmp){
    if (defined $r2cr{$pp}){
      my $cr = $r2cr{$pp};
      $tmp{$cr} ++;
      for my $pp1 (keys %{$cr2r{$cr}}){
        $tmp{$pp1}++;
      }
    }
    if (defined $cr2r{$pp}){
      for my $pp1 (keys %{$cr2r{$pp}}){
        $tmp{$pp1}++;
      }
    }
  }
  my @ps = keys %tmp;
#  print STDERR "@ps\n";
  @ps = sort mCmp @ps;
  my $p0 = shift @ps;
  for my $pp (@ps){
    $r2ccr{$pp} = $p0;
  }
  %tmp = ();
}

my $off = 0;
$off = $ARGV[0] - 1 if defined $ARGV[0];
my $pc = "";
my @res;
%tmp = ();
my %noForks;
while(<STDIN>){
  chop();
  my @x = split(/;/); 
  if (defined  $r2ccr{$x[$off]}){
    $x[$off] = $r2ccr{$x[$off]};
  }else{
    $noForks{$x[$off]}++;
  }
  if ($x[0] ne $pc && $pc ne ""){
    if (scalar (keys %tmp)>=0) {
      output1 ();
    } 
    %tmp=(); 
    @res = ();
  }; 
  $pc = $x[0];
  my $s = join ';', @x; 
  $tmp{$s}++;
  push @res, $s
}
output1 ();

sub output1 {
  for my $i (@res){ 
    print "$i\n" if $tmp{$i} > 0;
    $tmp{$i} = 0;
  }
}

for my $p (keys %noForks){
  print STDERR "$p\n";
}
