#!/usr/bin/perl -I /home/audris/lookup -I /home/audris/lib64/perl5 -I /home/audris/lib/x86_64-linux-gnu/perl -I /usr/local/lib64/perl5 -I /usr/local/share/perl5
use strict;
use warnings;
use Error qw(:try);

use TokyoCabinet;
use Compress::LZF;
use cmt;
use MongoDB;
use Devel::Size qw(total_size);

my %badProjectsL = (
  "bb_fusiontestaccount_fuse-2944" => "32400A",
  "bb_fusiontestaccount_fuse1999v2" => "34007A", 
  "octocat_Spoon-Knife" => "forking tutorial, 41176A", 
  "cirosantilli_imagine-all-the-people" => "Commit email scraper, 389993A",
  "marcelstoer_nodemcu-custom-build" => "97994A" ,
  "jasperan_github-utils" => "4394779C", 
  "avsm_ocaml-ci.logs" => "4283368C");
my %badAuthorsL = ( 'one-million-repo <mikigal.acc@gmail.com>' => "1M commits", 
   'scraped_page_archive gem 0.5.0 <scraped_page_archive-0.5.0@scrapers.everypolitician.org>' => "4243985C", 
   'Your Name <you@example.com>' => "1829654C",
   'Auto Pilot <noreply@localhost>' => "2063212C",
   'GitHub Merge Button <merge-button@github.com>' => "109778A",
   '= <=>' => "190490A",
   'greenkeeper[bot] <greenkeeper[bot]@users.noreply.github.com>' => "2067354C", 
   'Google Code Exporter <GoogleCodeExporter@users.noreply.github.com>' => "277+K projects",
   'datakit <datakit@docker.com>' => "4400778 commits" );

my %badCommits = ( "403ae9865be093b23abf36085dcb9bcd8cc4c108" => "head over 8M deep" );

my ($doPrj, $doFiles, $doBlobs) = (1, 1, 1);

$doBlobs = $ARGV[0] if defined $ARGV[0];

my $client = MongoDB::MongoClient->new(host => "mongodb://da1.eecs.utk.edu/");
$client->connect();
my $db = $client->get_database('WoC');
my $col = $client->get_namespace('WoC.users');
my $cursor = $col->find();
my $result = $cursor->result;


# get author ids for each user
my %input;
while ( my $doc = $result->next ) {
  my $a = $doc->{'selectedIds'};
  my $do = 0;
#  $do++ if $doc->{'_id'} eq "5cd48b431b93640143c6edb1";#chris
#  $do++ if $doc->{'_id'} eq "5cd48c101b93640143c6edb2";#marat
#  $do++ if $doc->{'_id'} eq "";#
#  $do++ if $doc->{'_id'} eq "";#
#  $do++ if $doc->{'_id'} eq "";#
#  $do++ if $doc->{'_id'} eq "";#
  $do++ if $doc->{'_id'} eq "5d15fe22c420d377e4fdcd97";#mbernotas
#  $do++ if $doc->{'_id'} eq "5cd9c1bf1b93640143c6edba";# moh
#  $do++ if $doc->{'_id'} eq "5cd9ea8f7e662355ba53e159";# dycz0fx
#  $do++ if $doc->{'_id'} eq "5cee9a305ea3d86976bdce65";# dkennard
#  $do++ if $doc->{'_id'} eq "5ceff9d95ea3d86976bdce66";# eduardo
#  $do++ if $doc->{'_id'} eq "5cd353e5342977bdac3474ad";#audris
#  $do++ if $doc->{'_id'} eq "5cdecf2b8bd70a2d4ad38e02";#drew
#  $do++ if $doc->{'_id'} eq "5cea96251e729cb67f04078c";#dmg
#  $do++ if $doc->{'_id'} eq "5cd9c0561b93640143c6edb8";#rayhan
#  $do++ if $doc->{'_id'} eq "5ceadf772ee50a02198c67dd";# mei
#  $do++ if $doc->{'_id'} eq "5ceb0ba02ee50a02198c67de";# zhu
#  $do++ if $doc->{'_id'} eq "5ceb3d6e2ee50a02198c67df";# zhmh
#  $do++ if $doc->{'_id'} eq "5cec07de5ea3d86976bdce60";# bogdan
#  $do++ if $doc->{'_id'} eq "5cec0c9e5ea3d86976bdce61";# emad
#  $do++ if $doc->{'_id'} eq "5cec22465ea3d86976bdce62";# diomidis 
#  $do++ if $doc->{'_id'} eq "5cec55115ea3d86976bdce64"; #dirk
#  $do++ if $doc->{'_id'} eq "5cec483a5ea3d86976bdce63";#  ahn
  next if $do == 0;
  for my $id (@$a){
    if (ref $id eq "HASH"){
      $input{$doc->{'_id'}}{$id->{id}}++;
      print "$doc->{'_id'};$id->{id}\n";
    }else{
      $input{$doc->{'_id'}}{$id}++;
      print "$doc->{'_id'};$id\n";
    }
  }
  #last;
}

addForks();

my $split = 32;
################
### get torvalds paths for a user
my %a2trp;
{ my $fname = "/fast/a2trpO.tch";
  tie %a2trp, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER | TokyoCabinet::HDB::ONOLCK
  or die "cant open $fname\n";
};
my %a2tr;
for my $u (keys %input){
  my %pa;
  my $cncted = 0;
  for my $id (keys %{$input{$u}}){
    if (defined $a2trp{$id}){
      my $str = safeDecomp($a2trp{$id});
      my @path = ($id, split(/;/, $str));
      $pa{$#path} = join ';', @path;
      $cncted++;
    }
  }
  if ($cncted){
    my $ml = (sort { $a <=> $b } keys %pa)[0];
    $a2tr{$u} = $pa{$ml};
  }
}
untie %a2trp;

################
## get projects for a user
my %a2pF;
for my $sec (0..($split-1)){
  my $fname = "/fast/a2pFullP.$sec.tch";
  tie %{$a2pF{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER | TokyoCabinet::HDB::ONOLCK,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fname\n";
}
my %a2p;
for my $u (keys %input){
  for my $id (keys %{$input{$u}}){
    my $sec = sHash ($id, $split);
    listP ($u, $id, $a2pF{$sec}{$id}, \%a2p) if defined $a2pF{$sec}{$id};
  }
}

#########################
##get all authors for projects user worked on
my %p2aF = ();
for my $sec (0..($split-1)){
  my $fname = "/fast/p2aFullP.$sec.tch";
  tie %{$p2aF{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER | TokyoCabinet::HDB::ONOLCK,
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fname\n";
}
my %gA;
my %p2a;
for my $u (keys %input){
  my @ps = keys %{$a2p{$u}};
  for my $p (@ps){
    next if defined $badProjects{$p};
    my $sec = 0;
    $sec = sHash ($p, $split);
    if (defined $p2aF{$sec}{$p}){
      listP ($u, $p, $p2aF{$sec}{$p}, \%p2a);  
      for my $a (keys %{$p2a{$u}}){
        $gA{$a}{$p}++;
      }
    }
  }
}
for my $a (keys %gA){
  my $sec = sHash ($a, $split);
  if (defined $a2pF{$sec}{$a}){
    for my $p (split(/;/, safeDecomp($a2pF{$sec}{$a}))){
      $gA{$a}{$p}++ if !defined $gA{$a}{$p};
    }
  }
}
for my $sec (0..($split-1)){
  untie %{$p2aF{$sec}};
}
for my $sec (0..($split-1)){
  untie %{$a2pF{$sec}};
}

sub listP {
  my ($u, $p, $v, $res) = @_;
  my $fsn = safeDecomp($v);
  $fsn =~ s/\n//g;
  my @fs = split (/;/,$fsn);
  for my $f (@fs){
    next if defined $badProjects{$f};
    $res ->{$u}{$f}{$p}++;
  }
}

###################
#get commits for a user
my %a2cF = ();
for my $sec (0..($split-1)){
  my $fname = "/fast/a2cFullP.$sec.tch";
  tie %{$a2cF{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER | TokyoCabinet::HDB::ONOLCK,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fname\n";
}
my %a2c;
my %gA2C;
for my $u (keys %input){
  for my $id (keys %{$input{$u}}){
    my $au = $id;
    my $sec = 0;
    $sec = sHash ($au, $split) if $split > 1;
    if (defined $a2cF{$sec}{$au}){
      listB ($u, $au, $a2cF{$sec}{$au}, \%a2c);
      listB ($au, $u, $a2cF{$sec}{$au}, \%gA2C);
    }else{
      print STDERR "no $au in $sec\n";
    }
    #listB ("$u, $p\n", $a2cF{$sec}{"$p\n"}, \%a2c) if defined $a2cF{$sec}{"$p\n"};
  }
}
for my $a (keys %gA){
  my $sec = 0;
  $sec = sHash ($a, $split);
  if (defined $a2cF{$sec}{$a}){
    listB ($a, $a, $a2cF{$sec}{$a}, \%gA2C);
  }
}
for my $sec (0..($split-1)){
  untie %{$a2cF{$sec}};
}

sub listB {
  my ($u, $p, $v, $res) = @_;
  my $ns = length($v)/20;
  for my $i (0..($ns-1)){
    my $c = substr ($v, 20*$i, 20);
    $res ->{$u}{toHex($c)}{$p}++;
  }
}

#######################
#get blobs for a user
my %a2bF;
my %c2b = ();
for my $sec (0..($split-1)){
  my $fname = "/fast/c2bFullO.$sec.tch";
  tie %{$c2b{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER | TokyoCabinet::HDB::ONOLCK,
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fname\n";
}
my %a2b; 
my %c2bG;
for my $u (keys %input){
  my @cs = keys %{$a2c{$u}};
  for my $c1 (@cs){
    my $c = fromHex($c1);
    my $sec = (unpack "C", substr ($c, 0, 1))%$split;
    if (defined $c2b{$sec}{$c}){
      listB ($u, $c, $c2b{$sec}{$c}, \%a2b); 
      listB ($c, $c, $c2b{$sec}{$c}, \%c2bG); 
    }
  }
}
for my $sec (0..($split-1)){
  untie %{$c2b{$sec}};
}

######################
# get files for a user
my %a2fF = ();
for my $sec (0..($split-1)){
  my $fname = "/fast/c2fFullO.$sec.tch";
  tie %{$a2fF{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER | TokyoCabinet::HDB::ONOLCK,
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fname\n";
}
my %a2f;
for my $u (keys %input){
  my @cs = keys %{$a2c{$u}};
  for my $c1 (@cs){
    my $c = fromHex($c1);
    my $sec = (unpack "C", substr ($c, 0, 1))%$split;
    if (defined $a2fF{$sec}{$c}){
      listP ($u, $c, $a2fF{$sec}{$c}, \%a2f);
    }
  }
}
for my $sec (0..($split-1)){
  untie %{$a2fF{$sec}};
}


#########################
#get commits for projects
my %p2c = ();
my %p2nc = ();
for my $sec (0..($split-1)){
  my $fname = "/fast/p2cFullP.$sec.tch";
  tie %{$p2c{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER | TokyoCabinet::HDB::ONOLCK,
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fname\n";
}
my %p2c1;
for my $u (keys %input){
  my @ps = keys %{$a2p{$u}};
  for my $p (@ps){
    my $sec = 0;
    $sec = sHash ($p, $split);
    if (defined $p2c{$sec}{$p}){
      listB ($u, $p, $p2c{$sec}{$p}, \%p2c1);
      listB ($p, $u, $p2c{$sec}{$p}, \%p2nc);
    }
  }
}
for my $sec (0..($split-1)){
  untie %{$p2c{$sec}};
}


my $prof = $client->get_namespace('WoC.profile');
my $PS = $client->get_namespace('WoC.projects');
my $BS = $client->get_namespace('WoC.blobs');
my $AS = $client->get_namespace('WoC.friends');

for my $u (keys %input){
  my %result = ();

  my @as = keys %{$p2a{$u}};  
  my @cs = keys %{$a2c{$u}};
  my @bs = keys %{$a2b{$u}};
  my @fs = keys %{$a2f{$u}};
  my @ps = keys %{$a2p{$u}};
  my (@A, @Af, @P, @Pf, @B, @Bf, %Ti);
 
  my @path = split (/;/, $a2tr{$u}); 
  my @p1 = @path;
  for my $i (1..($#path-1)){ $p1[$i] = toUrl($path[$i]) if $i%2; }
  $result{tridx} = { idx => $#path/2, path => [ @path ], url => [ @p1 ] };

  if ($doPrj){
    my (%clb, %clb1);
    for my $p (@ps){
      for my $au (sort { scalar(keys %{$gA2C{$b}}) <=> scalar(keys %{$gA2C{$a}})  } keys %{$p2a{$u}}){
        # exclude user from her collaborators
        $clb{$au}{$p}++ if defined $p2a{$u}{$au}{$p} && !defined $input{$u}{$au};
        $clb1{$p}{$au}++ if defined $p2a{$u}{$au}{$p} && !defined $input{$u}{$au};
      }
      my $nMyC = 0;
      for my $c (keys %{$a2c{$u}}){
        $nMyC += 1 if defined $p2c1{$u}{$c}{$p};
      }
      my $url = toUrl($p);

      push @P, { name => $p, nC => scalar(keys %{$p2nc{$p}}), nMyC => $nMyC, url => $url } if $#P < 30;
      push @Pf, { name => $p, nC => scalar(keys %{$p2nc{$p}}), nMyC => $nMyC, url => $url };
    }
    $result{projects} =  [ @P ];

    my @topP = sort { scalar(keys %{$clb1{$b}}) <=> scalar(keys %{$clb1{$a}}) } keys %clb1;
    my %lnk = ();
    for my $au (keys %{$input{$u}}){
      $lnk{$au}++ if defined $p2a{$u}{$au}{$topP[0]};
    }
    my @ll = keys %lnk;
    print STDERR "$u project with most collaborators $topP[0]=".(scalar (keys %{$clb1{$topP[0]}}))." link by @ll\n"; 
    print STDERR "$u project with second most collaborators $topP[1]=".(scalar (keys %{$clb1{$topP[1]}}))."\n"; 


    for my $au (sort { scalar (keys $gA2C{$b}) <=> scalar (keys $gA2C{$a}) } keys %clb){
      my @pr;
      my @ppp = keys %{$clb{$au}};
      for my $p (@ppp){
        my $nc = 0;
        my @ccc = keys %{$gA2C{$au}};
        for my $c (@ccc){
          $nc++ if defined $p2nc{$p}{$c};
        }
        my $na = 0;
        my @aaa = keys %{$p2a{$u}};
        #print STDERR "$u;$au;$p;$#ccc;$#aaa;$aaa[0];$#ppp;$ppp[0]\n";
        if ($#aaa < 2000){
          for my $au1 (@aaa){
            $na ++ if defined $p2a{$u}{$au1}{$p} && ! defined $input{$u}{$au1};
          }
        }
        push @pr, { nc => $nc, name => $p, url => toUrl($p), nAuth => $na };
      }
      push @A, { id => $au, projects => [ @pr ] } if $#A < 30;
      push @Af, { id => $au, projects => [ @pr ] };
      next if $#Af > 2000;
    }
    $result{friends} = [ @A ];  
    print STDERR "done Authors $#Af\n";
  }


  if ($doFiles){
    my %F;
    for my $f (@fs){
      my $la = "other";
      $la = "js" if $f =~ /\.(js|iced|liticed|iced.md|coffee|litcoffee|coffee.md|ts|cs|ls|es6|es|jsx|sjs|co|eg|json|json.ls|json5)$/;
      $la = "py" if $f =~ /\.(py|py3|pyx|pyo|pyw|pyc|whl|ipynb)$/;
      $la = "c" if $f =~ /(\.[Cch]|\.cpp|\.hh|\.cc|\.hpp|\.cxx)$/;
      $la = "r" if $f =~ /(\.Rd|\.[Rr]|\.Rprofile|\.RData|\.Rhistory|\.Rproj|^NAMESPACE|^DESCRIPTION|\/NAMESPACE|\/DESCRIPTION)$/;
      $la = "sh" if $f =~ /\.(sh|shell|csh|zsh|bash|pbs|bat|BAT)$/;
      $la = "pl" if $f =~ /\.(pl|PL|pm|pod|perl)$/;
      $la = "html" if $f =~ /\.(html|css)$/;
      $la = "java" if $f =~ /(\.java|\.iml|\.class)$/;
      $la = "scala" if $f =~ /\.scala$/;
      $la = "rust" if $f =~ /\.(rs|rlib|rst)$/;
      $la = "go" if $f =~ /\.go$/;
      $la = "f" if $f =~ /\.(f[hi]|[fF]|[fF]77|[fF]9[0-9]|fortran|forth)$/;
      $la = "rb" if $f =~ /\.(rb|erb|gem|gemspec)$/;
      $la = "php" if $f =~ /\.php$/;
      $la = "cs" if $f =~ /\.cs$/;
      $la = "swift" if $f =~ /\.swift$/;
      $la = "erl" if $f =~ /\.erl/;
      $la = "sql" if $f =~ /\.(sql|sqllite|sqllite3|mysql)$/;
      $la = "lsp" if $f =~ /\.(el|lisp|elc)$/;
      $la = "lua" if $f =~ /\.lua$/;
      $la = "jl" if $f =~ /\.jl$/;
      $la = "obj" if $f =~ /\.(o|a|so|exe|bin)$/;
      $la = "tex" if $f =~ /\.(tex|bib|sty|cls|ttf|TTF)$/;
      $la = "markup" if $f =~ /(\.md|\.html|\.xml|\.css|README|AUTHORS|TODO|CHANGELOG|changelog|ChangeLog|COPYING)$/;
      $la = "build" if $f =~ /(Makefile|Dockerfile|build\.xml|BUILD|\.cmake|Makefile.in|rake|CMakeLists\.txt|\.TXT|\.m4|\.am|vcproj|vcxproj|Imakefile)$/;
      $la = "doc" if $f =~ /\.(txt|ps|eps|pdf|org|pptx|doc|ppt|xls|odp|odf|jpg|JPG|jpeg|png|pgm|gif|tif|tiff)$/;
      my @cs = keys %{$a2f{$u}{$f}};
      #my @ext = split (/\./, $f, -1);
      #$la = $ext[$#ext] if $la eq "other";
      $F{$la} += $#cs + 1;
    }  
    $result{files} = { %F };  
  }

  if ($doBlobs){
    my %c2ta = ();
    my (%c2hF, %b2c);
    for my $sec (0..($split-1)){
      my $fname = "/fast/c2taFullP.$sec.tch";
      tie %{$c2ta{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER | TokyoCabinet::HDB::ONOLCK,
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fname\n";

      $fname = "/fast/c2hFullO.$sec.tch";
      tie %{$c2hF{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER | TokyoCabinet::HDB::ONOLCK,
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fname\n";
      
      $fname = "/fast/b2cFullO.$sec.tch";
      tie %{$b2c{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER | TokyoCabinet::HDB::ONOLCK,
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fname\n";
    }
    my @B;
    my %b2c1;
    my %b2nc;
    my @bs = keys %{$a2b{$u}};
    print "nbs=$#bs\n";
    my $ncs = 0;
    for my $bl (@bs){
      my $s = segH ($bl, $split);
      my $blb = fromHex($bl);
      #print "bl=$bl, s=$s\n";
      if (defined $b2c{$s}{$blb}){
        listB ($bl, $u, $b2c{$s}{$blb}, \%b2c1);
        $ncs += length($b2c{$s}{$blb})/20;
        $b2nc{$bl} = scalar (keys %{$b2c1{$bl}}) + 0;
        #print "$bl;b2nc=$b2nc{$bl}\n";
      }
    }
    print "ncs=$ncs\n";
    #exit();
    #open A, '|ssh da0 "$HOME/lookup/Cmt2BlobShow.perl /data/basemaps/b2cFullM 1 32" > /tmp/zzz1';
    #for my $b (@bs){
    #  print A "$b\n";
    #}
    #close A;
    #print STDERR "ran c2b\n";
    my %b2na;
    my %b2depth;
    #open A, "/tmp/zzz1";
    #while (<A>){
    #  chop();
    #  my ($bl, $nc, @csb) = split (/;/, $_, -1);
    my @nskip = ();
    for my $bl (keys %b2c1){
      my @csb = keys %{$b2c1{$bl}};
      #print "$bl;ncs=$#csb\n";
      if ($#csb > 1000){
        push @nskip, $bl;
        next;
      }
      my %bas = ();
      for my $c (@csb){
        my $s = segH ($c, $split);
        my $cc = fromHex($c); 
        if (defined $c2ta{$s}{$cc}){
          my ($t, $au) = split (/;/, $c2ta{$s}{$cc});
          $bas{$t}{$au} = $c;
          if (defined $c2hF{$s}{$cc}){
            my $depth = unpack "w", substr($c2hF{$s}{$cc}, 20, length($c2hF{$s}{$cc})-20);
            $b2depth{$bl} = $depth if !defined $b2depth{$bl} || $b2depth{$bl} < $depth;
            #print "a $bl;$c;$depth\n";
          }
        }
      }
      my $first = (sort { $a+0 <=> $b+0 } keys %bas)[0];
      my @aa = keys %{$bas{$first}};
      my $own = 0; 
      $own = 1 if defined $input{$u}{$aa[0]};
      if ($own){
        #$b2nc{$bl} = $nc;
        print "$aa[0];$bl\n";
        for my $t (keys %bas){
          my @aa = keys %{$bas{$t}};
          for my $au (@aa){
            if (!defined $input{$u}{$au}){
              my $c = $bas{$t}{$au};
              $b2na{$bl}{$au} = $c;
              my $cc = fromHex ($c);
              my $s0 = segH ($c, $split);
              if (defined $c2hF{$s0}{$cc}){
                my $depth = unpack "w", substr($c2hF{$s0}{$cc}, 20, length($c2hF{$s0}{$cc})-20);
                #print "$bl;$c;$depth\n";
                $b2depth{$bl} = $depth if !defined $b2depth{$bl} || $b2depth{$bl} < $depth;
              }
            }
          } 
        }
        delete $b2nc{$bl} if ! defined $b2depth{$bl} || !defined $b2na{$bl};
        
        #my @zz = keys %{$b2na{$bl}};
        #$b2na{$bl} = \@zz;
      } else {
        delete $b2nc{$bl};
      }
      #print "$own;$bl\;$nc;@aa\n";
    }
    #exit();
    for my $b1 (sort { $b2nc{$b} <=> $b2nc{$a}} (keys %b2nc)){
      my %val;
      for my $au (keys %{$b2na{$b1}}){
        my $c = $b2na{$b1}{$au};
        $val{$c} = $au;
      }
      if (defined $b2depth{$b1}){
        push @B, { blob => $b1, nc => $b2nc{$b1}, depth => $b2depth{$b1}, users => { %val }  } if $#B < 20;
        push @Bf, { blob => $b1, nc => $b2nc{$b1}, depth => $b2depth{$b1}, users => { %val } };
      }
    }
    print STDERR "done Blobs $#Bf, skipped=$#nskip\n";
    $result{blobs} = [ @B ];
    if ($#B < 0){
      undef $result{blobs};
      my @objects = $prof ->find ({ user => $u }) ->all;
      $prof ->update_one ({ user => $u }, { '$unset' => { 'blobs' => 1 } } );
    }
  }

  if ($doPrj && $doFiles && $doBlobs){
    $result{stats} = { NFriends => $#as+1, NCommits => $#cs+1, NBlobs => $#bs+1,  NFiles => $#fs+1, NProjects => $#ps+1 };
  }
  if ($doPrj && $doFiles ){
    $result{stats} = { NFriends => $#as+1, NCommits => $#cs+1, NFiles => $#fs+1, NProjects => $#ps+1 };
  }

  my @objects = $prof ->find ({ user => $u }) ->all;
  if ($#objects >= 0){
    $prof ->update_one ({ user => $u }, { '$set' => { %result } } );
  }else{
    $result{user} = $u;
    $prof ->insert_one ({ %result });
  }
  if ($doPrj && total_size(\@Pf) < 10000000){
    @objects = $PS ->find ({ user => $u }) ->all;
    if ($#objects >= 0){
      $PS ->update_one ({ user => $u }, { '$set' => { projects => [ @Pf ] } });
    }else{
      $PS ->insert_one ({ user => $u, projects => [ @Pf ] });
    }
  }
  if ($doBlobs && total_size(\@Bf) < 10000000){
    @objects = $BS ->find ({ user => $u }) ->all;
    if ($#objects >= 0){
      $BS ->update_one ({ user => $u }, { '$set' => { blobs => [ @Bf ] } });
    }else{
      $BS ->insert_one ({ user => $u, blobs => [ @Bf ] });
    }
  }
  if ($doPrj && total_size(\@Af) < 10000000){ 
    @objects = $AS ->find ({ user => $u }) ->all;
    if ($#objects >= 0){
      $AS ->update_one ({ user => $u }, { '$set' => { friends => [ @Af ] } });
    }else{
      $AS ->insert_one ({ user => $u, friends => [ @Af ] });
    }
  }
  print "$u\;$#ps;$#cs;$#as;$#bs;$#fs\n";
}

