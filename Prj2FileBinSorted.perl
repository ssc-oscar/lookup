#!/usr/bin/perl -I /home/audris/lookup -I /home/audris/lib64/perl5
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
  my ($p, $f) = split (/\;/, $_);
  if ($p ne $pp && $pp ne "" && $doDump){
    $nc ++;
    while (my ($p1, $v) = each %tmp){
      my $fs = join ';', sort keys %{$v};
      my $fsC = safeComp ($fs);
      if (length ($fsC) > 100000000*20){
        print STDERR "too large for $p1: ".(length($fsC))."\n";
        my $pH = toHex(sHashV ($p1));
        open A, "$fname.large.$pH";
        print A $fsC;
        close (A);
      }else{
        $c2p{$p1} = $fsC;
      }
    }
    %tmp = ();
    $doDump = 0;
  }  
  $pp = $p;
  $tmp{$p}{$f}++;
  if (!($lines%100000000)){
    print STDERR "$lines done\n";
    $doDump = 1;
  }
}
while (my ($p1, $v) = each %tmp){
  my $fs = join ';', sort keys %{$v};
  my $fsC = safeComp ($fs);
  if (length ($fsC) > 100000000*20){
    print STDERR "too large for $p1: ".(length($fsC))."\n";
    my $pH = toHex(sHashV ($p1));
    open A, "$fname.large.$pH";
    print A $fsC;
    close (A);
  }else{
    $c2p{$p1} = $fsC;
  }
}
untie %c2p;

print STDERR "read $lines dumping $nc prjts\n";

