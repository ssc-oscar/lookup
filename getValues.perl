#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
#
use strict;
use warnings;
use Error qw(:try);
use woc;
use Getopt::Long qw(GetOptions);

use TokyoCabinet;
use Compress::LZF;
my $flat="n"; 
GetOptions('flat=s' => \$flat);



my $fname="$ARGV[0]";
my (%clones);
my $hdb = TokyoCabinet::HDB->new();

my $f1 = "h";
my $f2 = "h";

my $split = 32;


my $group=1; #how many field represent a single unit as in b2tac

my $offset = 0;
my $types = $fname;
$types =~ s|.*/||;
$types =~ s|Full[A-Z]$||;
my ($t1, $t2) = split(/2/, $types);
$f1 = "s" if ($t1 =~ /^[aAfpP]$/);

$f2 = "cs" if ($t2 =~ /^[AafpP]$/);

$f1 = "h" if ($t1 =~ /^[cbw]$/ || $t1 =~ /^(ob|td)$/);
$f2 = "h" if ($t2 =~ /^[cb]$/ || $t2 =~ /^(cc|pc|ob|td)$/);

$f2 = "sh" if $types =~ /b2f[aA]/;
$f2 = "s" if $t2 =~ /^ta$/;
$f2 = "s" if $types eq "b2tk"; 
$f2 = "s" if $types eq "td2f"; 
$f2 = "r" if $types =~ /^c2[hr]$/;

$f1 = "s" if ($t1 eq "PS" || $t1 eq "PF" || $t1 eq "PFS"); 
$f2 = "s" if ($t2 eq "PS" || $t2 eq "PF" || $t2 eq "PFS"); 

$f2 = "hhwww" if ($t2 eq "rhp");


$f1 = $ARGV[1] if defined $ARGV[1];
$f2 = $ARGV[2] if defined $ARGV[2];

if ($types =~ /^[pP]2[pP]/ || $types =~ /^[aA]2[aA]/){
  $split = 1;
  $f1 = "s";
  $f2 = "cs";
  $f2 = "cs" if ($types eq "P2p" ||$types eq "A2a");
}
if ($types eq "b2BadDate" || $types eq "b2ManyP"){
  $split = 1;
  $f1 = "h";
  $f2 = "cs";
}
if ($types =~ /^[aA]2fb/ || $types =~ /^[aA]2[bc]/){
  $f1 = "s";
  $f2 = "h";
}
if ($types eq "c2dat"){
  $f1 = "h";
  $f2 = "s";
}
if ($types eq "b2tac"){
  $f1 = "h";
  $f2 = "cs";
  $group  = 3;
}
$split = $ARGV[3] if defined $ARGV[3];

sub get {
  my ($c, $s) = @_;
  if (!defined $clones{$s}){
    if ($split > 1){
      if(!tie(%{$clones{$s}}, "TokyoCabinet::HDB", "$fname.$s.tch",
         TokyoCabinet::HDB::OREADER | TokyoCabinet::HDB::ONOLCK)){
        die "tie error for $fname.$s.tch\n";
      }
    }else{
      if(!tie(%{$clones{"0"}}, "TokyoCabinet::HDB", "$fname.tch", 
          TokyoCabinet::HDB::OREADER | TokyoCabinet::HDB::ONOLCK)){
        die "tie error for $fname.tch\n";
      }
    }
  }
  return $clones{$s}{$c} if defined $clones{$s}{$c};
  return undef;
}

while (<STDIN>){
  chop();
  my $large = 0;
  my ($ch, @rest) = split(/;/, $_, -1);
  my $extra = "";
  $extra = join ';', @rest if $#rest >= 0;
  my $l = length($ch);
  my $c = $ch;
  my $s = segH ($c, $split);
  if ($f1 =~ /[hw]/){
    $c = fromHex($ch);
  }else{
    $s = sHash ($c, $split);
    $c = safeComp ($ch) if $f1 =~ /c/;
  }
  my $v = get ($c, $s);
  if (!defined $v){
    my $lF = "$fname.$s.tch.large.";
    if ($f1 =~ /h/){
      $lF .= $ch;
    }else{
      $lF .= sprintf "%.8x", sHashV ($c);
    }
    if (-f $lF){
      $large = 1;
      my $len = -s $lF;
      if ($f2 =~ /h/){
        open VAL, $lF;
        $v="";
        seek (VAL, length($c)+1, 0);
        read (VAL, $v, $len-length($c));
      }else{
        open VAL, "zcat $lF|";
        <VAL>; #drop first line: it is just the key
        $v="";
        while (<VAL>){ $v .= $_; }
      } 
      #print STDERR "big file\n";
      #print "$ch\n";
    }else{
      # Previously left, I suppose debug.
      # I propose to remove (lgonzal6 6/1/23)
      #print "$ch\n";
      #print STDERR "no $ch in $fname $f1 $f2\n";
      
      # Error message when not found
      print STDERR "No $ch in $fname\n";
      if ($f1 eq "s" && $f2 eq "cs"){
        $v = ""; #not sure why it was $v = safeComp ($c);
      }else{
        next;
      }
    }
  }
  if ($f2 =~ /r/){
    if ($f2 eq "r"){
      my $h = toHex (substr($v, 0, 20));
      my $d = unpack 'w', (substr($v, 20, length($v) - 20));
      print "$ch\;$h\;$d\n";
    }else{
      my $r = toHex (substr($v, 0, 20));
      my $h = toHex (substr($v, 20, 20));
      my ($dr, $dh, $part) = unpack 'w*', substr($v, 40, length($v) - 40);
      print "$ch\;$r\;$dr;$h;$dh;$part\n";
    }
  }else{
    my $res = ";$v";
    if ($f2 =~ /cs/){
      if ($large){
        $res = ";".$v;
      }else{
        $res = ';'.safeDecomp ($v);
      }
    }      
    if ($f2 eq "h"){
      my $n = length($v)/20;
      $res="";
      for my $i (0..($n-1)){
        $res .= ";" . toHex (substr($v, $i*20, 20));
      }
    }
    if ($f2 eq "sh"){
      my $c = toHex(substr($v, length($v)-20, 20));
      my ($t, $a) = split(/;/, substr($v, 0, length($v)-20));
      $res = ";$t;$a;$c"; 
    }
	  if ($flat eq "n"){
      if ($extra eq  ""){
		    print "$ch$res\n";
	    }else{ 
        print "$ch;$extra$res\n";
      }
    }else{
      $res =~ s/^;//;
      $ch .= ";$extra" if $extra ne "";
      my @vvs;
      my $lres = length($res);
      if ($lres < 100000*41){
        @vvs = split(/;/, $res, -1);
      }else{#handle super long strings
        my $inc = 41*100000;
        for my $part (0..int(($lres+1)/$inc)){
          my $from = $inc * $part;
          my $to   = $inc + $from - 1;
          $to = $lres if $to > $lres;
          push @vvs, (split(/;/, substr($res, $from, $to-$from), -1));
          #print STDERR "els=".(($lres+1)/41)." got=".($#vvs+1)." part=$part from=$from to=$to lres=$lres ".(substr(substr($res, $from, $to-$from), 0, 42))."\n";
        }
      }
      if ($group == 1){
        for my $vv (@vvs){
          print "$ch;$vv\n";
        }
      }else{
        for my $ii (0..($#vvs/$group)){
          print "$ch;$vvs[$ii*$group];$vvs[$ii*$group+1];$vvs[$ii*$group+2]\n";
        }
      }
    }
	}
  $offset++;
}
for my $s (0..($split-1)){
  untie %{$clones{$s}} if defined $clones{$s};
}

