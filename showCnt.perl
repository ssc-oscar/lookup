#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl");
use strict;
use warnings;
use Error qw(:try);
use woc;


my $type = $ARGV [0];

# this is to handle different output formats
my $debug = 0;
$debug = $ARGV[1]+0 if defined $ARGV[1]; #select output format based on the cleantCmt function in cmt.pm
my $sections = 128;

#this is to handle whether or not tch is used as content or offset for bdiff, trees, and commits
my $ncnt = 0; 
$ncnt = $ARGV[2] if defined $ARGV[2];


my (%fhob, %fhost, %fhosc);

my $fbasec="All.sha1c/${type}_";
if ($type eq "blob" || ($type =~ /bdiff|commit|tree/ && $ncnt) ){
  $fbasec="All.sha1o/sha1.${type}_";
}
for my $sec (0 .. ($sections-1)){
  my $pre = "/fast";
  tie %{$fhosc{$sec}}, "TokyoCabinet::HDB", "$pre/${fbasec}$sec.tch", TokyoCabinet::HDB::OREADER | TokyoCabinet::HDB::ONOLCK,  
    16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
    or die "cant open $pre/$fbasec$sec.tch\n";
  if ( $type eq "blob" || ($type =~ /bdiff|commit|tree/ && $ncnt)){
	  open $fhob{$sec}, "/data/All.blobs/${type}_$sec.bin" or die "$!";
  }
}

while (<STDIN>){
  chop();
  my ($cmt, $rest) = split(/;/, $_, -1);
  if ($type eq "bdiff"){
    getBdiff ($cmt);
    next;
  }
  if ($type eq "blob"){
    getBlob ($cmt);
    next;
  }
  if ($type eq "tree"){
    getTree ($cmt, "");
    next;
  }
  if ($type eq "tkns" || $type eq "tdiff"){
    getTkns ($cmt, $type);
    next;
  }
  my $sec = hex (substr($cmt, 0, 2)) % $sections;
  my $cB = fromHex ($cmt);
  if (! defined $fhosc{$sec}{$cB}){
     print STDERR "no $type $cmt in $sec\n";
  }else{
    my $codeC = "";
    if ($ncnt){
      my ($off, $len) = unpack ("w w", $fhosc{$sec}{$cB});
      my $f = $fhob{$sec};
      seek ($f, $off, 0);
      $codeC = ""; my $rl = read ($f, $codeC, $len);
    } else {
      $codeC = $fhosc{$sec}{$cB};
    }
    cleanCmt ($codeC, $cmt, $debug);
  }
}

sub getTkns {
  my ($ch, $type) = @_;
  my $sec = hex (substr($ch, 0, 2)) % $sections;
  my $cB = fromHex ($ch);
  if (! defined $fhosc{$sec}{$cB}){
    print STDERR "no content for $type $ch in $sec\n";
    return "";
  }
  my $codeC = $fhosc{$sec}{$cB};
  print "".(safeDecomp ($codeC, "$sec;$ch"));
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
  #print "blob;$sec;$rl;$curpos;$off;$len\;$blob\n";
  print "$code\n";
}

sub getBdiff {
  my ($ch) = $_[0];
  my $sec = hex (substr($ch, 0, 2)) % $sections;
  my $cB = fromHex ($ch);
  if (! defined $fhosc{$sec}{$cB}){
    print STDERR "no bdiff for commit $ch in $sec\n";
    return "";
  }
  my $buff = "";
  if ($ncnt){ #use offset
    my ($off, $len) = unpack ("w w", $fhosc{$sec}{$cB});
    my $f = $fhob{$sec};
    seek ($f, $off, 0);
    my $codeC = "";
    my $rl = read ($f, $codeC, $len);
    #  print STDERR "$off;$sec;$ch;$len;$rl\n";
    $buff = safeDecomp ($codeC, "$off;$sec;$ch;$len;$rl");
  }else{ # use content
    my $val = $fhosc{$sec}{$cB};
    #print STDERR "got bdiff sec=$sec len=".(length($val))."\n";
    $buff = safeDecomp ($val, "sec;$ch");
  }
  my $res = "";
  while ($buff =~ s/^(.+?)\0//){
    my $n = $1;
    my $h = ""; 
    if (length($buff)>=20){
      $h = substr($buff, 0, 20);
      $buff = substr($buff, 20, length($buff) - 20);
    } else {
      print STDERR "no hash: $sec;$ch\n";
      exit();
    }
    my $t = substr ($n, 0, 1);
    $n = substr ($n, 1, length($n)-1);
    #print STDERR "$c;$t;$n;".(toHex($h)).";".length($buff)."\n";
    my $new = "";
    my $old = "";
    if ($t =~ /[crm]/){
      $new = toHex ($h);
      if ($t eq "r"){
        $old = $1 if ($buff =~ s/^(.+?)\0//);
      }else{
        if ($t eq "m"){
          if (length($buff) >= 20){
            $old = toHex (substr($buff,0,20));
            $buff = substr($buff,20,length($buff) - 20);
          }else{
            print STDERR "1:$n;$ch;".(length($buff))."\n";
            exit ();
          }
        }
      }
    }else{
      $old = toHex ($h);
    }
    $res.= "$ch;$n;$new;$old\n";
  }
  print "bdiff;$sec;$res";
}

sub getTree {
  my ($tree, $off) = @_;
  my $sec = hex (substr($tree, 0, 2)) % $sections;
  my $tB = fromHex ($tree);
  if (! defined $fhosc{$sec}{$tB}){
    print STDERR "no tree $tree\n";
    next;
  }
  my $codeC = "";
  if ($ncnt){ #use offset
    my ($off, $len) = unpack ("w w", $fhosc{$sec}{$tB});
    my $f = $fhob{$sec};
    seek ($f, $off, 0);
    my $rl = read ($f, $codeC, $len);
  }else{
    $codeC = $fhosc{$sec}{$tB};
  }
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
      my ($mode, $name, $bytes) = (oct($1), $2, $3);
      $name =~ s/\n/__NEWLINE__/g;
      printf "$off%06o;%s;%s\n",
        $mode, #($mode == 040000 ? "tree" : "blob"),
        unpack ("H*", $bytes), $name;
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
