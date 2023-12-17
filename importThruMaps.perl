#!/usr/bin/perl -I /home/audris/lib64/perl5 -I /da3_data/lookup
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

my $fname = $ARGV[0] if defined $ARGV[0] or die "Path not provided";
open A, "zcat $fname |" or die "failed to open $fname";

while(<A>){
    my ($blob, $commit, $project, $time, $author, @rest) = split(/;/);
    my $dep = join ';', @rest;
    chomp $dep;
    my $lang = (split '\/', $fname)[-2];
    $lang =~ s/thruMaps//;
    $time =~ s/ .*//;
    next if $time <= 0;
    my $res = fromHex($blob);
    $res .= fromHex($commit);
    $res .= leb128(length($project)).$project;
    $res .= pack 'L', $time;
    $res .= leb128(length($author)).$author;
    $res .= leb128(length($lang)).$lang;
    $res .= leb128(length($dep)).$dep;
    #print;
    print "$res" if $bad == 0;
}

