use strict;
use warnings;

use utf8;
no utf8;
use JSON;

my $counter = 0;
my $codec = JSON->new;
my @docs;

my $v = $ARGV[0];
my $s = $ARGV[1];
my %d;
for my $ty ("P2tspan", "P2c","P2A","P2f","P2b","P2p"){
  my $str = "zcat P2summFull.$ty.$v$s.gz|";
  $str = "zcat ${ty}Full$v$s.gz|" if $ty eq "P2tspan";
  open A, $str;
  while (<A>){
    chop(); 
    my ($a, @x) = split (/;/);
    if ($ty eq "P2tspan"){
      $d{$a}{EarlistCommitDate} = $x[0]+0;
      $d{$a}{LatestCommitDate} = $x[1]+0;
      next;
    }
    #par=VictorFursa_simple_php_framework;star=;frk=0;comunity=2
    if ($ty eq "P2p"){
      for my $k (@x){
        my ($ke, $va) = split (/=/, $k, -1);
        $ke = "RootFork" if $ke eq "par";
        $ke = 'NumStars' if $ke eq "star";
        $ke = 'NumForks' if $ke eq "frk";
        $ke = 'CommunitySize' if $ke eq "comunity";
        $d{$a}{$ke} = $va if $va ne "";
      }
      next;
    } 
    my $k = shift @x;
    next if !defined $k;
    if ($k =~ /=/){
      my ($ke, $va) = split (/=/, $k, -1);
      $ke = 'NumCommits' if $ke eq "A2c";
      $ke = 'NumFiles' if $ke eq "A2f";
      $ke = 'NumBlobs' if $ke eq "A2fb";
      $ke = 'NumAuthors' if $ke eq "A2P";
      $d{$a}{$ke} = $va;
    }else{
      for $k (@x){
        my ($ke, $va) = split (/=/, $k, -1);  
        $d{$a}{e}{$ke} = $va;
      }
    }
  }
}
my $c = JSON->new;
for my $a (keys %d){
  my $doc = {
    ProjectID => $a
  };
  for my $f ('NumCommits', "RootFork", 'NumStars', 'NumForks', 'CommunitySize', "NumFiles", "NumBlobs", "NumAuthors", "EarlistCommitDate", "LatestCommitDate"){
    if (defined $d{$a}{$f}){
      my $val = $d{$a}{$f};
      $val += 0 if $f =~ /^Num/;
      $doc->{$f} = $val;
    }
  }
  if (defined $d{$a}{Alias}){
    my @as = keys %{$d{$a}{Alias}};
    $doc->{NumAlias} = $#as+1;
    my $bson = $codec->encode( \@as );
    $doc->{Alias} = $codec->decode( $bson );
  }
  my @ext = keys %{$d{$a}{e}};
  my %stats = ();
  for my $ee (@ext){
    $v = $d{$a}{e}{$ee} + 0;
    $ee =~ s/TypesSript/TypeScript/;
    $stats{$ee} = $v;
  }
  if ($#ext>=0){
    my $bson = $codec->encode( \%stats );
    $doc->{FileInfo} = $codec->decode( $bson );
  }
  print "".($c->encode( $doc ))."\n";
}

