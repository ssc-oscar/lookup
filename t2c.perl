#!/usr/bin/perl -I /home/audris/lib64/perl5

use strict;
use warnings;
use Error qw(:try);

use TokyoCabinet;
use Compress::LZF;

sub toHex { 
        return unpack "H*", $_[0]; 
} 

sub fromHex { 
        return pack "H*", $_[0]; 
} 

my $sections = 128;

my $fbase="All.sha1c/commit_";

my (%t2c, %fhoc);

while(<STDIN>){
  chop();
  my $f = $_;
  my %fhos = ();
  tie %fhos, "TokyoCabinet::HDB", "$f", TokyoCabinet::HDB::OREADER,
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $f\n";

  while (my ($sha, $v) = each %fhos){
    my ($tree, $parent, $auth, $cmtr, $ta, $tc, @rest) = extrCmt ($v);
    my $t = fromHex ($tree);
    $t2c{$t}{$sha}++;
  }
  untie %fhos;
}

tie %fhoc, "TokyoCabinet::HDB", "$ARGV[0]", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $ARGV[0]\n";

while (my ($k, $v) = each %t2c){
  my $v1 = join "", (sort keys %{$v});
  $fhoc{$k} = $v1;
}

untie %fhoc;



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

sub extrCmt {
  my $codeC = $_[0];
  my $code = safeDecomp ($codeC);

  my ($tree, $parent, $auth, $cmtr, $ta, $tc) = ("","","","","","");
  my ($pre, @rest) = split(/\n\n/, $code, -1);
  for my $l (split(/\n/, $pre, -1)){
     $tree = $1 if ($l =~ m/^tree (.*)$/);
     $parent .= ":$1" if ($l =~ m/^parent (.*)$/);
     ($auth, $ta) = ($1, $2) if ($l =~ m/^author (.*)\s([0-9]+\s[\+\-]+\d+)$/);
     ($cmtr, $tc) = ($1, $2) if ($l =~ m/^author (.*)\s([0-9]+\s[\+\-]+\d+)$/);
  }
  $parent =~ s/^:// if defined $parent;
  return ($tree, $parent, $auth, $cmtr, $ta, $tc, @rest);
}

