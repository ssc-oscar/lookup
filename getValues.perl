#!/usr/bin/perl -I /home/audris/lookup -I /home/audris/lib64/perl5 -I /home/audris/lib/x86_64-linux-gnu/perl
#
use strict;
use warnings;
use Error qw(:try);
use cmt;

use TokyoCabinet;
use Compress::LZF;

my $fname="$ARGV[0]";
my (%clones);
my $hdb = TokyoCabinet::HDB->new();

my $f1 = "h";
my $f2 = "h";
$f1 = $ARGV[1] if defined $ARGV[1];
$f2 = $ARGV[2] if defined $ARGV[2];

my $split = 32;

for my $s (0..($split-1)){
  if(!tie(%{$clones{$s}}, "TokyoCabinet::HDB", "$fname.$s.tch",
                  TokyoCabinet::HDB::OREADER | TokyoCabinet::HDB::ONOLCK)){
        print STDERR "tie error for $fname.$s.tch\n";
  }
}


my $offset = 0;

while (<STDIN>){
  chop();
  my $ch = $_;
  my $l = length($ch);
  my $c = $ch;
	my $s = segH ($c, $split);
  if ($f1 =~ /h/){
		$c = fromHex($ch);
  }else{
    $s = sHash ($c, $split);
		$c = safeComp ($ch) if $f1 =~ /c/;
	}
  my $v = $clones{$s}{$c};
  if ($f2 =~ /r/){
    my $h = toHex (substr($v, 0, 20));
    my $d = unpack 'w', (substr($v, 20, length($v) - 20));
    print "$offset\;$l\;$ch\;$h\;$d\n";
  }else{
    my $res = ";$v";
    if ($f2 =~ /cs/){
      $res = ";".$v;
      $res = ';'.safeDecomp ($v);
    }      
    if ($f2 =~ /h/){
      my $n = length($v)/20;
      $res="";
      for my $i (0..($n-1)){
        $res .= ";" . toHex (substr($v, $i*20, 20));
      }
    }
    print "$ch$res\n";
  }
  $offset++;
}
for my $s (0..($split-1)){
  untie %{$clones{$s}};
}

