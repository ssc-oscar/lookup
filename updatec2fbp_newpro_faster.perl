#!/usr/bin/perl -I /home/audris/lib64/perl5
use strict;
use warnings;
use Compress::LZF;
use Digest::SHA qw (sha1_hex sha1);
use Time::Local;

#########################
# create code to versions database
#########################
use TokyoCabinet;

sub fromHex { 
	return pack "H*", $_[0]; 
} 

sub toHex { 
        return unpack "H*", $_[0]; 
} 

my ($prj, $rev, $tree, $parent, $aname, $cname, $alogin, $clogin, $path, $atime, $ctime, $f, $comment) = ("","","","","","","","","","","","","");
my (%c2p, %p2c, %b2c, %c2f);

#my $prj = "";
my $pre = "/fast1/All.sha1c";
my $sections = 128;
# need to update the tree_$sec.tch first ... for new data. like update0 and update1...
my (%fhos);
my (%fhoc);
for my $sec (0 .. ($sections-1)){
  tie %{$fhos{$sec}}, "TokyoCabinet::HDB", "$pre/tree_$sec.tch", TokyoCabinet::HDB::OREADER,  
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $pre/tree_$sec.tch\n";
  tie %{$fhoc{$sec}}, "TokyoCabinet::HDB", "$pre/commit_$sec.tch", TokyoCabinet::HDB::OREADER,  
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $pre/commit_$sec.tch\n";
}



my $proexist = 1;
my $preprj = "";


my %cmtstmp;

my $prev = "";
my $fs="";
while(<STDIN>){
  chop();
  ($prj, $rev, $tree, $parent, $aname, $cname, $alogin, $clogin, $path, $atime, $ctime, $f, $comment) = split(/\;/, $_, -1);
  next if length($rev) ne 40;    
  #p2c, no restruction, 
  my $rev_pac = fromHex($rev);
  my $k = "$prj;$rev;$tree;$parent";
  if ($prev ne $k && $prev ne ""){
    dump_newrecords($prev, $fs);
    $fs = $f;
    $prev = $k;
  }else{
    if ($prev eq ""){
      $fs = $f;
      $prev = $k;
    }else{
      $fs .= ";$f";
    }
  }
}
#print "here:$prev;$fs\n";
dump_newrecords($prev, $fs);

#open(my $Curstatus, '>>', '/da4_data/play/newc2fbpPieces/Curstatus1');
#print $Curstatus "One piece process finished\n";
#close $Curstatus;


sub extr {
  my $v = $_[0];
  #my $v1 = unpack "H*", $v;
  my $v1 = $v;
  my $n = length($v1);
  my @v2 = ();
  if ($n >= 20){
    for my $i (0..($n/20-1)){
      $v2[$i] = substr ($v1, $i*20, 20);
    }
  }
  return @v2;
}

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




sub popSeg {
  my ($f1, $map) = @_;
  my @fsegs = split(/\//, $f1, -1);
  my $pre = "/$fsegs[0]";
  $map ->{$pre} = $f1;
  for my $d (1..$#fsegs){
    $pre .= "/$fsegs[$d]";
    $map ->{$pre} = $f1;
  }
  #$map ->{$f1}{f} = 1;
}

sub getCT {
  my $c = $_[0];
  my $sec = hex (substr($c, 0, 2)) % $sections;
  my $cB = fromHex ($c);
  my $codeC = $fhoc{$sec}{$cB};
  my $code = safeDecomp ($codeC, $c);

  my ($tree, $parent, $auth, $cmtr, $ta, $tc) = ("","","","","","");
  my ($pre, @rest) = split(/\n\n/, $code, -1);
  for my $l (split(/\n/, $pre, -1)){
     #print "$l\n";
     $tree = $1 if ($l =~ m/^tree (.*)$/);
     $parent .= ":$1" if ($l =~ m/^parent (.*)$/);
     ($auth, $ta) = ($1, $2) if ($l =~ m/^author (.*)\s([0-9]+\s[\+\-]+\d+)$/);
     ($cmtr, $tc) = ($1, $2) if ($l =~ m/^author (.*)\s([0-9]+\s[\+\-]+\d+)$/);
  }
  $parent =~ s/^:// if defined $parent;
  return ($tree);
}

sub getTO {
  my $t1 = $_[0];
  my $sec = hex (substr($t1, 0, 2)) % $sections;
  my $tB = fromHex ($t1);
  my $codeC = $fhos{$sec}{$tB};
  if (defined $codeC && length ($codeC) > 0){
    return safeDecomp ($codeC);
  }else{
    return "";
  }
}


my %did = ();
my %didP = ();

sub getTRP {
  my ($to, $prefix, $map, $stuff) = @_;
  if (length ($to) == 0){
    print STDERR "no tree $stuff->[2];cmt=$stuff->[0];$prefix/;prj=$stuff->[1]\n";
    return;
  }
  #print "getTRP:$prefix\n";
  while ($to) {
    if ($to =~ s/^([0-7]+) (.+?)\0(.{20})//s) {
      my ($mode, $name, $bytes) = (oct($1),$2,$3);
      my $nO = $name;
      my $bH = toHex ($bytes);
      #print "$prefix/$name\n";
      if (defined $map->{"$prefix/$nO"}){
         if ($mode == 040000){
            #print "got tree: $prefix $bH\n";
            getTRP (getTO($bH), "$prefix/$nO", $map, $stuff);
         }else{
            $didP{"$prefix/$nO"} = $bH;
            print "P $stuff->[0];$prefix/$nO;$bH;$stuff->[1]\n";
         }
      }
    }    
  }
}
sub getTR {
  my ($to, $prefix, $map, $stuff) = @_;
  if (length ($to) == 0){
    print STDERR "no tree $stuff->[2];cmt=$stuff->[0];$prefix/;prj=$stuff->[1]\n";
    return;
  }
  #print "getTR:$prefix\n";
  while ($to) {
    if ($to =~ s/^([0-7]+) (.+?)\0(.{20})//s) {
      my ($mode, $name, $bytes) = (oct($1),$2,$3);
      my $nO = $name;
      my $bH = toHex ($bytes);
      #print "$prefix/$name\n";
      if (defined $map->{"$prefix/$nO"}){
         if ($mode == 040000){
            #print "got tree: $prefix $bH\n";
            getTR (getTO($bH), "$prefix/$nO", $map, $stuff);
         }else{
            $did{"$prefix/$nO"}{$bH}++;
            print "$stuff->[0];$prefix/$nO;$bH;$stuff->[1]\n";
         }
      }
    }    
  }
}

sub compare {
  my ($map, $stuff) = @_;
  while (my ($k, $v) = each %{$map}){
     #print "$k;$v\n";
     if ($k eq "/$v"){
        if (defined $did{$k}){           
        }else{
           if (defined $didP{$k}){
             print "deleted: $stuff->[0];$k;$didP{$k};$stuff->[1]\n";
           }
           print STDERR "$.;no $k;$stuff->[0];;;$stuff->[1]\n";
        }
     }
  }
}
   
sub  dump_newrecords {
 my ($p1, $c1h, $t1, $parent) = split (/\;/, $_[0], -1);
 my $c1 = fromHex ($c1h);
 my $t2 = $t1;
 my @fs = sort split(/\;/, $_[1], -1);

 my %map = ();
 my %mapP = ();
 for my $f1 (@fs){ 
   if ($f1 =~ /=>/){
     if ($f1 =~ /{/){
       $f1 =~ s/{.*?=> (.*?)}/$1/g;
       $f1 =~ s|/+|/|g;
     }
     else{
       $f1 =~ s/.*=> //;
       #printf "$f1\n";
       #return;
     }
   }
   #printf "f1:".$f1." t1:$t1\n";
   popSeg ($f1, \%mapP);
   popSeg ($f1, \%map);
 }
 my @stuff = ($c1h, $p1, $t1);
 getTRP (getTO(getCT($parent)), "", \%mapP, \@stuff);
 getTR (getTO($t1), "", \%map, \@stuff);
 compare (\%map, \@stuff);
 %did = ();
}

#untie %c2p;
#untie %p2c;
#untie %b2c;
#untie %c2f;
for my $sec (0 .. ($sections-1)){
        untie %{$fhos{$sec}};
}




