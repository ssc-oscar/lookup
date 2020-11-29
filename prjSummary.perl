use strict;
use warnings;

my $v = $ARGV[0];
my $s = $ARGV[1];

my %ff;
for my $ty ("P2f", "P2a", "P2b"){
  open $ff{$ty}, "zcat ${ty}Full$v$s.s|";
}

my $batch = 0;
my %d;
my %pP;
my %L;
#open A, 'lsort 30G -t\; -k1,2 --merge  <(zcat P2cFull'.$v.$s.'.s) <(zcat P2cFull'.$v.($s+32).'.s) <(zcat P2cFull'.$v.($s+64).'.s) <(zcat P2cFull'.$v.($s+96).'.s)|';
#lsort 30G -t\; -k1,2 --merge  <(zcat P2cFullS0.s) <(zcat P2cFullS32.s) <(zcat P2cFullS64.s) <(zcat P2cFullS96.s)
while (<STDIN>){
  chop ();
  #print "$_\n";
  my ($p, $c) = split (/;/, $_, -1);
  $L{P2c} = "$p;$c"; 
  if (defined $pP{P2c} && $pP{P2c} ne $p){
    out ();
    for my $ty ("P2c", "P2f", "P2a", "P2b"){
      $d{$ty} = ();
    }
  }
  $d{P2c}{$c}++;
  $L{P2c} = "";
  $pP{P2c} = $p;
}

out ();

sub out {
  catchUp($pP{P2c}, "P2a");
  catchUp($pP{P2c}, "P2b");
  catchUp($pP{P2c}, "P2f");
  print "$pP{P2c}";
  my @a = keys %{$d{P2c}};
  print ";".scalar(@a);
  @a = keys %{$d{P2a}};
  print ";".scalar(@a);
  @a = keys %{$d{P2b}};
  print ";".scalar(@a);
  @a = keys %{$d{P2f}};
  print ";".scalar(@a);
  my %e = ();
  for my $fi (@a){
	 ext ($f, \%e) if $fi ne "";
  }
  @a = sort { $ext{$b} <=> $ext{$a} }  keys %ext;
  print ";".scalar(@a);
  for my $i (@a){ 
	  print ";$i=$e{$i}";
  }
  print "\n";
}

sub catchUp {
  my ($p, $ty) = @_;
  my $B = $ff{$ty};
  if (! defined $L{$ty}){
    my $l = <$B>;
    chop ($l);
    $L{$ty} = $l;
    my ($pr, $c) = split (/;/, $l, -1);
    my $where = ($pr cmp $p);
    if ($where == 0){
      $d{$ty}{$c}++;
      $L{$ty} = "";
    }
    else{
      if ($where > 0){
        return;
      }else{
        die "$pr $p in $ty\n";
      }
    }
  }else{
    if ($L{$ty} ne ""){
      my ($pr, $c) = split (/;/, $L{$ty}, -1);
      my $where = ($pr cmp $p);
      if ($where == 0){
        $d{$ty}{$c}++;
        $L{$ty} = "";
      }else{
        if ($where > 0){
          return;
        }else{
          die "$pr $p in $ty\n";
        }
      }
    }
  }
  while (<$B>){
    chop ();
    $L{$ty} = $_;
    my ($pr, $c) = split (/;/, $_, -1);
    my $where = ($pr cmp $p);
    if ($where == 0){
      $d{$ty}{$c}++;
      $L{$ty} = "";
    }else{
      if ($where > 0){
        return;
      }else{
        die "$pr $p in $ty\n";
      }
    }
  }
}
sub ext {
  my ($f, $d) = @_;
  %stats = %$d;
  if( $f =~ m/(\.java$|\.iml|\.jar|\.class|\.dpj|\.xrb)$/ ) {$stats{'total_java_files'}++;}
  elsif( $f =~ m/(\.perl|\.pod|\.pl|\.PL|\.pm)$/ ){ $stats{'total_perl_files'}++; }
  elsif( $f =~ m/\.CPP$|\.CXX$|\.cpp$|\.[Cch]$|\.hh$|\.cc$|\.cxx$|\.hpp$|\.hxx$|\.Hxx$|\.HXX$|\.C$|\.c$|\.h$|\.H$/ ) { $stats{'total_c_or_c++_files'}++; }
  elsif( $f =~ m/\.(js|iced|liticed|iced.md|coffee|litcoffee|coffee.md|cs|ls|es6|jsx|sjs|co|eg|json|json.ls|json5)$/ )      {$stats{'total_javascript_files'}++;}
  elsif( $f =~ m/\.(py|py3|pyx|pyo|pyw|pyc|whl)$/ )    {$stats{'total_python_files'}++;}
  elsif( $f =~ m/\.cs$/ )    {$stats{'total_csharp_files'}++;}
  elsif( $f =~ m/\.php$/ )     {$stats{'total_php_files'}++;}
  elsif( $f =~ m/\.(rb|erb|gem|gemspec)$/ )    {$stats{'total_ruby_files'}++;  }
  elsif( $f =~ m/\.go$/ )      {$stats{'total_go_files'}++;}
  elsif( $f =~ m/\.(rs|rlib|rst)$/ )   {$stats{'total_rust_files'}++;}
  elsif( $f =~ m'./*(\.Rd|\.[Rr]|\.Rprofile|\.Rdata|\.Rhistory|\.Rproj|^NAMESPACE|^DESCRIPTION|/NAMESPACE|/DESCRIPTION)$' )    {$stats{'total_r_files'}++;}
  elsif( $f =~ m/\.swift$/ )   {$stats{'total_swift_files'}++;}
  elsif( $f =~ m/\.scala$/ )   {$stats{'total_scala_files'}++;}
  elsif( $f =~ m/\.(f[hi]|[fF]|[fF]77|[fF]9[0-9]|fortran|forth)$/ )    {$stats{'total_fortran_files'}++;}
  elsif( $f =~ m/\.ad[abs]$/ ) {$stats{'total_ada_files'}++;}
  elsif( $f =~ m/\.erl$/ )     {$stats{'total_erlang_files'}++;}
  elsif( $f =~ m/\.lua$/ )     {$stats{'total_lua_files'}++;}
  elsif( $f =~ m/\.(sql|sqllite|sqllite3|mysql)$/ )    {$stats{'total_sql_files'}++;}
  elsif( $f =~ m/\.(el|lisp|elc)$/ )   {$stats{'total_lisp_files'}++;}
  elsif( $f =~ m/\.(fs|fsi|ml|mli|hs|lhs|sml|v)$/ )    {$stats{'total_fml_files'}++;}
  elsif( $f =~ m/\.jl$/ )      {$stats{'total_jl_files'}++;}   
  elsif( $f =~ m/\.(COB|CBL|PCO|FD|SEL|CPY|cob|cbl|pco|fd|sel|cpy)$/ ) {$stats{'total_cob_files'}++;}
  elsif( $f =~ m/\.(kt|kts|ktm)$/ ) {$stats{'total_kotlin_files'}++;}
  elsif( $f =~ m/\.(ts|tsx)$/ ) {$stats{'total_typescript_files'}++;}
  elsif( $f =~ m/\.dart$/ ) {$stats{'total_dart_files'}++;}
  elsif( $f =~ m/\.(cljs|cljc|clj)$/ ) {$stats{'total_clojure_files'}++;}
  elsif( $f =~ m/\.(aug|mli|ml|aug)$/ ) {$stats{'total_ocaml_files'}++;}
  elsif( $f =~ m/\.(bas|bb|bi|pb)$/ ) {$stats{'total_basic_files'}++;}
  elsif( $f =~ m/\.ipy$/ ) {$stats{'total_ipy_files'}++;}
  else {$stats{'total_other_files'}++;
}

