use strict;
use warnings;

use BSON;
use BSON::Types ':all';
use MongoDB;
use utf8;
no utf8;
use JSON

my $counter = 0;
my $codec = BSON->new;
my @docs;

while (<STDIN>){
  chop ();
  my ($p, $fr, $to, $par, $stars, $forks, $prjs, $numCommits, $numAuth, $blobs, $files, @ext) = split (/;/, $_, -1); 
  my $dstats = "";
  my %stats;
  for my $ee (@ext){
    my ($e, $n) = split(/=/, $ee, -1);
    $e =~ s/TypesSript/TypeScript/;
    $stats{$e} = $n+0;
  }
  if ($#ext >= 0){
    my $bson = $codec->encode_one( \%stats );
    $dstats = $codec->decode_one( $bson );
  }
  $blobs = $blobs ne "" ? $blobs : 0;
  $files = $files ne "" ? $files : 0;
  my $doc = {
    ProjectID => $p,
    NumAuthors => $numAuth+0,
    NumCommits => $numCommits+0,
    NumBlobs => $blobs + 0,
    NumFiles => $files +0,
    EarlistCommitDate => $fr + 0,
    LatestCommitDate => $to + 0,
    CommunitySize => $prjs + 0
  };
  $doc->{FileInfo} = $dstats if ($dstats ne "");
  $doc->{NumStars} = $stars+0 if $stars ne "";
  $doc->{NumForks} = $forks+0 if $forks != 0;
  $doc->{RootFork} = $par if $par ne "";
  push @docs, $doc;
}

my $c = JSON->new;
for my $d (@docs){
  print "".($c->encode( $d ))."\n";
}
