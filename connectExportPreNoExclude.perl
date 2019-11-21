use warnings;
use strict;
use File::Temp qw/ :POSIX /;


print STDERR "starting ".(localtime())."\n";
my $n = 0;
my $i = 0;
my ($pid, $pv) = ("", "");
my ($pa, $pb) = (-1, -1);
my %tmp;
while(<STDIN>){
  chop();
  my ($id, $v) = split(/\;/, $_, -1);

  if ($id eq $pid && $pid ne ""){
    $tmp{$v}++;
  }else{
    prt ($pid);
  }
  $tmp{$v}++;
  ($pid, $pv) = ($id, $v);
}
prt($pid);

sub prt {
  my $pid = $_[0];
  my @vs = keys %tmp;
  %tmp = ();
  my $v0 = shift @vs;
  print "$pid;$v0" if $#vs >=0; # print only if commit connects two or more projects
  for my $v1 (@vs){ print ";$v1"; }
  print "\n" if $#vs >=0;
}

