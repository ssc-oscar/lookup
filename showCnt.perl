#!/usr/bin/perl -I /home/audris/lib64/perl5 -I /da3_data/lookup
use strict;
use warnings;
use Error qw(:try);
use woc;


my $type = $ARGV [0];
my $debug = 0;
$debug = $ARGV[1]+0 if defined $ARGV[1]; #select output format based on the cleantCmt function in cmt.pm
my $sections = 128;
my $raw = ""; #produce .idx/.bin database as in All.blobs
$raw = $ARGV[2] if defined $ARGV[2];


my (%fhob, %fhost, %fhosc);

my $fbasec="All.sha1c/${type}_";
$fbasec="All.sha1o/sha1.${type}_" if $type eq "blob";
for my $sec (0 .. ($sections-1)){
  my $pre = "/fast/";
  tie %{$fhosc{$sec}}, "TokyoCabinet::HDB", "$pre/${fbasec}$sec.tch", TokyoCabinet::HDB::OREADER,  
   16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
   or die "cant open $pre/$fbasec$sec.tch\n";
  if ( $type eq "blob"){
	 open $fhob{$sec}, "/data/All.blobs/blob_$sec.bin" or die "$!";
  }
}

while (<STDIN>){
  chop();
  my ($cmt, $rest) = split(/;/, $_, -1);
  if ($type eq "blob"){
	  getBlob($cmt);
     next;
  }
  if ($type eq "tree"){
    getTree ($cmt, "");
    next;
  }
  my $sec = hex (substr($cmt, 0, 2)) % $sections;
  my $cB = fromHex ($cmt);
  if (! defined $fhosc{$sec}{$cB}){
     print STDERR "no $type $cmt in $sec\n";
  }else{
    cleanCmt ($fhosc{$sec}{$cB}, $cmt, $debug);
  }
}

sub getBlob {
  my ($blob) = $_[0];
  my $sec = hex (substr($blob, 0, 2)) % $sections;
  my $bB = fromHex ($blob);
  if (! defined $fhosc{$sec}{$bB}){
     print STDERR "no blob $blob in $sec\n";
     return "";
  }
  my ($off, $len) = unpack ("w w", $fhosc{$sec}{$bB});
  my $f = $fhob{$sec};
  seek ($f, $off, 0);
  my $curpos = tell($f);
  my $codeC = "";
  my $rl = read ($f, $codeC, $len);
  my $code = safeDecomp ($codeC, "$sec;$curpos;$blob");
  print "blob;$sec;$rl;$curpos;$off;$len\;$blob\n$code\n";
}

sub getTree {
  my ($tree, $off) = @_;
  my $sec = hex (substr($tree, 0, 2)) % $sections;
  my $tB = fromHex ($tree);
  if (! defined $fhosc{$sec}{$tB}){
    print STDERR "no tree $tree\n";
    next;
  }
  my $codeC = $fhosc{$sec}{$tB};
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
  untie %{$fhosc{$sec}};
}
