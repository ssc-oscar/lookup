#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
use strict;
use warnings;
use woc;

my $v = $ARGV[0];
my $s = $ARGV[1];
my $fr = 0;
$fr = $ARGV[3] if defined $ARGV[3];
$fr = $fr/2 if $ARGV[2] eq "A2f";

my %d = ();
my $pP = "";
my $pP1 = "";
my %tmp = ();
my $cnt = 0;

for my $ty ($ARGV[2]){
  $cnt = 0;
  %tmp = ();
  $pP = "";
  $pP1 = "";
  my $pre = "";
  $pre = "../c2fb/" if $ty =~/A2[bf]/;
  $pre = "../c2fb/" if $ty =~/A2tPlPkg/;
  open A, "zcat $pre${ty}Full.$v.$s.s |";
  while (<A>){
    chop ();
    my ($p, $c, @rest) = split (/;/, $_, -1);
    if ($fr > 0){
      if ($pP1 ne $p){
        $fr --;
        $p=$pP1;
      }
      next;
    }
    if ($pP ne "" && $pP ne $p){
      if ($fr > 0){
        $fr --;
      }else{
        print "$pP;$ty=".(scalar(keys %tmp))."\n";
        #$d{$ty}{$pP} = scalar(keys %tmp);
        if ($ty eq "A2f"){
          doExt ($pP, \%tmp);
        }
        if ($ty eq "A2tPlPkg"){
          doAPI ($pP, \%tmp);
        }
        %tmp = ();
        print STDERR "$s $ty $cnt\n" if (!($cnt++%500000));
        #last if $cnt > 10000;
      }
    }
    if (! defined $badAuthors{$p}){
      if ($ty eq "A2tPlPkg"){
        $tmp{$c}{join ";", @rest}++; 
      }else{
        $tmp{$c}++;
      }
    }
    $pP = $p;
  }
  print "$pP;$ty=".(scalar(keys %tmp))."\n";
  #$d{$ty}{$pP} = scalar(keys %tmp);
  doExt ($pP, \%tmp) if ($ty eq "A2f");
  doAPI ($pP, \%tmp) if ($ty eq "A2tPllPkg");
  print STDERR "done $s $ty $cnt\n";
}


sub doAPI {
  my ($p, $tmp) = @_;
  my %api;
  for my $t (keys %$tmp){
    for my $v (keys %{$tmp->{$t}}){
      my ($p, $l, @pkg) = split (/;/, $v);
      for my $pk (@pkg){
        $api{$l}{$pk}++;
      }
    }
  }
  for my $i (keys %api){
    print "$p;api;$i";
    for my $v (keys %{$api{$i}}){
      my $v1 = $v;
      $v1 =~ s/=/EQ/g;
      print ";$v1=$api{$i}{$v}";
    }
    print "\n";
  }
}

sub doExt {
  my ($p, $tmp) = @_;
  my @a = keys %$tmp;
  my %e = ();
  for my $fi (@a){ ext ($fi, \%e, $tmp->{$fi}) if $fi ne ""; }
  #my @a = sort { $e{$b} <=> $e{$a} }  keys %e;
  print "$p;exts";
  for my $i (keys %e){
    my $i1 = $i;
    $i1 =~ s/=/EQ/g;
    print ";$i1=$e{$i}";
    #$d{e}{$p}{$i}=$e{$i}; 
  }
  print "\n"
}

sub ext {
  my ($f, $stats) = @_;
  if( $f =~ m/(\.java$|\.iml|\.jar|\.class|\.dpj|\.xrb)$/ ) {$stats->{'Java'}++;}
  elsif( $f =~ m/\.(js|iced|liticed|iced.md|coffee|litcoffee|coffee.md|cs|ls|es6|jsx|sjs|co|eg|json|json.ls|json5)$/ ) {$stats->{'JavaScript'}++;}
  elsif( $f =~ m/\.(py|py3|pyx|pyo|pyw|pyc|whl)$/ ) {$stats->{'Python'}++;}
  elsif( $f =~ m/\.CPP$|\.CXX$|\.cpp$|\.[Cch]$|\.hh$|\.cc$|\.cxx$|\.hpp$|\.hxx$|\.Hxx$|\.HXX$|\.C$|\.c$|\.h$|\.H$/ ) { $stats->{'C/C++'}++; }
  elsif( $f =~ m/\.cs$/ )    {$stats->{'C#'}++;}
  elsif( $f =~ m/\.php$/ )     {$stats->{'PHP'}++;}
  elsif( $f =~ m/\.(rb|erb|gem|gemspec)$/ )    {$stats->{'Ruby'}++;  }
  elsif( $f =~ m/\.go$/ )      {$stats->{'Go'}++;}
  elsif( $f =~ m/\.ipy$/ ) {$stats->{'ipy'}++;}
  elsif( $f =~ m/\.swift$/ )   {$stats->{'Swift'}++;}
  elsif( $f =~ m/\.scala$/ )   {$stats->{'Scala'}++;}
  elsif( $f =~ m/\.(kt|kts|ktm)$/ ) {$stats->{'Kotlin'}++;}
  elsif( $f =~ m/\.(ts|tsx)$/ ) {$stats->{'TypeScript'}++;}
  elsif( $f =~ m/\.dart$/ ) {$stats->{'Dart'}++;}
  elsif( $f =~ m/\.(rs|rlib|rst)$/ )   {$stats->{'Rust'}++;}
  elsif( $f =~ m'./*(\.Rd|\.[Rr]|\.Rprofile|\.Rdata|\.Rhistory|\.Rproj|^NAMESPACE|^DESCRIPTION|/NAMESPACE|/DESCRIPTION)$' )    {$stats->{'R'}++;}
  elsif( $f =~ m/(\.perl|\.pod|\.pl|\.PL|\.pm)$/ ){ $stats->{'Perl'}++; }
  elsif( $f =~ m/\.(f[hi]|[fF]|[fF]77|[fF]9[0-9]|fortran|forth)$/ )    {$stats->{'Fortran'}++;}
  elsif( $f =~ m/\.ad[abs]$/ ) {$stats->{'Ada'}++;}
  elsif( $f =~ m/\.erl$/ )     {$stats->{'Erlang'}++;}
  elsif( $f =~ m/\.lua$/ )     {$stats->{'Lua'}++;}
  elsif( $f =~ m/\.(sql|sqllite|sqllite3|mysql)$/ )    {$stats->{'Sql'}++;}
  elsif( $f =~ m/\.(el|lisp|elc)$/ )   {$stats->{'Lisp'}++;}
  elsif( $f =~ m/\.(fs|fsi|ml|mli|hs|lhs|sml|v)$/ )    {$stats->{'fml'}++;}
  elsif( $f =~ m/\.jl$/ )      {$stats->{'Julia'}++;}   
  elsif( $f =~ m/\.(COB|CBL|PCO|FD|SEL|CPY|cob|cbl|pco|fd|sel|cpy)$/ ) {$stats->{'Cobol'}++;}
  elsif( $f =~ m/\.(cljs|cljc|clj)$/ ) {$stats->{'Clojure'}++;}
  elsif( $f =~ m/\.(aug|mli|ml|aug)$/ ) {$stats->{'OCaml'}++;}
  elsif( $f =~ m/\.(bas|bb|bi|pb)$/ ) {$stats->{'Basic'}++;}
  else {$stats->{'other'}++};
}

