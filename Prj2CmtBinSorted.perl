#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
use strict;
use warnings;
use Error qw(:try);
use Compress::LZF;
use TokyoCabinet;
use cmt;

my (%tmp, %c2p, %c2p1);

my $fname = "$ARGV[0]";
tie %c2p, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
      16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $fname\n";

my $lines = 0;
my $f0 = "";
my $cnn = 0;
my $nc = 0;
my $doDump = 0;
my $isPrj = 0; #process project name according to our rules
$isPrj = $ARGV[1] if defined $ARGV[1] ;  
my $pp = "";
while (<STDIN>){
  chop();
  $lines ++;
  my ($p, $hc) = split (/\;/, $_);
  if ($hc !~ m|^[0-9a-f]{40}$|){
    print STDERR "bad sha:$_\n";
    next;
  }
  my $c = fromHex ($hc);
  #this may affect author when used to map authors to commits
  if ($isPrj){
    $p =~ s/.*github.com_(.*_.*)/$1/;
    $p =~ s/^bitbucket.org_/bb_/;
    $p =~ s/\.git$//;
    $p =~ s|/*$||;
    $p =~ s/\;/SEMICOLON/g;
  }
  $p = "EMPTY" if $p eq "";
  if ($p ne $pp && $pp ne "" && $doDump){
    while (my ($p1, $v) = each %tmp){
      $nc ++;
      my $cs = join '', sort keys %{$v};
      #if (length($cs) >= 108894657*20){
      if (length($cs) >=  100000000*20){
        print STDERR "too large for $p1: ".(length($cs))."\n";
        my $pH = sprintf "%.8x", sHashV ($p1);
        open A, ">$fname.large.$pH";
        print A $cs;
        close A;
      }else{
        $c2p{$p1} = $cs;
      }
    }
    %tmp = ();
    $doDump = 0;
  }  
  $pp = $p;
  $tmp{$p}{$c}++;
  if (!($lines%50000000)){
    print STDERR "$lines done\n";
    $doDump = 1;
  }
}
while (my ($p1, $v) = each %tmp){
  my $cs = join '', sort keys %{$v};
  if (length($cs) >= 100000000*20){
    print STDERR "too large for $p1: ".(length($cs))."\n";
    my $pH = sprintf "%.8x", sHashV ($p1);
    open A, ">$fname.large.$pH";
    print A $cs;
    close A;
  }else{
    $c2p{$p1} = $cs;
  }
}
untie %c2p;

print STDERR "read $lines dumping $nc prjts\n";

