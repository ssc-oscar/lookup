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
     if ($l =~ m/^tree (.*)$/){
		  $tree = $1;
     } 
     $parent .= ":$1" if ($l =~ m/^parent (.*)$/);
     ($auth, $ta) = ($1, $2) if ($l =~ m/^author (.*)\s([0-9]+\s[\+\-]+\d+)$/);
     ($cmtr, $tc) = ($1, $2) if ($l =~ m/^author (.*)\s([0-9]+\s[\+\-]+\d+)$/);
  }
  $parent =~ s/^:// if defined $parent;
  return ($tree, $parent);
}

my %did = ();
my %didP = ();

my $prev = "";
my $fs="";
while(<STDIN>){
  chop();
  $rev = $_;
  next if length($rev) ne 40;    
  my %map = ();
  my %mapP = ();
  my ($tree, $parent) = getCT ($rev);
  my ($treeP, $parentP) = getCT ($parent);
  getTR (getTO ($tree), "", \%map); 
  getTR (getTO ($treeP), "", \%mapP); 
  separate (\%map, \%mapP);
}

sub separate {
  my ($m, $mP) = @_;
  my (%uM, %uP);
  while (my ($k, $v) = each %{$m}){
	 if (!defined %{$mP->{$k}}){
      $uM{$k} = $v; 
    }else{
		#separate1 ($m->{$k}, $mP->{$k});
    }
  } 
  print "".(sort keys %uM)."\n";
  while (my ($k, $v) = each %{$mP}){
	 if (!defined %{$mP->{$k}}){
      $uP{$k} = $v; 
    }else{
		#separate1 ($m->{$k}, $mP->{$k});
    }
  } 
  print "".(sort keys %uP)."\n";
}

sub getTR {
  my ($to, $prefix, $map) = @_;
  if (length ($to) == 0){
    return "";
  }
  while ($to) {
    if ($to =~ s/^([0-7]+) (.+?)\0(.{20})//s) {
      my ($mode, $name, $bytes) = (oct($1),$2,$3);
      my $nO = $name;
      my $bH = toHex ($bytes);
      print "$mode $prefix/$name $bH\n";
      $map->{"$prefix"}{$nO}{$bH}++;
      if ($mode == 040000){
        #print "got tree: $prefix $bH\n";
        getTR (getTO($bH), "$prefix/$nO", $map);
      }
    }    
  }
}


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



sub compare {
  my ($map, $stuff) = @_;
  while (my ($k, $v) = each %{$map}){
     #print "$k;$v\n";
     if ($k eq "/$v"){
        if (defined $did{$k}){           
        }else{
           if (defined $didP{$k}){
             print "$stuff->[0];$k;$didP{$k};$stuff->[1];deleted\n";
           }else{
             print STDERR "$.;no $k;$stuff->[0];;;$stuff->[1]\n";
           }
        }
     }
  }
}
   
for my $sec (0 .. ($sections-1)){
        untie %{$fhos{$sec}};
}




