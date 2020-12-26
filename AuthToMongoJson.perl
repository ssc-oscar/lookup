use strict;
use warnings;

use BSON;
use BSON::Types ':all';
use MongoDB;
use utf8;
no utf8;
use JSON;

my $counter = 0;
my $codec = BSON->new;
my @docs;

while (<STDIN>){
  chop ();
  my ($p, $fr, $to, $alias, $numCommits, $numProjects, $blobs, $files, @ext) = split (/;/, $_, -1); 
  $numProjects = $numProjects ne "" ? $numProjects : 0;
  $blobs = $blobs ne "" ? $blobs : 0;
  $files = $files ne "" ? $files : 0;
  @as = split (/|/, $alias, -1);
  my $doc = {
    AuthorID => $p,
    NumProjects => $numProjects+0,
    NumCommits => $numCommits+0,
    NumFirstBlobs => $blobs + 0,
    NumFiles => $files + 0,
    EarlistCommitDate => $fr + 0,
    LatestCommitDate => $to + 0,
  };
  if ($#ext >= 0){
    my %stats;
    for my $ee (@ext){
      my ($e, $n) = split(/=/, $ee, -1);
      $e =~ s/TypesSript/TypeScript/;
      $stats{$e} = $n+0;
    }
    my $bson = $codec->encode_one( \%stats );
    $doc->{FileInfo} = $codec->decode_one( $bson );
  }
  if ($#as > 0){
    $doc->{NumAlias} = $#as+1;
    my $bson = $codec->encode_one( \@as );
    $doc->{Alias} = $codec->decode_one( $bson );
  }
  push @docs, $doc;
}

my $c = JSON->new;
for my $d (@docs){
  print "".($c->encode( $d ))."\n";
}


