#!/usr/bin/perl -I  /home/audris/lookup -I /home/audris/lib64/perl5
use strict;
use warnings;
use Error qw(:try);
use Compress::LZF;
use TokyoCabinet;
use cmt;

my (%tmp, %c2p, %c2p1);
my $sec;
my $nsec = 8;
$nsec = $ARGV[1] + 0 if defined $ARGV[1];

my $fname = "$ARGV[0]";
for $sec (0..($nsec -1)){
  $fname = "$ARGV[0].$sec.tch";
  $fname = $ARGV[0] if $nsec == 1;
  tie %{$c2p{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
      16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $fname\n";
}

my $lines = 0;
my $f0 = "";
my $cnn = 0;
my $nc = 0;
my $doDump = 0;
my $cp = "";
while (<STDIN>){
  chop();
  $lines ++;
  my ($hc, $f, $hb, $p) = split (/\;/, $_);
  if ($hc !~ m|^[0-9a-f]{40}$|){
    print STDERR "bad sha:$_\n";
    next;
  }
  my $c = fromHex ($hc);
  if (0){#keep project names totally intact
    $p =~ s/.*github.com_(.*_.*)/$1/;
    $p =~ s/^bitbucket.org_/bb_/;
    $p =~ s/\.git$//;
    $p =~ s|/*$||;
    $p =~ s/\;/SEMICOLON/g;
    $p = "EMPTY" if $p eq "";
  }
  if ($c ne $cp && $cp ne ""){
    $sec = (unpack "C", substr ($cp, 0, 1))%$nsec;
    $nc ++;
    my $ps = join ';', sort keys %tmp;
    my $psC = safeComp ($ps);
    large ($psC, $cp);
    %tmp = ();
    if ($doDump){
      dumpData ();
      $doDump = 0;
    }
  }  
  $cp = $c;
  $tmp{$p}++; 
  if (!($lines%500000000)){
    print STDERR "$lines done\n";
    $doDump = 1;
  }
}

my $ps = join ';', sort keys %tmp;
my $psC = safeComp ($ps);
$sec = (unpack "C", substr ($cp, 0, 1))%$nsec;
large($psC, $cp);
dumpData ();

sub large {
  my ($psC, $cp) = @_;
  if (length ($psC) > 10000000*20){
    my $cpH = toHex ($cp);
    print STDERR "too large for $cpH: ".(length($psC))."\n";
    open A, ">$fname.large.$cpH";
    print A $psC;
    close (A);
  }else{
    $c2p1{$sec}{$cp} = $psC;
  } 
}


sub dumpData {
  for my $s (0..($nsec -1)){
    while (my ($c, $v) = each %{$c2p1{$s}}){
      $c2p{$s}{$c} = $v;
    }
    %{$c2p1{$s}} = ();         
  }
}

for $sec (0..($nsec-1)){
  untie %{$c2p{$sec}};
}

print STDERR "read $lines dumping $nc commits\n";

