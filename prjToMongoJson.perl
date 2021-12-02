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
for my $ty ("B2b", "P2A", "P2b", "P2c", "P2f", "P2g", "Pnfb", "P2p", "P2tspan","P2core","P2mnc"){
  my $str = "zcat ../gz/P2summFull.$ty.$v$s.gz|";
  $str = "zcat ../c2fb/${ty}Full$v$s.s|" if $ty =~ /P2tspan/;
  $str = "zcat ../gz/${ty}Full$v$s.s|" if $ty =~ /P2(core|mnc)/;
  open A, $str;
  while (<A>){
    chop(); 
    my ($a, @x) = split (/;/);
    if ($ty eq "P2tspan"){
      $d{$a}{EarlistCommitDate} = $x[0]+0;
      $d{$a}{LatestCommitDate} = $x[1]+0;
      next;
    }
    if ($ty eq "P2core"){
      for my $ii (@x){
        $ii =~ s/=([0-9]+)$//;
        my $nc = $1;
        $d{$a}{Core}{$ii} = $nc;
      }
      $d{$a}{NumCore} = $#x+1;
      next;
    }
    if ($ty eq "P2mnc"){
      $d{$a}{MonNauth}{$x[0]} = $x[1];
      $d{$a}{MonNcmt}{$x[0]} = $x[2];
    }
    if ($ty eq "B2b"){
      if ($x[0] eq "B2B"){
        shift @x;
        for my $aa (@x){
          $d{$a}{BlobCommunity}{$aa}++;
        }
      }else{
        for my $k (@x){
          for my $k (@x){
            my ($ke, $va) = split (/=/, $k, -1);
            $ke = "BlobParent" if $ke eq "B";
            $ke = "BlobCommunitySize" if $ke eq "comunity";
            $d{$a}{$ke} = $va if $va ne "";
          }
        }
      }
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
      $ke = 'NumCommits' if $ke eq "P2c";
      $ke = 'NumFiles' if $ke eq "P2f";
      $ke = 'NumBlobs' if $ke eq "P2b";
      $ke = 'NumOriginalBlobs' if $ke eq "Pnfb";
      $ke = 'NumAuthors' if $ke eq "P2A";
      $ke = 'NumWithGender' if $ke eq "P2g";
      $d{$a}{$ke} = $va;
    }else{
      my $k0 = $k;
      for $k (@x){
        my ($ke, $va) = split (/=/, $k, -1);  
        $d{$a}{$k0}{$ke} = $va;
      }
    }
  }
}
my $c = JSON->new;
for my $a (keys %d){
  my $doc = {
    ProjectID => $a
  };
  $d{$a}{"NumActiveMon"} = scalar (keys %{$d{$a}{"MonNauth"}});
  for my $f ('NumCommits', "RootFork", 'NumStars', 'NumForks', 'CommunitySize', "NumCore", "NumActiveMon", "NumFiles", "NumBlobs", "NumOriginalBlobs", "NumAuthors", "EarlistCommitDate", "LatestCommitDate", "BlobCommunitySize", "BlobParent"){
    if (defined $d{$a}{$f}){
      my $val = $d{$a}{$f};
      $val += 0 if $f =~ /^(Num|CommunitySize)/;
      $doc->{$f} = $val;
    }
  }
  if (defined $d{$a}{Alias}){
    my @as = keys %{$d{$a}{Alias}};
    $doc->{NumAlias} = $#as+1;
    my $bson = $codec->encode( \@as );
    $doc->{Alias} = $codec->decode( $bson );
  }
  my $bson = $codec->encode( \%{$d{$a}{Core}} );
  $doc->{Core} = $codec->decode( $bson );
  my (@ext, %stats);
  for my $f ("Gender","MonNcmt","MonNauth"){ 
    @ext = keys %{$d{$a}{$f}};
    %stats = ();
    for my $ee (@ext){
      $v = $d{$a}{$f}{$ee} + 0;
      $stats{$ee} = $v;
    }
    if ($#ext>=0){
      my $bson = $codec->encode( \%stats );
      $doc->{$f} = $codec->decode( $bson );
    }
  }
  @ext = keys %{$d{$a}{exts}};
  %stats = ();
  for my $ee (@ext){
    $v = $d{$a}{exts}{$ee} + 0;
    $ee =~ s/TypesSript/TypeScript/;
    $stats{$ee} = $v;
  }
  if ($#ext>=0){
    my $bson = $codec->encode( \%stats );
    $doc->{FileInfo} = $codec->decode( $bson );
  }
  print "".($c->encode( $doc ))."\n";
}

