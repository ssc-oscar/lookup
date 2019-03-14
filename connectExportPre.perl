use warnings;
use strict;
use File::Temp qw/ :POSIX /;

my %badPrj = (
"docker-library_commit-warehouse" => 1, 
"FER-HT_chef-repo" => 1, 
"devillnside_AcerRecovery" => 1, 
"ezterry_AcerRecovery" => 1, 
"bb_cyanogenmod_android_external_busybox" => 1,
"tianon_bad-ideas" => 1,
"wuertele_drupal-deployer-subtree-merge-2" => 1,
"wuertele_Drupal-Deployer" => 1,
"wuertele_drupal-deployer-subtree-merge" => 1,
"bb_kanooh_paddle-all" => 1,
"bb_kanooh_meesterlijk-gezond" => 1
);


my %badCmt;

open A, "largeCmt"; while (<A>){ chop(); $badCmt{$_}++}
open A, "zcat emptycs|"; while (<A>){ chop(); $badCmt{$_}++}

print STDERR "starting ".(localtime())."\n";
my $n = 0;
my $i = 0;
my ($pid, $pv) = ("", "");
my ($pa, $pb) = (-1, -1);
my %tmp;
while(<STDIN>){
  chop();
  my ($id, $v) = split(/\;/, $_, -1);

  # ignore problematic project ids
  next if defined $badPrj{$v} || $v =~ /^Gitmolrest\.[0-9]*$/;

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
  if (!defined $badCmt{$pid}){ # ignore large (many projects) and empty (no-files) commits 
    my $v0 = shift @vs;
    print "$pid;$v0" if $#vs >=0; # print only if commit connects two or more projects
    for my $v1 (@vs){ print ";$v1"; }
    print "\n" if $#vs >=0;
  }
}

