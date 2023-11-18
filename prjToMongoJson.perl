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
for my $ty ("P2tAlPkg", "B2b", "P2A", "P2b", "P2c", "P2f", "P2g", "P2nfb", "P2p", "P2tspan","P2core","P2mnc"){
  my $str = "zcat ../gz/P2summFull.$ty.$v$s.gz|";
  $str = "zcat ../c2fb/${ty}Full$v$s.s|" if $ty =~ /P2tspan/;
  $str = "zcat ../gz/${ty}Full$v$s.s|" if $ty =~ /P2(core|mnc)/;
  open A, $str;
  while (<A>){
    chop(); 
    my ($a, @x) = split (/;/);
    if ($ty eq "P2tspan"){
      $d{$a}{EarliestCommitDate} = $x[0]+0;
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
    if ($ty eq "P2tAlPkg"){
      my $k = shift @x;
      if ($k eq "api"){
        my $l = shift @x;
        #print "$a;$k;$l\n";
        for $k (@x){
          my ($ke, $va) = split (/=/, $k, -1);
          #print "$a;$l:$ke=$va\n";
          $d{$a}{api}{"$l:$ke"} = $va;
        }
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
      $ke = 'NumOriginatingBlobs' if $ke eq "P2nfb";
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
for my $au (keys %d){
  my $doc = {
    ProjectID => $au
  };
  $d{$au}{"NumActiveMon"} = scalar (keys %{$d{$au}{"MonNauth"}});
  for my $f ('NumCommits', "RootFork", 'NumStars', 'NumForks', 'CommunitySize', "NumCore", "NumActiveMon", "NumFiles", "NumBlobs", "NumOriginating", "NumAuthors", "EarliestCommitDate", "LatestCommitDate", "BlobCommunitySize", "BlobParent"){
    if (defined $d{$au}{$f}){
      my $val = $d{$au}{$f};
      $val += 0 if $f =~ /^(Num|CommunitySize)/;
      $doc->{$f} = $val;
    }
  }
  if (defined $d{$au}{Alias}){
    my @as = keys %{$d{$au}{Alias}};
    $doc->{NumAlias} = $#as+1;
    my $bson = $codec->encode( \@as );
    $doc->{Alias} = $codec->decode( $bson );
  }
  my $bson = $codec->encode( \%{$d{$au}{Core}} );
  $doc->{Core} = $codec->decode( $bson );
  my (@ext, %stats);
  for my $f ("Gender","MonNcmt","MonNauth"){ 
    @ext = keys %{$d{$au}{$f}};
    %stats = ();
    for my $ee (@ext){
      $v = $d{$au}{$f}{$ee} + 0;
      $stats{$ee} = $v;
    }
    if ($#ext>=0){
      my $bson = $codec->encode( \%stats );
      $doc->{$f} = $codec->decode( $bson );
    }
  }
  @ext = keys %{$d{$au}{exts}};
  %stats = ();
  for my $ee (@ext){
    $v = $d{$au}{exts}{$ee} + 0;
    $ee =~ s/TypesSript/TypeScript/;
    $stats{$ee} = $v;
  }
  if ($#ext>=0){
    my $bson = $codec->encode( \%stats );
    $doc->{FileInfo} = $codec->decode( $bson );
  }
  @ext = sort { $d{$au}{api}{$b} <=> $d{$au}{api}{$a} } keys %{$d{$au}{api}};
  %stats = ();
  my $napi = 0;
  for my $ee (@ext){
    $v = $d{$au}{api}{$ee} + 0;
    $stats{$ee} = $v;
    last if ($napi++>100);
  }
  if ($#ext>=0){
    my $bson = $codec->encode (\%stats);
    $doc->{ApiInfo} = $codec->decode ($bson);
  }

  print "".($c->encode( $doc ))."\n";
}

