use strict;
use warnings;

my $v = $ARGV[0];
my $s = $ARGV[1];
my $type = $ARGV[2];
my %d = ();
my $pP = "";
my %tmp = ();
my $cnt = 0;


if ($type eq "P2p"){
  open A, "zcat ${type}Full$v.$s.gz |";
  $cnt = 0;
  while (<A>){
    my ($p, $c) = split (/;/, $_, -1);
    if ($pP ne "" && $pP ne $p){
      $d{ff}{$pP}++; for my $a (keys %tmp){ $d{p2P}{$a} = $pP; $d{ff}{$a}++;$d{P2p}{$pP}{$a}++ };
      %tmp = ();
    }
    $tmp{$c}++;
    $pP = $p;
  }
  $d{ff}{$pP}++; for my $a (keys %tmp){  $d{p2P}{$a} = $pP;  $d{ff}{$a}++;$d{P2p}{$pP}{$a}++ };
  %tmp = ();  $pP = "";

  #get forks/stars
  open A, "zcat ghForkMapR.gz1|";
  $cnt = 0;
  while (<A>){
    chop();
    my ($p, $r, $ps, $rs) = split (/;/, $_, -1);
    next if !defined $d{ff}{$p} && !defined $d{ff}{$r};
    if (defined $d{P2p}{$r}){
      my $star = $rs eq "" ? $ps : $rs;
      $d{s}{$r} = $star if ($star ne "");
      $d{f}{$r}{$p}++;
    }elsif (defined $d{P2p}{$p}){
      my $star = $rs eq "" ? $ps : $rs;
      $d{parent}{$p} = $r;
      $d{s}{$p} = $star if ($star ne "" && (!defined $d{s}{$p} || $d{s}{$p} < $star)); # select the largest star from the group
    }elsif (defined $d{ff}{$p}){
      my $star = $rs eq "" ? $ps : $rs;
      $d{parent}{$d{p2P}{$p}} = $r;
      $d{s}{$d{p2P}{$p}} = $star if ($star ne "" && (!defined $d{s}{$d{p2P}{$p}} || $d{s}{$d{p2P}{$p}} < $star)); # select the largest star from the group
    }
  }
  for my $p (keys %{$d{P2p}}){
    my $stars = defined $d{s}{$p} ? $d{s}{$p} : "";
    my $forks = defined $d{f}{$p} ? scalar (keys %{$d{f}{$p}}) : 0;
    my $parent = defined $d{parent}{$p} ? $d{parent}{$p} : "";
    my $cSize = scalar(keys %{$d{P2p}{$p}});
    print "$p;par=$parent;star=$stars;frk=$forks;comunity=$cSize\n";
  } 
  print STDERR "done $s Stars\n";
  exit;
}


for my $ty ($type){
  $cnt = 0;
  %tmp = ();
  $pP = "";
  my $pre ="";
  $pre = "../c2fb/" if $ty =~ /P2[bf]/;
  my $str = "zcat $pre${ty}Full$v$s.s |";
  $str = 'zcat P2cFull'.$v.'{'.$s.",".($s+32).",".($s+64).",".($s+96).'}'.'.s|' if $ty eq "P2c"; 
  open A, $str;
  while (<A>){
    chop ();
    my ($p, $c) = split (/;/, $_, -1);
    if ($pP ne "" && $pP ne $p){
      #$d{$ty}{$pP} = scalar(keys %tmp);
      print "$pP;$ty=".(scalar(keys %tmp))."\n";
      if ($ty eq "P2f"){
        doExt ($pP, \%tmp);
      }
      %tmp = ();
      print STDERR "$s $ty $cnt prs\n" if (!($cnt++%1000000));
      #last if $cnt > 1000;
    }
    $tmp{$c}++;
    $pP = $p;
  }
  #$d{$ty}{$pP} = scalar(keys %tmp);
  print "$pP;$ty=".(scalar(keys %tmp))."\n";
  doExt ($pP, \%tmp) if ($ty eq "P2f");
  print STDERR "done $s $ty $cnt\n";
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

