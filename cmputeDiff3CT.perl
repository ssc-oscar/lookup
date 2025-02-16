#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
############
############ See accurate diff ib cmputeDiff.perl
############ this is 40X faster but may miss renamed files under renamrd subflders
############ treating some as adds: see commit 0010db3b9a569500a8974bb680acaad12e72a72b
############ Not clear what git diff does here
############
use strict;
use warnings;
use Compress::LZF;
use Digest::SHA qw (sha1_hex sha1);
use Time::Local;
use cmt;

#########################
# create code to versions database
#########################
use TokyoCabinet;

#sub fromHex { 	return pack "H*", $_[0]; } 

#sub toHex { return unpack "H*", $_[0]; } 

my $rev = "";
#my ($prj, $rev, $tree, $parent, $aname, $cname, $alogin, $clogin, $path, $atime, $ctime, $f, $comment) = ("","","","","","","","","","","","","");
my (%c2p, %p2c, %b2c, %c2f);

#my $prj = "";
my $pre = "/fast/All.sha1c";
my $preO = "/fast/All.sha1o";
$preO = $ARGV[0] if defined $ARGV[0];

my $sections = 128;
# need to update the tree_$sec.tch first ... for new data. like update0 and update1...
my (%fhos);
my (%fhoc);
my (%fhob);
my (%fhocb);

for my $sec (0 .. ($sections-1)){
  tie %{$fhos{$sec}}, "TokyoCabinet::HDB", "$preO/sha1.tree_$sec.tch", TokyoCabinet::HDB::OREADER,  
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "can't open $preO/sha1.tree_$sec.tch\n";
  tie %{$fhoc{$sec}}, "TokyoCabinet::HDB", "$preO/sha1.commit_$sec.tch", TokyoCabinet::HDB::OREADER,  
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "can't open $pre/commit_$sec.tch\n";
  open $fhob{$sec}, "/data/All.blobs/tree_$sec.bin" or die "$!";
  open $fhocb{$sec}, "/data/All.blobs/commit_$sec.bin" or die "$!";
}


sub getCT {
  my $c = $_[0];
  if (!defined getC($c)){
	 #print STDERR "no commit $c\n";
    return ("", "");
  }
  my $code = getC($c);
#my $code = safeDecomp ($codeC, $c);

  my ($tree, $parent, $auth, $cmtr, $ta, $tc) = ("","","","","","");
  my ($preX, @rest) = split(/\n\n/, $code, -1);
  for my $l (split(/\n/, $preX, -1)){
     if ($l =~ m/^tree (.*)$/){
		  $tree = $1;
     } 
     $parent .= "$1" if ($l =~ m/^parent (.*)$/);
  }
  #$parent =~ s/^:// if defined $parent;
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
  if (defined $badCmt{$rev}){
    print STDERR "nasty test commit $rev: ignoring\n";
    next;
  }   	

  my ($tree, $parentFull) = getCT ($rev);
  my $parent = $parentFull;
  if ($tree eq ""){
    print STDERR "no commit for $rev\n";
    next;
  }
  if (defined $parent && $parent ne ""){
    $parent = substr ($parentFull, 0, 40); #ignore additional parents
    my ($treeP, $parentP) = getCT ($parent);
    if ($treeP eq ""){
      print STDERR "no parent commit: $parent for $rev\n";
      # what to do with missing parent commit?
      #printTR ($rev, getTO ($tree), "", 1);
      next;
    }
    if ($treeP eq $tree){
      while (length ($parentFull) > 40){
        $parentFull = substr ($parentFull, 40, length($parentFull)-40);
        $parent = substr ($parentFull, 0, 40);
        ($treeP, $parentP) = getCT ($parent);
        last if ($treeP ne $tree);
      }
      if ($treeP eq $tree){
        print STDERR "identical trees: $tree for $rev and parent $parent\n";
        next;
      }
    }
    separate2T ($rev, $parent, "", $tree, $treeP);
  }else{
    my $msg = "no parent for $rev tree $tree";
    #commit with no parents; added missing created parameter to put blobs in the right column
    my $str = getTO ($tree);
    $msg .=  " no tree $tree" if $str eq "";
    print STDERR "$msg\n";
    printTR ($rev, $str, "", 1);
  }
}

sub treeCnt {
}

sub separate2T {
  my ($c, $cP, $pre, $t, $tP) = @_;
  my (%map, %mapI, %mapF, %mapFI);
  my (%mapP, %mapPI, %mapPF, %mapPFI);
    
  #print "doing :$pre:$t:$tP\n";
  
  my $tree = getTO($t);
  my $treeP = getTO($tP);
  if ($tree eq "" && $t ne "4b825dc642cb6eb9a060e54bf8d69288fbee4904"){
    print STDERR "no tree:$t for $c\n";
    return;
  }
  if ($treeP eq "" && $tP ne "4b825dc642cb6eb9a060e54bf8d69288fbee4904"){
    print STDERR "no tree:$tP for parent $cP for $c\n";
    return;
  }
  getTR ($tree, \%map, \%mapI, \%mapF, \%mapFI); 
  getTR ($treeP, \%mapP, \%mapPI, \%mapPF, \%mapPFI);  
  while (my ($k, $v) = each %mapF){
    if (!defined $mapPF{$k}){
      my $kH = toHex ($k);
      #my @ns = keys %{$v};
      #print STDERR "mfiles @ns in $kH for $c\n" if $#ns > 0;
      for my $n (keys %{$v}){
        if (defined $mapPFI{$n}){
          my $bs = $mapPFI{$n};
          my $bP = toHex ($bs);
          #print STDERR "mblobs $bP in $n for $c\n" if $#bs > 0;
          print "$c;$pre/$n;$kH;$bP\n";
        }else{
          #new file (might be a double)
          print "$c;$pre/$n;$kH;\n";
        }
      }
    }else{
      #rename or clone of preexisting
      my $kH = toHex ($k);
      #my @ns = keys %{$v};
      my @nsp = keys %{$mapPF{$k}};
      #print STDERR "mfilesRename @ns and @nsp in $kH for $c\n" if $#ns >0||$#nsp>0;
      for my $n (keys %{$v}){
        if (!defined $badBlob{$kH}){
          print "$c;$pre/$n;$kH;$pre/@nsp\n" if !defined $mapPF{$k}{$n};
        }else{
          print "$c;$pre/$n;$kH;\n" if !defined $mapPF{$k}{$n};
        }
      }
    }
  }
  while (my ($k, $v) = each %mapPF){
    if (!defined $mapF{$k}){
      my $kH = toHex ($k);
      #my @ns = keys %{$v};
      #print STDERR "mfilesP @ns in $kH\n" if $#ns > 0; 
      for my $n (keys %{$v}){
        if (defined $mapFI{$n}){
          #my @bs = keys %{$mapFI{$ns[0]}};
          #my $bP = toHex ($bs[0]);
          #print STDERR "mblobsP $bP in $ns[0] for $c\n" if $#bs > 0;
          #print "modP;@ns;$c;$pre/$ns[0];$bP;$kH\n";
        }else{
          # deleted  file
          print "$c;$pre/$n;;$kH\n";
        }
      }
    }
  }
  while (my ($v0, $v) = each %map){
    if (!defined $mapP{$v0}){
      my $v0H = toHex ($v0);     
      my @ns = keys %{$v};
      print STDERR "mdir @ns in $c\n" if $#ns > 0;
      for my $n (@ns){ 
        if (defined $mapPI{$n}){
          my $bs = $mapPI{$n};
          my $bP = toHex ($bs);
          #print "doing $#ns:$#bs:$pre/$ns[0];$v0H;$bP\n";
          separate2T ($c, $cP, "$pre/$n", $v0H, $bP);
        }else{
          #print STDERR "new folder $c;$t;$tP;$pre/$ns[0];$v0H\n";
          printTR ($c, getTO ($v0H), "$pre/$n", 1);
          #new folder? /renamed folder?
		    #print "$pre/$ns[0];$v0H\n";
        }
      }
    }else{
      #potential rename, no need to catch these
#     my @ns = keys %{$v};
#     my @ns1 = keys %{$mapP{$v0}};
#     if ($ns1[0] ne $ns[0]){
#       print STDERR "rename $pre;@ns;@ns1;$v0H\n";
#     }

    }
  }
  # handle deleted trees
  while (my ($v0, $v) = each %mapP){
    if (!defined $map{$v0}){
      my $v0H = toHex ($v0);
      my @ns = keys %{$v};
      for my $n (@ns){
        if (!defined $mapI{$n}){
          printTR ($c, getTO ($v0H), "$pre/$n", 0);
          #print STDERR "del tree :$pre/$n:$v0H\n";
        }
      }
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
      $nO =~ s/\r/__CR__/g;
      $nO =~ s/\n/__NEWLINE__/g;
      $nO =~ s/;/SEMICOLON/g;
      my $bH = toHex ($bytes);
      #print "$name;$bH;$mode\n";
      if ($mode == 040000){
		  $map->{$bytes}{"$nO"} = $mode;
        $mapI->{"$nO"} = $bytes;        
        #print "got tree: $prefix $bH\n";
        #this is where time is sent
        #getTR (getTO($bH), "$prefix/$nO", $map, $map1);
      }else{
		  #if ($mode == 0100644){
  		    $mapF->{$bytes}{"$nO"} = $mode;
          $mapFI->{"$nO"} = $bytes; 
        #}               
	   }
    }    
  }
}

sub printTR {
  my ($c, $to, $prefix, $created) = @_;
  if (length ($to) == 0){
    return "";
  }
  #print STDERR "printTR: $c;$prefix\n";
  while ($to) {
    if ($to =~ s/^([0-7]+) (.+?)\0(.{20})//s) {
      my ($mode, $name, $bytes) = (oct($1),$2,$3);
      my $nO = $name;
      $nO =~ s/\r/__CR__/g;
      $nO =~ s/\n/__NEWLINE__/g;
      $nO =~ s/;/SEMICOLON/g;
      my $bH = toHex ($bytes);
      if ($mode == 040000){
        printTR ($c, getTO($bH), "$prefix/$nO", $created);
      }else{        
        if ($created){
          print "$c;$prefix/$nO;$bH;\n";# if $mode == 0100644;
        }else{
          print "$c;$prefix/$nO;;$bH\n";# if $mode == 0100644;
        }
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
  if (!defined $fhos{$sec} || !defined $fhos{$sec}{$tB}){
    print STDERR "no tree $sec $t1\n";
    return "";
  }
  my ($off, $len) = unpack ("w w", $fhos{$sec}{$tB});
  my $f = $fhob{$sec};
  seek ($f, $off, 0);
  #my $curpos = tell($f);
  my $codeC = "";
  my $rl = read ($f, $codeC, $len);
  #print STDERR "tree $t1 $sec $off $len $rl\n";
  if (defined $codeC && length ($codeC) > 0){
    return safeDecomp ($codeC, "tree $t1 $sec $off $len $rl\n");
  }else{
    return "";
  }
}

sub getC {
  my $t1 = $_[0];
  my $sec = hex (substr($t1, 0, 2)) % $sections;
  my $tB = fromHex ($t1);
  if (!defined $fhoc{$sec} || !defined $fhoc{$sec}{$tB}){
    print STDERR "no commit $sec $t1\n";
    return;
  }
  my ($off, $len) = unpack ("w w", $fhoc{$sec}{$tB});
  my $f = $fhocb{$sec};
  seek ($f, $off, 0);
  my $codeC = "";
  my $rl = read ($f, $codeC, $len);
  #print STDERR "commit $sec $t1 $off $len $rl\n";
  if (defined $codeC && length ($codeC) > 0){
    return safeDecomp ($codeC, "commit $sec $t1 $off $len $rl\n");
  }else{
    return;
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
  untie %{$fhoc{$sec}};
}




