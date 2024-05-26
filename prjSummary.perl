#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
use strict;
use warnings;
use woc;

my $v = $ARGV[0];
my $s = $ARGV[1];
my $type = $ARGV[2];
my $start = defined $ARGV[3] ? $ARGV[3] : "";
my $process = 1;#process input only once after project is encountered
$process = 0 if ($start ne "");
my %d = ();
my $pP = "";
my %tmp = ();
my $cnt = 0;

if ($type eq "B2b"){
  my %Ps;
  open A, "zcat b2BFull.$v.s |";
  while (<A>){
    chop();
    my ($p0, $P) = split (/;/, $_, -1);
    my $ss = sHash ($p0, 32);
    next if $s != $ss;
    $d{P}{$p0} = $P;
    $Ps{$P}{$p0}++;
  }
  open A, "zcat b2BFull.$v.s |";
  while (<A>){
    chop();
    my ($P, $p0) = split (/;/, $_, -1);
    next if !defined $Ps{$P};
    $Ps{$P}{$p0}++;
  }
  for my $p0 (keys %{$d{P}}){
    next if !defined $d{P}{$p0};
    my $P = $d{P}{$p0};
    my @cmnt = keys %{$Ps{$P}};
    next if $#cmnt ==0 && $cmnt[0] eq $p0;
    my $cSize = scalar(@cmnt);
    print "$p0;B=$P;comunity=$cSize\n";
    print "$p0;B2B;".(join ';', @cmnt)."\n" if $cSize <= 100;;
  }
  exit();
}
if ($type eq "P2p"){
  my %ucP;
  open A, "zcat ${type}Full.$v.$s.gz |";
  $cnt = 0;
  while (<A>){
    chop();
    my ($P, $p) = split (/;/, $_, -1);
    $p = lc($p);
    my $P0 = $P;
    $P = lc($P);
    $ucP{$P} = $P0;
    if ($pP ne "" && $pP ne $P){
      $d{ff}{$pP}++; 
      for my $a (keys %tmp){ 
         $d{p2P}{$a} = $pP; 
         $d{ff}{$a}++;
         $d{P2p}{$pP}{$a}++;
         # print STDERR "$a;$pP\n" if $a eq "izio7_ios-messaging-tutorial" || $pP eq "izio7_ios-messaging-tutorial";
      };
      %tmp = ();
    }
    $tmp{$p}++;
    $d{ff}{$P}++;
    $d{ff}{$p}++;
    $pP = $P;
  }
  $d{ff}{$pP}++; 
  for my $a (keys %tmp){  $d{p2P}{$a} = $pP;  $d{ff}{$a}++;$d{P2p}{$pP}{$a}++ };
  %tmp = ();  $pP = "";

  #get forks/stars
  #open A, "zcat ghForkMapR.gz1|";
  #zcat ght.p2pfrk.gz | awk -F\; '{print $1";"$2";"$1";"$2}' | perl ~/lookup/mp.perl 2 p2P$ver.s | perl ~/lookup/mp.perl 3 p2P$ver.s | gzip > ght.p2pP2Pfrk$ver.gz
  open A, "zcat ght.p2pP2Pfrk$v.gz|";
  $cnt = 0;
  while (<A>){
    chop();
    #my ($p, $r, $ps, $rs) = split (/;/, $_, -1);
    my ($p, $r, $P, $R) = split (/;/, $_, -1);
    $P = lc ($P);
    $R = lc ($R);
    #next if !defined $d{ff}{$p} && !defined $d{ff}{$r};
    #print STDERR "debug;$p;$r;$P;$R;$d{p2P}{$P};$d{p2P}{$R}\n" if $P eq "izio7_ios-messaging-tutorial" || $R eq "izio7_ios-messaging-tutorial";      
    if (defined $d{p2P}{$P}){
      $d{parents}{$d{p2P}{$P}}{$r}{$p}++;
      #print STDERR "parents;$p;$r;$P;$R;$d{p2P}{$p}\n";      
    }
    if (defined $d{p2P}{$R}){
      $d{forks}{$d{p2P}{$R}}{$p}++;
      #print STDERR "forks;$p;$r;$P;$R;$d{p2P}{$p}\n";      
    }
  }
  #  zcat ght.watchers.date.gz | perl ~/lookup/mp.perl 0 p2P$ver.s | gzip > ght.P2w$ver.gz
  #  zcat ght.P2wU.gz|awk -F\; '{print $1";"$3";"$2}' |lsort 100G -u -t\; -k1,3 | gzip > ght.P2wU.s
  open A, "zcat ght.P2w$v.s|";
  while (<A>){
    chop();
    my ($p, $u, $dt) = split (/;/, $_, -1);
    $p = lc ($p);
    my $P = defined $d{p2P}{$p} ? $d{p2P}{$p} : $p;
    $d{su}{$P}{$u}++;
  }
  for my $P (keys %{$d{su}}){
    $d{s}{$P} = scalar (keys %{$d{su}{$P}});
  }
  for my $P (keys %{$d{parents}}){
    my @rs = sort { scalar (keys %{$d{parents}{$P}{$b}}) <=> scalar (keys %{$d{parents}{$P}{$a}}) } (keys %{$d{parents}{$P}});
    $d{parent}{$P} = $rs[0];
    print STDERR "parent;$P;@rs\n";
  }
  for my $P (keys %{$d{forks}}){
    $d{fork}{$P} = scalar (keys %{$d{forks}{$P}});
    print STDERR "fork;$P;$d{fork}{$P}\n";
  }      
  for my $p (keys %{$d{P2p}}){
    my $stars = defined $d{s}{$p} ? $d{s}{$p} : "";    
    my $forks = defined $d{fork}{$p} ? $d{fork}{$p} : 0;
    my $parent = defined $d{parent}{$p} ? $d{parent}{$p} : "";
    my $cSize = scalar(keys %{$d{P2p}{$p}});
    $p = $ucP{$p};
    print "$p;par=$parent;star=$stars;frk=$forks;comunity=$cSize\n";
  } 
  print STDERR "done $s Stars\n";
  exit;
}


for my $ty ($type){
  $cnt = 0;
  %tmp = ();
  $pP = "";
  my $pre ="";#P2tAllPkg?
  $pre = "../c2fb/" if $ty =~ /P2[bf]|P2nfb/;
  $pre = "../c2fb/" if $ty =~/P2tAlPkg/;
  my $str = "zcat $pre${ty}Full$v$s.s |";
  $str = 'zcat P2cFull.'.$v.'.{'.$s.",".($s+32).",".($s+64).",".($s+96).'}'.'.s|' if $ty eq "P2c"; 
  open A, $str;
  while (<A>){
    chop ();
    my ($p, $c, @rest) = split (/;/, $_, -1);
    $process = 1 if ($process == 0 && $p eq $start); 
    next if ! $process;
    if ($ty ne "P2nfb" && $pP ne "" && $pP ne $p){
      print "$pP;$ty=".(scalar(keys %tmp))."\n";
      if ($ty eq "P2f"){
        doExt ($pP, \%tmp);
      }
      if ($ty eq "P2tAlPkg"){
        doAPI ($pP, \%tmp);
      }
      doG ($pP, \%tmp) if ($ty eq "P2g");
      %tmp = ();
      print STDERR "$s $ty $cnt prs\n" if (!($cnt++%1000000));
      #last if $cnt > 1000;
    }else{
      if ($ty eq "P2nfb"){
        print "$p;$ty=$c\n";
      }
    }
    if ($ty eq "P2tAlPkg"){
      $tmp{$c}{join ";", @rest}++;
    }else{
      $tmp{$c}++;
    }
    $pP = $p;
  } 

  #$d{$ty}{$pP} = scalar(keys %tmp);
  print "$pP;$ty=".(scalar(keys %tmp))."\n";
  doExt ($pP, \%tmp) if ($ty eq "P2f");
  doG ($pP, \%tmp) if ($ty eq "P2g");
  print STDERR "done $s $ty $cnt\n";
}

sub doG {
  my ($p, $tmp) = @_;
  my @a = keys %$tmp;
  print "$p;Gender";
  for my $i (@a){
    print ";$i=$tmp->{$i}";
  }
  print "\n";
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
     print ";$i=$e{$i}";
     #$d{e}{$p}{$i}=$e{$i}; 
  }
  print "\n";
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

