#!/usr/bin/perl -I /da3_data/lookup -I /home/audris/lib64/perl5
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
use cmt;

#my $prj = "";
my $pre = "/fast";
$pre = $ARGV[0] if defined $ARGV[0];

my $sections = 32;
# need to update the tree_$sec.tch first ... for new data. like update0 and update1...
my (%cc, %pc, %b2c, %b2f, %f2b, %f2c, %c2f, %c2b);

for my $sec (0 .. ($sections-1)){
  tie %{$cc{$sec}}, "TokyoCabinet::HDB", "$pre/c2ccFullP.$sec.tch", TokyoCabinet::HDB::OREADER | TokyoCabinet::HDB::ONOLCK,  
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $pre/c2ccFullP.$sec.tch\n";
  tie %{$b2c{$sec}}, "TokyoCabinet::HDB", "$pre/b2cFullP.$sec.tch", TokyoCabinet::HDB::OREADER | TokyoCabinet::HDB::ONOLCK,  
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $pre/b2cFullP.$sec.tch\n";
  tie %{$b2f{$sec}}, "TokyoCabinet::HDB", "$pre/b2fFullP.$sec.tch", TokyoCabinet::HDB::OREADER | TokyoCabinet::HDB::ONOLCK,  
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $pre/b2fFullP.$sec.tch\n";
  tie %{$pc{$sec}}, "TokyoCabinet::HDB", "$pre/c2pcFullP.$sec.tch", TokyoCabinet::HDB::OREADER | TokyoCabinet::HDB::ONOLCK,  
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $pre/c2pcFullP.$sec.tch\n";
  tie %{$c2b{$sec}}, "TokyoCabinet::HDB", "$pre/c2bFullP.$sec.tch", TokyoCabinet::HDB::OREADER | TokyoCabinet::HDB::ONOLCK,  
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $pre/c2bFullP.$sec.tch\n";
  tie %{$c2f{$sec}}, "TokyoCabinet::HDB", "$pre/c2fFullP.$sec.tch", TokyoCabinet::HDB::OREADER | TokyoCabinet::HDB::ONOLCK,  
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $pre/c2fFullP.$sec.tch\n";
  tie %{$f2b{$sec}}, "TokyoCabinet::HDB", "$pre/f2bFullP.$sec.tch", TokyoCabinet::HDB::OREADER | TokyoCabinet::HDB::ONOLCK,  
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $pre/f2bFullP.$sec.tch\n";
  tie %{$f2c{$sec}}, "TokyoCabinet::HDB", "$pre/f2cFullP.$sec.tch", TokyoCabinet::HDB::OREADER | TokyoCabinet::HDB::ONOLCK,  
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $pre/f2cFullP.$sec.tch\n";
}

sub toArr {
  my $v = $_[0];
  my $n = length($v)/20;
  my @res=();
  for my $i (0..($n-1)){
	  push @res, substr($v, $i*20, 20);
  }
}

sub toArrS {
  my $v = $_[0];
	return split(/;/, safeDecomp ($v), -1);
}

while(<STDIN>){
  chop();
  my $b = $_;
  next if length($b) ne 40; 
  my $bP = toHex ($b);
  my $s = hex (substr($b, 0, 2)) % 32;
	my @cs = toArr ($b2c{$s}{$bP});
	my @fs = toArrS ($b2f{$s}{$bP});
	print "@cs\n";
	print "@fs\n";
} 


for my $sec (0 .. ($sections-1)){
  untie %{$cc{$sec}};
  untie %{$pc{$sec}};
  untie %{$b2c{$sec}};
  untie %{$b2f{$sec}};
  untie %{$f2c{$sec}};
  untie %{$f2b{$sec}};
  untie %{$c2f{$sec}};
  untie %{$c2b{$sec}};
}




