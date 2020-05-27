#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
use strict;
use warnings;
use Error qw(:try);

use TokyoCabinet;
use Compress::LZF;

sub toHex { 
	return unpack "H*", $_[0]; 
} 

sub fromHex { 
	return pack "H*", $_[0]; 
} 

my $debug = 0;
my $sections = 128;
my $parts = 2;
$debug = $ARGV[0] if defined $ARGV[0];
my $fbase="All.sha1c/tree_";


my (%fhob, %fhos);
#for my $sec (0 .. ($sections-1)){
#  my $pre = "/fast/";
#  $pre = "/fast" if $sec % $parts;
#  tie %{$fhos{$sec}}, "TokyoCabinet::HDB", "$pre/${fbase}$sec.tch", TokyoCabinet::HDB::OREADER,  
#	16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
#     or die "cant open $pre/$fbase$sec.tch\n";
#}

sub safeDecomp {
        my $codeC = $_[0];
        try {
                my $code = decompress ($codeC);
                return $code;
        } catch Error with {
                my $ex = shift;
                print STDERR "Error: $ex\n";
                return "";
        }
}

while (<STDIN>){
  chop();
  my $tree = $_;
  getTree ($tree, "");
}

sub getTree {
  my ($tree, $off) = @_;
  my $sec = hex (substr($tree, 0, 2)) % $sections;
  my $tB = fromHex ($tree);
  if ($debug < 0){
    print "$tree\n" if defined $fhos{$sec}{$tB};
    next;
  }
  if (! defined $fhos{$sec}){
    my $pre = "/fast/";
    $pre = "/fast" if $sec % $parts;
    tie %{$fhos{$sec}}, "TokyoCabinet::HDB", "$pre/${fbase}$sec.tch", TokyoCabinet::HDB::OREADER,
       16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $pre/$fbase$sec.tch\n";
  }
  if (! defined $fhos{$sec}{$tB}){
    print STDERR "no tree $tree\n";
    next;
  }
  my $codeC = $fhos{$sec}{$tB};
  my $code = safeDecomp ($codeC);
  my $len = length ($code);
  my $treeobj = $code;
  prtTree ($treeobj, $off);
}

sub prtTree {
  my ($treeobj, $off) = @_;
  while ($treeobj) {
  # /s is important so . matches any byte!
    if ($treeobj =~ s/^([0-7]+) (.+?)\0(.{20})//s) {
      my ($mode,$name,$bytes) = (oct($1),$2,$3);
      $name =~ s/\n/__NEWLINE__/g;
      printf "$off%06o;%s;%s\n",
        $mode, #($mode == 040000 ? "tree" : "blob"),
        unpack("H*", $bytes), $name;
      if ($debug == 3 && $mode == 040000){
        getTree (unpack("H*", $bytes), "$off  ");
      }
    }else {
      die "$0: unexpected tree entry";
    }
  }
}


for my $sec (0 .. ($sections-1)){
  untie %{$fhos{$sec}} if defined $fhos{$sec};
}

