use warnings;
use strict;
use File::Temp qw/ :POSIX /;


my %badPrj = ("docker-library_commit-warehouse" => 1, "FER-HT_chef-repo" => 1,
              "devillnside_AcerRecovery" => 1, "ezterry_AcerRecovery" => 1);


print STDERR "starting ".(localtime())."\n";
open A, "|gzip>$ARGV[0].names";
open B, "|gzip>$ARGV[0].versions";
my (%f2num);
my $n = 0;
my $i = 0;

while(<STDIN>){
  chop();
  my ($id, @vs) = split(/\;/, $_, -1);
  my @vs1 = (); 
  for my $v1 (@vs){
    if (!defined $f2num{$v1}){
      next if defined $badPrj{$v1} || $v1 =~ m/^Gitmolrest\.[0-9]*$/;
      push @vs1, $v1;
      $f2num{$v1} = $i+0;
      print A "$v1\n";
      $i++;
    }
  }
  my $v0 = shift @vs1;
  for my $v1 (@vs1){
    print B "$f2num{$v0} $f2num{$v1}\n";
  } 
  $n ++;
  if (!($n%100000000)) { print STDERR "$n lines in $ARGV[0] done\n";}
}
print B "".($i-1)." ".($i-1)."\n";#ensure a complete list of vertices

