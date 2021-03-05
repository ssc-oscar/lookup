#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
use strict;
use warnings;
use Error qw(:try);
use woc;


sub leb128 {
  my $la = $_[0];
  my $res = "";
  while ($la > 127){
    $res .= pack "C", (($la&127)|128);
    $la = $la >> 7;
    #print STDERR "1-$la\n";
  }
  #print STDERR "2-$la\n";
  return $res . (pack "C", $la&127);
}

#zcat /da?_data/basemaps/gz/c2chFullS9.s|head -1
#090000033aca6783fb1d4431b036b2dbe01a75ff;15040472322_qcloud-documents;50f7b0ebe4fffac8e794cf8d4e826a78efe6ea32;1a7de7464b33cd4b6ace78d29eb31d8692cf5636;dhaichen <31986479+v-dhaichen@users.noreply.github.com>;GitHub <noreply@github.com>;1566206168;15662061 68;+0800;+0800;�����
while (<STDIN>){
  chop();
  my ($c,$p,$tree,$parent,$author,$cmtr,$ta,$tc,$taz,$tcz,$comment) = split(/;/);
  my $bt = fromHex ($tree);
  my $bp = "";
  if ($parent ne ""){
    for my $p (split(/:/, $parent, -1)){
      $bp .= fromHex ($p);
    }
  }
  $ta =~ s/ .*//;
  $tc =~ s/ .*//;
  next if $ta <= 0 || $ta > 1576800000; 
  #($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($ta);
# "CREATE TABLE commit_q (sha1 FixedString(20), time Int32, tc Int32, tree FixedString(20), parent String, taz String, tcz String, author String, commiter String, project String, comment String) ENGINE = MergeTree() ORDER BY time" 
  my $res = fromHex($c);
  $res .= pack 'L', $ta;	
  $res .= pack 'L', $tc;	
  $res .= $bt;
  $res .= leb128(length($bp)).$bp;
  $res .= leb128(length($taz)).$taz;
  $res .= leb128(length($tcz)).$tcz;
  $res .= leb128(length($author)).$author;
  $res .= leb128(length($cmtr)).$cmtr;
  $res .= leb128(length($p)).$p;
  $res .= leb128(length($comment)).$comment;
  print "$res";
}

