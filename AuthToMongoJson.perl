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
for my $ty ("A2tspan", "A2c","A2a","A2f","A2fb","A2P"){
  my $str = "zcat A2summFull.$ty.$v$s.gz|";
  $str = "zcat ${ty}FullH$v.$s.gz|" if $ty eq "A2a";
  $str = "zcat ${ty}Full$v$s.gz|" if $ty eq "A2tspan";
  open A, $str;
  while (<A>){
    chop(); 
    my ($a, @x) = split (/;/);
    if ($ty eq "A2tspan"){
      $d{$a}{EarlistCommitDate} = $x[0]+0;
      $d{$a}{LatestCommitDate} = $x[1]+0;
      next;
    }
    if ($ty eq "A2a"){
      $d{$a}{Alias}{$x[0]}++;
      next;
    } 
    my $k = shift @x;
    next if !defined $k;
    if ($k =~ /=/){
      my ($ke, $va) = split (/=/, $k, -1);
      $ke = 'NumCommits' if $ke eq "A2c";
      $ke = 'NumFiles' if $ke eq "A2f";
      $ke = 'NumFirstBlobs' if $ke eq "A2fb";
      $ke = 'NumProjects' if $ke eq "A2P";
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
    AuthorID => $a,
    NumCommits => $d{$a}{NumCommits}+0
  };
  for my $f ("NumFiles", "NumFirstBlobs", "NumProjects", "EarlistCommitDate", "LatestCommitDate"){
    if (defined $d{$a}{$f}){
      my $val = $d{$a}{$f};
      $val += 0 if $f =~ /^Num/;
      $doc->{$f} = $val;
    }
  }
  if (defined $d{$a}{Alias}){
    my @as = keys %{$d{$a}{Alias}};
    next if $#as <= 0;
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

