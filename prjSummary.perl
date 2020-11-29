use strict;
use warnings;

my $v = $ARGV[0];
my $s = $ARGV[1];

my %ff;
for my $ty ("P2f", "P2a", "P2b"){
  open $ff{$ty}, "zcat ${ty}Full$v$s.s|";
}

my $batch = 0;
my %d;
my %pP;
my %L;
#open A, 'lsort 30G -t\; -k1,2 --merge  <(zcat P2cFull'.$v.$s.'.s) <(zcat P2cFull'.$v.($s+32).'.s) <(zcat P2cFull'.$v.($s+64).'.s) <(zcat P2cFull'.$v.($s+96).'.s)|';
#lsort 30G -t\; -k1,2 --merge  <(zcat P2cFullS0.s) <(zcat P2cFullS32.s) <(zcat P2cFullS64.s) <(zcat P2cFullS96.s)
while (<STDIN>){
  chop ();
  #print "$_\n";
  my ($p, $c) = split (/;/, $_, -1);
  $L{P2c} = "$p;$c"; 
  if (defined $pP{P2c} && $pP{P2c} ne $p){
    out ();
    for my $ty ("P2c", "P2f", "P2a", "P2b"){
      $d{$ty} = ();
    }
  }
  $d{P2c}{$c}++;
  $L{P2c} = "";
  $pP{P2c} = $p;
}

out ();

sub out {
  catchUp($pP{P2c}, "P2a");
  catchUp($pP{P2c}, "P2b");
  catchUp($pP{P2c}, "P2f");
  print "$pP{P2c}";
  my @a = keys %{$d{P2c}};
  print ";".scalar(@a);
  @a = keys %{$d{P2a}};
  print ";".scalar(@a);
  @a = keys %{$d{P2b}};
  print ";".scalar(@a);
  @a = keys %{$d{P2f}};
  print ";".scalar(@a);
  my %ext = ();
  for my $fi (@a){
    $fi =~ s/.*\.//;
    $ext{$fi}++ if $fi ne "";
  }
  @a = sort { $ext{$b} <=> $ext{$a} }  keys %ext;
  print ";".scalar(@a);
  print ";$a[0]=$ext{$a[0]}" if $#a >= 0;
  print ";$a[1]=$ext{$a[1]}" if $#a >= 1;
  print "\n";
}

sub catchUp {
  my ($p, $ty) = @_;
  my $B = $ff{$ty};
  if (! defined $L{$ty}){
    my $l = <$B>;
    chop ($l);
    $L{$ty} = $l;
    my ($pr, $c) = split (/;/, $l, -1);
    my $where = ($pr cmp $p);
    if ($where == 0){
      $d{$ty}{$c}++;
      $L{$ty} = "";
    }
    else{
      if ($where > 0){
        return;
      }else{
        die "$pr $p in $ty\n";
      }
    }
  }else{
    if ($L{$ty} ne ""){
      my ($pr, $c) = split (/;/, $L{$ty}, -1);
      my $where = ($pr cmp $p);
      if ($where == 0){
        $d{$ty}{$c}++;
        $L{$ty} = "";
      }else{
        if ($where > 0){
          return;
        }else{
          die "$pr $p in $ty\n";
        }
      }
    }
  }
  while (<$B>){
    chop ();
    $L{$ty} = $_;
    my ($pr, $c) = split (/;/, $_, -1);
    my $where = ($pr cmp $p);
    if ($where == 0){
      $d{$ty}{$c}++;
      $L{$ty} = "";
    }else{
      if ($where > 0){
        return;
      }else{
        die "$pr $p in $ty\n";
      }
    }
  }
}
