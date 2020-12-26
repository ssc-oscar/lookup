use strict;
use warnings;

use BSON;
use BSON::Types ':all';
use MongoDB;
use utf8;
no utf8;


my $counter = 0;
my $codec = BSON->new;
my @docs;

my $client = MongoDB::MongoClient->new(host => "mongodb://da1.eecs.utk.edu/");
$client->connect();
my $db = $client->get_database('WoC');
my $col = $db->get_collection('proj_metadata.S');

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
    projectID => $p,
    NumAuthors => $numAuth+0,
    NumCommits => $numCommits+0,
    NumBlobs => $blobs + 0,
    NumFiles => $files +0,
    EarlistCommitDate => $fr + 0,
    LatestCommitDate => $to + 0,
    communitySize => $prjs + 0
  };
  $doc->{FileInfo} = $dstats if ($dstats ne "");
  $doc->{numStars} = $stars+0 if $stars ne "";
  $doc->{numForks} = $forks+0 if $forks != 0;
  $doc->{rootFork} = $par if $par ne "";
  push @docs, $doc;

  $counter++;
  if( $counter > 1000 ) {
    $col->insert_many( \@docs );
    $counter = 0;
    @docs = ();
  }
}
