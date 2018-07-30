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
    my @vs = keys %tmp;
    %tmp = ();
    my $v0 = shift @vs;
    print "$v0" if $#vs >=0;
    for my $v1 (@vs){
      print ";$v1";
    }
    print "\n" if $#vs >=0;
  }
  $tmp{$v}++;
  ($pid, $pv) = ($id, $v);
}
my @vs = keys %tmp;
my $v0 = shift @vs;
print "$v0" if $#vs >=0;
for my $v1 (@vs){ print ";$v1"; }
print "\n" if $#vs >=0;

