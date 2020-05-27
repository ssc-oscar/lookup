#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl");
use strict;
use warnings;
use Error qw(:try);
use TokyoCabinet;
use Compress::LZF;
use cmt;

my $debug = 1;
my $sections = 128;
my $fbasec="All.sha1c/commit_";
my $fbase="All.sha1c/tree_";
my $C = "";

my (%fhob, %fhos, %fhosc);
for my $sec (0 .. ($sections-1)){
  my $pre = "/fast/";
  tie %{$fhos{$sec}}, "TokyoCabinet::HDB", "$pre/${fbase}$sec.tch", TokyoCabinet::HDB::OREADER,  
	  16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $pre/$fbase$sec.tch\n";
  tie %{$fhosc{$sec}}, "TokyoCabinet::HDB", "$pre/${fbasec}$sec.tch", TokyoCabinet::HDB::OREADER,  
	  16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $pre/$fbasec$sec.tch\n";
}

while (<STDIN>){
  chop();
  my $cmt = $_;
  if (defined $badCmt{$cmt}){
    print STDERR "bad commit $cmt\n";
    next;
  }
  $C = $cmt;
  my $sec = hex (substr($cmt, 0, 2)) % $sections;
  my $cB = fromHex ($cmt);
  if (! defined $fhosc{$sec}{$cB}){
    print STDERR "no $cmt in $sec\n";
  }else{
    my $codeC = $fhosc{$sec}{$cB};
    my @code = split (/\n/, safeDecomp ($codeC), -1);
    if ($code[0] =~ /^tree ([0-9a-f]{40})$/){      
      getTree ($1, "");
    }else{
      print STDERR "no tree for $cmt on line 1 $code[0]\n";
    }  
  }
}

sub getTree {
  my ($tree, $off) = @_;
  return "" if $tree eq "4b825dc642cb6eb9a060e54bf8d69288fbee4904"; #empty tree
  my $sec = hex (substr($tree, 0, 2)) % $sections;
  my $tB = fromHex ($tree);
  if ($debug < 0){
    print "$tree\n" if defined $fhos{$sec}{$tB};
    next;
  }
  if (! defined $fhos{$sec}{$tB}){
    print STDERR "no tree $tree for commit $C\n";
    return "";
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
      $name =~ s/\r/__CR__/g;
      $name =~ s/;/SEMICOLON/g;
      $name = "$off/$name";
      $name =~ s|^/||;
      printf "$C;%s;%s\n", unpack("H*", $bytes), $name if $mode != 040000;
      if ($debug == 1 && $mode == 040000){
        getTree (unpack("H*", $bytes), $name);
      }
    }else {
      die "$0: unexpected tree entry";
    }
  }
}


for my $sec (0 .. ($sections-1)){
  untie %{$fhos{$sec}} if defined $fhos{$sec};
  untie %{$fhosc{$sec}} if defined $fhosc{$sec};
}

