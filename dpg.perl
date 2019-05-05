#!/usr/bin/perl -I /home/audris/lookup -I /home/audris/lib64/perl5 -I /home/audris/lib/x86_64-linux-gnu/perl -I /usr/local/lib64/perl5 -I /usr/local/share/perl5
use strict;
use warnings;
use Error qw(:try);

use TokyoCabinet;
use Compress::LZF;
use cmt;
use MongoDB;
use Devel::Size qw(total_size);

my %badProjects = ( "octocat_Spoon-Knife" => "forking tutorial", "cirosantilli_imagine-all-the-people" => "Commit email scraper" );

my $doBlob = 0;
$doBlob = $ARGV[0] if defined $ARGV[0];

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
  for my $id (@$a){
    $input{$doc->{'_id'}}{$id}++;
    print "$doc->{'_id'};$id\n";
  }
}

my $split = 32;

################
## get projects for a user
my %p2c;
for my $sec (0..($split-1)){
  my $fname = "/fast/a2pO.$sec.tch";
  tie %{$p2c{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fname\n";
}
my %a2p;
for my $u (keys %input){
  for my $id (keys %{$input{$u}}){
    my $sec = sHash ($id, $split);
    listP ($u, $id, $p2c{$sec}{$id}, \%a2p) if defined $p2c{$sec}{$id};
  }
}
for my $sec (0..($split-1)){
  untie %{$p2c{$sec}};
}

#########################
##get all authors for projects user worked on
%p2c = ();
for my $sec (0..($split-1)){
  my $fname = "/fast/p2aO.$sec.tch";
  tie %{$p2c{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER,
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
    if (defined $p2c{$sec}{$p}){
      listP ($u, $p, $p2c{$sec}{$p}, \%p2a);
    
  
      for my $a (keys %{$p2a{$u}}){
        $gA{$a}{$p}++;
      }
    }
  }
}
for my $sec (0..($split-1)){
  untie %{$p2c{$sec}};
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
%p2c = ();
for my $sec (0..($split-1)){
  my $fname = "/fast/a2cFullO.$sec.tch";
  tie %{$p2c{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fname\n";
}
my %a2c;
my %gA2C;
for my $u (keys %input){
  for my $id (keys %{$input{$u}}){
    my $p = $id;
    my $sec = 0;
    $sec = sHash ($p, $split) if $split > 1;
    if (defined $p2c{$sec}{$p}){
      listB ($u, $p, $p2c{$sec}{$p}, \%a2c);
    }else{
      print STDERR "no $p in $sec\n";
    }
    #listB ("$u, $p\n", $p2c{$sec}{"$p\n"}, \%a2c) if defined $p2c{$sec}{"$p\n"};
  }
}
for my $a (keys %gA){
  my $p = $a;
  my $sec = 0;
  $sec = sHash ($p, $split);
  if (defined $p2c{$sec}{$p}){
    listB ($p, $p, $p2c{$sec}{$p}, \%gA2C);
  }
}
for my $sec (0..($split-1)){
  untie %{$p2c{$sec}};
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
%p2c = ();
for my $sec (0..($split-1)){
  my $fname = "/fast/c2bFullM.$sec.tch";
  tie %{$p2c{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER,
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fname\n";
}
my %a2b; 
for my $u (keys %input){
  my @cs = keys %{$a2c{$u}};
  for my $c1 (@cs){
    my $c = fromHex($c1);
    my $sec = (unpack "C", substr ($c, 0, 1))%$split;
    if (defined $p2c{$sec}{$c}){
      listB ($u, $c, $p2c{$sec}{$c}, \%a2b); 
    }
  }
}
for my $sec (0..($split-1)){
  untie %{$p2c{$sec}};
}

######################
# get files for a user
%p2c = ();
for my $sec (0..($split-1)){
  my $fname = "/fast/c2fFullM.$sec.tch";
  tie %{$p2c{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER,
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fname\n";
}
my %a2f;
for my $u (keys %input){
  my @cs = keys %{$a2c{$u}};
  for my $c1 (@cs){
    my $c = fromHex($c1);
    my $sec = (unpack "C", substr ($c, 0, 1))%$split;
    if (defined $p2c{$sec}{$c}){
      listP ($u, $c, $p2c{$sec}{$c}, \%a2f);
    }
  }
}
for my $sec (0..($split-1)){
  untie %{$p2c{$sec}};
}


#########################
#get commits for projects
%p2c = ();
my %p2nc = ();
for my $sec (0..($split-1)){
  my $fname = "/fast/p2cFullO.$sec.tch";
  tie %{$p2c{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER,
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
  my (@A, @Af, @P, @Pf, @B, @Bf); 
  my (%clb, %clb1);
  for my $p (@ps){
    for my $au (sort { scalar(keys %{$p2nc{$b}}) <=> scalar(keys %{$p2nc{$a}})  } keys %{$p2a{$u}}){
      # exclude user from her collaborators
      $clb{$au}{$p}++ if defined $p2a{$u}{$au}{$p} && !defined $input{$u}{$au};
      $clb1{$p}{$au}++ if defined $p2a{$u}{$au}{$p} && !defined $input{$u}{$au};
    }
    my $nMyC = 0;
    for my $c (keys %{$a2c{$u}}){
      $nMyC += 1 if defined $p2c1{$u}{$c}{$p};
    }
    my $url = $p;
    $url =~ s/^bb_/bitbucket.org_/;
    $url =~ s|^bitbucket.org_|bitbucket.org/|;
    $url =~ s|_|/|;
    $url = "github.com/$url" if $url !~ m|^bitbucket\.org|;

    push @P, { name => $p, nC => scalar(keys %{$p2nc{$p}}), nMyC => $nMyC, url => "https://$url" } if $#P < 30;
    push @Pf, { name => $p, nC => scalar(keys %{$p2nc{$p}}), nMyC => $nMyC, url => "https://$url" };
    #push @P, { name => $p, nMyC => $nMyC, url => "https://$url" };
  }
  $result{projects} =  [ @P ];
  print STDERR "done Projects $#Pf\n";
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
      push @pr, { nc => $nc, name => $p, nAuth => $na };
    }
    push @A, { id => $au, projects => [ @pr ] } if $#A < 30;
    push @Af, { id => $au, projects => [ @pr ] };
    next if $#Af > 2000;
  }
  $result{friends} = [ @A ];  
  print STDERR "done Authors $#Af\n";

  my %F;
  for my $f (@fs){
    my $la = "other";
    $la = "js" if $f =~ /\.(js|iced|liticed|iced.md|coffee|litcoffee|coffee.md|ts|cs|ls|es6|es|jsx|sjs|co|eg|json|json.ls|json5)$/;
    $la = "py" if $f =~ /\.(py|py3|pyx|pyo|pyw|pyc|whl)$/;
    $la = "c" if $f =~ /(\.[Cch]|\.cpp|\.hh|\.cc|\.hpp|\.cxx)$/;
    $la = "r" if $f =~ /(\.Rd|\.[Rr]|\.Rprofile|\.RData|\.Rhistory|\.Rproj|^NAMESPACE|^DESCRIPTION|\/NAMESPACE|\/DESCRIPTION)$/;
    $la = "sh" if $f =~ /\.(sh|shell|csh|zsh|bash)$/;
    $la = "pl" if $f =~ /\.(pl|PL|pm|pod|perl)$/;
    $la = "html" if $f =~ /\.(html|css)$/;
    $la = "java" if $f =~ /(\.java|\.iml|\.class)$/;
    my @cs = keys %{$a2f{$u}{$f}};
    $F{$la} += $#cs + 1;
  }  

  $result{files} = { %F };  
  

  if ($doBlob){
    my @B;
    my @bs = keys %{$a2b{$u}};
    open A, '|ssh da0 "$HOME/lookup/Cmt2BlobShow.perl /data/basemaps/b2cFullM 0 32" > /tmp/zzz';
    for my $b (@bs){
      print A "$b\n";
    }
    close A;
    print STDERR "ran c2b\n";
    my %b2nc;
    open A, "/tmp/zzz";
    while (<A>){
      chop();
      my ($b, $nc, @csb) = split (/;/, $_, -1);
      $b2nc{$b} = $nc;
      #print "$b\;$nc\n";
    } 
    for my $b1 (sort {$b2nc{$b} <=> $b2nc{$a}} (keys %b2nc)){
      push @B, { blob => $b1, nc => $b2nc{$b1} } if $#B < 20;
      push @Bf, { blob => $b1, nc => $b2nc{$b1} };
    }
    print STDERR "done Blobs $#Bf\n";
    $result{blobs} = [ @B ];
  }
  $result{stats} = { NFriends => $#as+1, NCommits => $#cs+1, NBlobs => $#bs+1, NFiles => $#fs+1, NProjects => $#fs+1 };
  my @objects = $prof ->find ({ user => $u }) ->all;
  if ($#objects >= 0){
    $prof ->update_one ({ user => $u }, { '$set' => { %result } } );
  }else{
    $result{user} = $u;
    $prof ->insert_one ({ %result });
  }
  if (total_size(\@Pf) < 10000000){
    @objects = $PS ->find ({ user => $u }) ->all;
    if ($#objects >= 0){
      $PS ->update_one ({ user => $u }, { '$set' => { projects => [ @Pf ] } });
    }else{
      $PS ->insert_one ({ user => $u, projects => [ @Pf ] });
    }
  }
  if (total_size(\@Bf) < 10000000){
    @objects = $BS ->find ({ user => $u }) ->all;
    if ($#objects >= 0){
      $BS ->update_one ({ user => $u }, { '$set' => { blobs => [ @Bf ] } });
    }else{
      $BS ->insert_one ({ user => $u, blobs => [ @Bf ] });
    }
  }
  if (total_size(\@Af) < 10000000){ 
    @objects = $AS ->find ({ user => $u }) ->all;
    if ($#objects >= 0){
      $AS ->update_one ({ user => $u }, { '$set' => { friends => [ @Af ] } });
    }else{
      $AS ->insert_one ({ user => $u, friends => [ @Af ] });
    }
  }
  print "$u\;$#ps;$#cs;$#as;$#bs;$#fs\n";
}

