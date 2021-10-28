use strict;
use warnings;

use utf8;
no utf8;
use JSON;

my $counter = 0;
my @docs;

my $v = $ARGV[0];
my $s = $ARGV[1];
my %d;
my $cnt = 0;
for my $ty ("A2tspan", "A2c","A2a","A2f","A2fb","A2g","A2P","A2mnc"){
  my $str = "zcat ../gz/A2summFull.$ty.$v$s.gz|";
  $str = "zcat ../gz/${ty}FullH$v.$s.gz|" if $ty eq "A2a";
  $str = "zcat ../c2fb/${ty}Full$v$s.s|" if $ty eq "A2tspan";
  $str = "zcat ../gz/${ty}Full$v$s.s|" if $ty eq "A2mnc";
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
    if ($ty eq "A2g"){
      $d{$a}{Gender} = $x[0];
      next;
    }
    if ($ty eq "A2mnc"){
      $d{$a}{MonNprj}{$x[0]} = $x[1];
      $d{$a}{MonNcmt}{$x[0]} = $x[2];
    }
    my $k = shift @x;
    next if !defined $k;
    if ($k =~ /=/){
      $cnt ++ if $ty eq "A2c";
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
#print STDERR "read $cnt\n";
$cnt = 0;
my $cout = JSON->new;
my $codec = JSON->new;
for my $a (keys %d){
  my $doc = {
    AuthorID => $a,
  };
  $d{$a}{"NumActiveMon"} = scalar (keys %{$d{$a}{"MonNprj"}});
  if (!defined $d{$a}{NumCommits}){
    my @k = keys %{$d{$a}};
    print STDERR "$a;@k\n";
    $doc->{NumCommits} = 0;
    next; #ignore author ids who cam from from committer field
  }else{
    $doc->{"NumCommits"} = $d{$a}{NumCommits}+0
  };
  for my $f ("Gender","NumFiles", "NumFirstBlobs", "NumProjects", "NumActiveMon", "EarlistCommitDate", "LatestCommitDate"){
    if (defined $d{$a}{$f}){
      my $val = $d{$a}{$f};
      $val += 0 if $f =~ /^Num/;
      $doc->{$f} = $val;
    }
  }
  if (defined $d{$a}{Alias}){
    my @as = keys %{$d{$a}{Alias}};
    if ($#as > 0){
      $doc->{NumAlias} = $#as+1;
      my $bson = $codec->encode (\@as);
      $doc->{Alias} = $codec->decode ($bson);
    }
  }
  my (@ext, %stats);
  for my $f ("MonNcmt","MonNprj"){
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
  @ext = keys %{$d{$a}{e}};
  %stats = ();
  for my $ee (@ext){
    $v = $d{$a}{e}{$ee} + 0;
    $ee =~ s/TypesSript/TypeScript/;
    $stats{$ee} = $v;
  }
  if ($#ext>=0){
    my $bson = $codec->encode (\%stats);
    $doc->{FileInfo} = $codec->decode ($bson);
  }
  $cnt++;
  print "".($cout ->encode ($doc))."\n";
}
#print STDERR "wrote $cnt\n";
