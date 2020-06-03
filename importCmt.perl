#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
use strict;
use warnings;
use Error qw(:try);
use cmt;


my $bad = 0;
sub leb128 {
  my $la = $_[0];
	$bad = 0;
	if ($la < 128){
		return pack "C", $la;
	}
	if ($la<128*128){
		my $a = int($la/128);
		my $b = $la - $a * 128;
		$b = $b | 128;
		return (pack "C", $b) . (pack "C", $a);
	}
	if ($la<128*128*128){
		my $a = int ($la/128/128);
		my $bb = int ($la - $a * 128 * 128);
		my $b = int ($bb/128);
		my $c = $bb - $b * 128;
#print STDERR "$a $b $c\n";
		$c |= 128;
		$b |= 128;
		return (pack "C", $c) . (pack "C", $b) . (pack "C", $a);
	}
	if ($la<128*128*128*128){
		my $a = int ($la/128/128/128);
		my $bb = int ($la - $a * 128 * 128 * 128);
		my $b = int ($bb/128/128);
		my $cc = $bb - $b * 128 * 128;
		my $c = int ($cc/128);
		my $d = $cc - $c * 128;
#print STDERR "$a $b $c $d\n";
		$d |= 128;
		$c |= 128;
		$b |= 128;
		return (pack "C", $d) . (pack "C", $c) . (pack "C", $b) . (pack "C", $a);
	}
	if ($la<128*128*128*128*128){
		my $a = int ($la/128/128/128/128);
		my $bb = int ($la - $a * 128 * 128 * 128 * 128);
		my $b = int ($bb/128/128/128);
		my $cc = $bb - $b * 128 * 128 * 128;
		my $c = int ($cc/128/128);
		my $dd = $cc - $c * 128 * 128;
		my $d = int($dd/128);
		my $e = $dd - $d * 128; 
#print STDERR "$a $b $c $d\n";
		$e |= 128;
		$d |= 128;
		$c |= 128;
		$b |= 128;
		return (pack "C", $e) . (pack "C", $d) . (pack "C", $c) . (pack "C", $b) . (pack "C", $a);
	}
  print STDERR "too big $la\n";
	$bad = 1;
}

my $sections = 128;
my $ss = $ARGV[0]+0;
my $pre = "/data/All.blobs";
$pre = $ARGV[1] if defined $ARGV[1];
my (%fhob, %fhost, %fhosc);
open A, "$pre/commit_$ss.idx";
open B, "$pre/commit_$ss.bin";
my $ml = 0;
while (<A>){
  chop();
  my ($n, $of, $l, $c) = split(/;/);
  seek B, $of, 0;
  my $buf;
  my $ll = read B, $buf, $l;
	
  my $cont = $buf;
  my $clen = $ll;

  my ($tree, $parent, $auth, $cmtr, $ta, $tc, @rest) = extrCmt ($buf);
  my $bt = fromHex ($tree);
  my $bp = "";
  if ($parent ne ""){
    for my $p (split(/:/, $parent, -1)){
      $bp .= fromHex ($p);
    }
  }
  my $comment = join '\n', @rest;
  $ta =~ s/ .*//;
  next if $ta <= 0 || $ta > 1576800000; 
  #($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($ta);
  my $dt = int($ta/3600/24);
  my $res = pack 'S', $dt;
  $res .= fromHex($c);
  $res .= pack 'L', $ta;	
  $res .= $bt;
  my $la = length($auth);
  $res .= leb128($la).$auth;
  $res .= leb128(length($bp)).$bp;
#	print STDERR "".(length($bp))."\n";
  $res .= leb128(length($comment)).$comment;
#	print STDERR "".(length($comment))."\n";
  $res .= leb128($clen).$cont;
  print "$res" if $bad == 0;
}

