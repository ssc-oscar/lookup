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
my $off = 0;
$off = $ARGV[0] if defined $ARGV[0];
my $pc = "";
my %tmp;
my @res;
my %noForks;
while(<STDIN>){
  chop();
  my @x = split(/;/); 
  if (defined  $r2cr{$x[$off]}){
    $x[$off] = $r2cr{$x[$off]};
  }else{
    $noForks{$x[$off]}++;
  }
  if ($x[$off] ne $pc && $pc ne ""){ 
    if (scalar (keys %tmp)>0) { 
      for my $i (@res){ 
        print "$i\n" if $tmp{$i} > 0;
        $tmp{$i} = 0;
      };
    } 
    %tmp=(); 
    @res = ();
  }; 
  $pc = $x[$off];
  my $s = join ';', @x; 
  $tmp{$s}++;
  push @res, $s
}

for my $i (@res){ 
  print "$i\n" if $tmp{$i} > 0;
  $tmp{$i} = 0;
}
for my $p (keys %noForks){
  print STDERR "$p\n";
}
