use warnings;
use strict;

#open A, "zcat $ARGV[0]|head -12|";
#open A, "zcat $ARGV[0]|head -12|";
open A, "zcat $ARGV[0]|";
open B, "zcat $ARGV[1]|";

my $finishedC = 0;
my $finishedC1 = 0;

sub getC {
  my ($pc, $pp, $c2p) = @_;
  $finishedC = 1;
  while (<A>){
    $finishedC = 0;
    chop();
    my ($c, $p) = split(/;/);
    if ($c eq $pc){
      $c2p ->{$pc}{$p}++;
    }else{
      return ($c, $p);
    }
  }
  return ($pc, $pp);
}

sub getC1 {   
  my ($pc, $pp, $c2p) = @_;
  $finishedC1 = 1;
  while (<B>){
    $finishedC1 = 0;
    chop();
    my ($c, $p) = split(/;/);
    if ($c eq $pc){
      $c2p ->{$pc}{$p}++;
    }else{
      return ($c, $p);
    }
  }
  return ($pc, $pp);
} 


my $first = 1, 
my ($c, $cb, $p, $pb);
my ($nc, $np);
my ($ncb, $npb);
my %c2p;
my %c2pb;

while (1){
  if ($first){
    $first = 0;
    my $l = <A>;
    chop ($l);
    ($c, $p) = split(/;/, $l);
    $c2p{$c}{$p}++;
    $l = <B>;
    chop ($l);
    ($cb, $pb) = split(/;/, $l);
    $c2pb{$cb}{$pb}++;
    ($nc, $np) = getC ($c, $p, \%c2p);
    ($ncb, $npb) = getC1 ($cb, $pb, \%c2pb);
    #print STDERR "init $c $nc $cb $ncb $finishedC $finishedC1\n";
  }
  if ($c eq $cb){
    my @vals = keys %{$c2p{$c}};
    #print STDERR "do $c $p :@vals: $nc $np $finishedC $finishedC1\n";
    doDiff ($c, \%c2p, \%c2pb);
    last if $finishedC; 
    %c2pb = ();
    %c2p = ();
    $c2p{$nc}{$np}++;
    @vals = keys %{$c2p{$nc}};
    #print STDERR "adding $nc $np :@vals:\n";
    $c2pb{$ncb}{$npb}++;
    ($c, $p, $cb, $pb) = ($nc, $np, $ncb, $npb);
    ($nc, $np) = getC ($c, $p, \%c2p);
    #print STDERR "new $nc $np\n";
    if (!$finishedC1){
      ($ncb, $npb) = getC1 ($cb, $pb, \%c2pb);
    }
    @vals = keys %{$c2p{$c}};
    #print STDERR "adding1 $c :@vals:\n";
    #last if $nc eq $c && $np eq $p;
  }else{
    if (($c cmp $cb) < 0){
      #print STDERR "out $c $finishedC $finishedC1\n";
      #print "output $c\n";
      #output $c2p{$c}
      for my $pp (keys %{$c2p{$c}}){
        print "$c;$pp\n";
      }
      %c2p = ();
      $c2p{$nc}{$np}++;
      ($c, $p) = ($nc, $np);
      ($nc, $np) = getC ($c, $p, \%c2p);
    }else{
      #print STDERR "out1 $c $finishedC $finishedC1\n";
      for my $pp (keys %{$c2p{$c}}){
        print "$c;$pp\n";
      }
      %c2p = ();
      $c2p{$nc} = $np;
      ($c, $p) = ($nc, $np);
      last if $finishedC; 
      ($nc, $np) = getC ($c, $p, \%c2p);
      last if $c eq $nc && $p eq $np;
      
      #print STDERR "impossible $c $cb\n";
    }
  }
  # print STDERR "$finishedC $finishedC1\n";
  #print STDERR "$c\n";
}      
sub doDiff {
  my ($c, $v, $v1) = @_;
  for my $p (keys %{$v ->{$c}}){
    print "$c\;$p\n" if !defined $v1 ->{$c}{$p};
    #print "$c\;$p\n";
  }
  for my $p (keys %{$v1 ->{$c}}){
    print "-$c\;$p\n" if !defined $v ->{$c}{$p};
  }
}
