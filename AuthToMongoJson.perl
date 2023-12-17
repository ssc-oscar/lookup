use strict;
use warnings;

use utf8;
no utf8;
use JSON;

my $counter = 0;
my @docs;

my %fields;
my $v = $ARGV[0];
my $s = $ARGV[1];
my %d;
my $cnt = 0;
for my $ty ("A2tPlPkg", "A2tspan", "A2c","A2a","A2f","A2fb","A2g","A2P","A2mnc"){
  my $str = "zcat ../gz/A2summFull.$ty.$v$s.gz|";
  $str = "zcat ../gz/${ty}FullH$v.$s.gz|" if $ty eq "A2a";
  $str = "zcat ../c2fb/${ty}Full$v$s.s|" if $ty eq "A2tspan";
  $str = "zcat ../gz/${ty}Full$v$s.s|" if $ty eq "A2mnc";
  open A, $str;
  while (<A>){
    chop(); 
    my ($a, @x) = split (/;/);
    if ($ty eq "A2tspan"){
      my $ff = 'EarliestCommitDate';
      $d{$a}{$ff} = $x[0]+0;
      $fields{$ff}++;
      $ff = 'LatestCommitDate';
      $d{$a}{$ff} = $x[1]+0;
      $fields{$ff}++;
      next;
    }
    if ($ty eq "A2a"){
      $d{$a}{Alias}{$x[0]}++;
      next;
    } 
    if ($ty eq "A2g"){
      $d{$a}{Gender} = $x[0];
      $fields{Gender}++;
      next;
    }
    if ($ty eq "A2mnc"){
      $d{$a}{MonNprj}{$x[0]} = $x[1];
      $d{$a}{MonNcmt}{$x[0]} = $x[2];
      next;
    }
    if ($ty eq "A2tPlPkg"){
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
      $cnt ++ if $ty eq "A2c";
      my ($ke, $va) = split (/=/, $k, -1);
      $ke = 'NumCommits' if $ke eq "A2c";
      $ke = 'NumFiles' if $ke eq "A2f";
      $ke = 'NumOriginatingBlobs' if $ke eq "A2fb";
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
$fields{NumCommits}++;
$fields{NumFiles}++;
$fields{NumOriginatingBlobs}++;
$fields{NumCommits}++;
$fields{NumProjects}++;
$fields{NumActiveMon}++;

#print STDERR "read $cnt\n";
$cnt = 0;
my $cout = JSON->new;
my $codec = JSON->new;
for my $au (keys %d){
  my $doc = {
    AuthorID => $au,
  };
  $d{$au}{NumActiveMon} = scalar (keys %{$d{$au}{"MonNprj"}});
  if (!defined $d{$au}{NumCommits}){
    my @k = keys %{$d{$au}};
    #print STDERR "$au;@k\n";
    $doc->{NumCommits} = 0;
    next; #ignore author ids who cam from from committer field
  }else{
    $doc->{"NumCommits"} = $d{$au}{NumCommits}+0
  };
  for my $f (keys %fields){
    if (defined $d{$au}{$f}){
      my $val = $d{$au}{$f};
      $val += 0 if $f =~ /^Num/;
      $doc->{$f} = $val;
    }
  }
  if (defined $d{$au}{Alias}){
    my @as = keys %{$d{$au}{Alias}};
    if ($#as > 0){
      $doc->{NumAlias} = $#as+1;
      my $bson = $codec->encode (\@as);
      $doc->{Alias} = $codec->decode ($bson);
    }
  }
  my (@ext, %stats);
  for my $f ("MonNcmt","MonNprj"){
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
  @ext = keys %{$d{$au}{e}};
  %stats = ();
  for my $ee (@ext){
    $v = $d{$au}{e}{$ee} + 0;
    $ee =~ s/TypesSript/TypeScript/;
    $stats{$ee} = $v;
  }
  if ($#ext>=0){
    my $bson = $codec->encode (\%stats);
    $doc->{FileInfo} = $codec->decode ($bson);
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

  $cnt++;
  print "".($cout ->encode ($doc))."\n";
}
#print STDERR "wrote $cnt\n";
