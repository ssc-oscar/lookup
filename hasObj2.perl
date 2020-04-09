#!/usr/bin/perl -I /home/audris/lookup -I /home/audris/lib64/perl5
use strict;
use warnings;
use Compress::LZF ();
use Digest::SHA qw (sha1_hex sha1);
use cmt;

#########################
# create code to versions database
#########################
use TokyoCabinet;

my $sections = 128;

my $fbase = $ARGV[0];
my (%fhv,%fhb, %fhi, %size);
my (%fhos);

my $parts = 1;
my @types = ("tag", "commit");
@types = ($ARGV[0]) if defined $ARGV[0];
for my $type (@types){
  for my $sec (0 .. ($sections-1)){
    my $pre = "/fast";
    $pre = "/fast" if $type eq "tag" || $type eq "commit";
    if ($type ne "tag"){
      tie %{$fhos{$type}{$sec}}, "TokyoCabinet::HDB", "$pre/All.sha1/sha1.${type}_$sec.tch", TokyoCabinet::HDB::OREADER, 
         16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
           or die "cant open $pre/All.sha1/sha1.${type}_$sec.tch\n";
    }
    if ($type eq "tag"){
      tie %{$fhos{$type}{$sec}}, "TokyoCabinet::HDB", "$pre/All.sha1/sha1.${type}_$sec.tch", TokyoCabinet::HDB::OREADER
        or die "cant open $pre/All.sha1/sha1.${type}_$sec.tch\n";
    }
  }
}



while(<STDIN>){
  chop();
  my ($hsha, @rest) = split(/;/);
  my $sec = hex (substr($hsha, 0, 2)) % $sections;
  next if defined $badCmt{$hsha};
  my $sha = fromHex ($hsha);
  my $found = 0;
  for my $typ (@types){
    if (defined $fhos{$typ}{$sec}{$sha}){
      $found = 1; 
      last;
    }
  }
  print "$_\n" if $found == 0;
}
