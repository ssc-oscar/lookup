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
  if (!defined $fhoc{$sec}{$cB}){
	 #print STDERR "no commit $c\n";
    return ("", "");
  }
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

  my ($tree, $parent) = getCT ($rev);
  if ($tree eq ""){
    print STDERR "no commit $rev\n";
    next;
  }
  if (defined $parent && $parent ne ""){
    $parent = substr ($parent, 0, 40); #ignore additional parents
    my ($treeP, $parentP) = getCT ($parent);
    if ($treeP eq ""){
      print STDERR "no parent commit: $parent for $rev\n";
      next;
    }
    separate2T ($rev, $parent, "", $tree, $treeP);
  }else{
    #commit with no parents
  }
}


sub separate2T {
  my ($c, $cP, $pre, $t, $tP) = @_;
  my (%map, %mapI, %mapF, %mapFI);
  my (%mapP, %mapPI, %mapPF, %mapPFI);
    
  print "doing :$pre:$t:$tP\n";
  my $tree = getTO($t);
  my $treeP = getTO($tP);
  if ($tree eq ""){
	 print STDERR "no tree:$t for $c\n";
    return;
  }
  if ($treeP eq ""){
	 print STDERR "no tree:$tP for parent $cP of $c\n";
    return;
  }
  getTR ($tree, \%map, \%mapI, \%mapF, \%mapFI); 
  getTR ($treeP, \%mapP, \%mapPI, \%mapPF, \%mapPFI);  
  while (my ($k, $v) = each %mapF){
    if (!defined $mapPF{$k}){
      my $kH = toHex ($k);
      my @ns = keys %{$v};
      if (defined $mapPFI{$ns[0]}){
		  my @bs = keys %{$mapPFI{$ns[0]}};
        my $bP = toHex ($bs[0]);
        print "$c;$pre/$ns[0];$kH;$bP\n";
      }else{
        #new file
        print "$c;$pre/$ns[0];$kH;\n";
      }
    }else{
      #rename
      my $kH = toHex ($k);
      my @ns = keys %{$v};
      my @nsp = keys %{$mapPF{$k}};
      print "$c;$pre/$ns[0];$kH;$pre/$nsp[0]\n" if $ns[0] ne $nsp[0];
    }
  }
  while (my ($v0, $v) = each %map){
    if (!defined $mapP{$v0}){
      my $v0H = toHex ($v0);     
      my @ns = keys %{$v}; 
      if (defined $mapPI{$ns[0]}){
		  my @bs = keys %{$mapPI{$ns[0]}};
        my $bP = toHex ($bs[0]);
        #print "doing $#ns:$#bs:$pre/$ns[0];$v0H;$bP\n";
        separate2T ($c, $cP, "$pre/$ns[0]", $v0H, $bP);      
	   }else{
        print STDERR "new folder $c;$t;$tP;$pre/$ns[0];$v0H\n",
		  #printTR ($c, "$pre/$ns[0]", getTO ($v0H));
        #new folder? /renamed folder?
		  #print "$pre/$ns[0];$v0H\n";
      }
    }else{
      #potential rename, no need to catch these
    }
  }
}

sub getTR {
  my ($to, $map, $mapI, $mapF, $mapFI) = @_;
  if (length ($to) == 0){
    return "";
  }
  while ($to) {
    if ($to =~ s/^([0-7]+) (.+?)\0(.{20})//s) {
      my ($mode, $name, $bytes) = (oct($1),$2,$3);
      my $nO = $name;
      #my $bH = toHex ($bytes);
      #print "$prefix/$name;$bH;$mode\n";
      if ($mode == 040000){
		  $map->{$bytes}{"$nO"} = $mode;
        $mapI->{"$nO"}{$bytes} = $mode;        
        #print "got tree: $prefix $bH\n";
        #this is where time is sent
        #getTR (getTO($bH), "$prefix/$nO", $map, $map1);
      }else{
		  if ($mode == 0100644){
  		    $mapF->{$bytes}{"$nO"} = $mode;
          $mapFI->{"$nO"}{$bytes} = $mode; 
        }               
	   }
    }    
  }
}

sub printTR {
  my ($c, $to, $prefix) = @_;
  if (length ($to) == 0){
    return "";
  }
  print STDERR "printTR: $c;$prefix\n";
  while ($to) {
    if ($to =~ s/^([0-7]+) (.+?)\0(.{20})//s) {
      my ($mode, $name, $bytes) = (oct($1),$2,$3);
      my $nO = $name;
      my $bH = toHex ($bytes);
      if ($mode == 040000){
        printTR ($c, getTO($bH), "$prefix/$nO");
      }else{        
        print "$c;$prefix/$nO;$bH;\n" if $mode == 0100644;
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




