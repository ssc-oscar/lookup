package woc;
use strict;
use warnings;
use Compress::LZF;
use TokyoCabinet;
use Digest::FNV::XS;
use MIME::Base64;

require Exporter;
our @ISA = qw (Exporter);
our @EXPORT = qw(toUrl segB segH sHash sHashV toHex fromHex safeDecomp safeComp simpEmail getFL parseAuthorId
		splitSignature signature_error contains_angle_brackets extract_trimmed git_signature_parse extrCmt getTime cleanCmt	
		addForks %badProjects %badAuthors %badCmt %badBlob %badTree %largeBlobPrj %largeTreePrj);
use vars qw(@ISA);

# basic utilities

# obsolete
my %toUrlMap = ("bb" => "bitbucket.org","gl" => "gitlab.org",
"android.googlesource.com" => "android.googlesource.com",
"bioconductor.org" => "bioconductor.org",
"drupal.com" => "git.drupal.org", "git.eclipse.org" => "git.eclipse.org",
"git.kernel.org" => "git.kernel.org/pub/scm/",
"git.postgresql.org" => "git.postgresql.org" ,
"git.savannah.gnu.org" => "git.savannah.gnu.org",
"git.zx2c4.com" => "git.zx2c4.com" ,
"gitlab.gnome.org" => "gitlab.gnome.org",
"kde.org" => "anongit.kde.org",
"repo.or.cz" => "repo.or.cz",
"salsa.debian.org" => "salsa.debian.org", 
		"sourceforge.net" => "git.code.sf.net/p"
    # "git.kernel.org" => "git.kernel.org/pub/scm/",
    );

sub toUrl {
  my $in = $_[0];
  my $found = 0;
  for my $p (keys %toUrlMap){
    if ($in =~ /^${p}_/ && (scalar(split(/_/, $in)) > 2 || $p eq "sourceforge.net")){
      $in =~ s|^${p}_|$toUrlMap{$p}\/|;
      $found ++;
      last;
    }
  }  
  $in =~ s|^|github.com/| if (!$found);
  $in =~ s|_|/|;
  return "https://$in";
}

sub getFL {
  my $a = $_[0];
  my $a0 = $a;
  $a =~ s/\s+\<.*//;
  if ($a =~ /([a-zA-Z0-9_\.]+@[a-zA-Z0-9]+\.[a-z]+)/){#has email in the name space
    my $e0 = $1;
    my $e = $e0;
    $e0 =~ s/@.*//;
    $e0 =~ s|^["\s\{\}\(\)\r#!%\$'/\&\*\+]*||;
    $e0 =~  s|["\s\{\}\(\)\r#!%\$'/\&\*\+]*$||;
    $e0 =~ s|([a-z])([A-Z])([A-Z])|$1.$2.$3|g; #Camelback
    $e0 =~ s|([a-z])([A-Z])|$1.$2|g; #Camelback
    my @as1 = split (/[\._\-]/, $e0);
    if ($#as1 > 1){ #use names derived from email
      return "$as1[0] $as1[$#as1]";
    }else{
      #remove email
      $a =~ s/$e0//;
    }
  }
  $a =~ s|^["\s\{\}\(\)\r#!%\$'/\&\*\+\.\-@]*||;
  $a =~  s|["\s\{\}\(\)\r#!%\$'/\&\*\+\.\-@]*$||;
  $a =~ s|[\.,\-\s]+| |g;
  $a =~ s|([a-z])([A-Z])([A-Z])|$1 $2 $3|g; #Camelback
  $a =~ s|([a-z])([A-Z])|$1 $2|g; #Camelback
  $a =~ s|\bMc ([A-Z])|Mc$1|;
  $a =~ tr/[A-Z]/[a-z]/;
  $a =~ s/^\s*$//;
  $a =~ s/^[0-9]*$//;
  if ($a ne ""){
    #print STDERR "here0;$a;\n";
    my @as=split(/ /,$a);
    pop @as if ($#as > 1 && $as[$#as] =~ m/^([iv]|[iv][iv]|ii[iv]|vii|jr|sr|phd|md|dds)$/);
    #print STDERR "here0:$a:$a0\n";
    return "$as[0] $as[$#as]" if $#as > 0;
    # handle singleword concatenated firstlast names in the future
    return "$as[0]";
  }else{#check email
    $a = $a0;
    $a =~ s/.*\<//;
    $a =~ s/\>.*//;
    $a =~ s|^["\s\{\}\(\)\r#!%\$'/\&\*\+,\.\-]*||;
    $a =~ s|["\s\{\}\(\)\r#!%\$'/\&\*\+,\.\-@]*$||;
    $a =~ s/@.*//;
    $a =~ s|([a-z])([A-Z])|$1 $2|g;
    $a =~ s/[\._-]/ /g;
    my @as = split (/ /, $a);
    my $res = "";
    for my $i (0..$#as){
      $res .= ";$as[$i]" if $as[$i] ne "" && $as[$i] !~ /^[0-9]*$/;
    }
    $res =~ s/^;//;
    if ($res ne ""){
      $res =~ tr/[A-Z]/[a-z]/;
      @as = split (/;/, $res);
      pop @as if ($#as > 1 && $as[$#as] =~ m/^([iv]|[iv][iv]|ii[iv]|vii|jr|sr|phd|md|dds)$/);
      #print STDERR "here1\n";
      return "$as[0] $as[$#as]" if $#as > 0;
      return "$as[0]";
      # handle singleword concatenated firstlast usernames in the future
      # e.g., fabianlevin88@hotmail.com, amockus1@gmail.com 
    }
  }
  return "";
}
sub parseAuthorId{
  my $a = $_[0];
  my $a0 = $a;
  my $eBare = $a;
  $eBare =~ s/\s+\<.*//;
  if ($eBare !~ /@/){
    $eBare = "";
  }
 
  my ($f, $l) = split (/ /, getFL($a), -1);
  $f = "" if !defined $f;
  $l = "" if !defined $l;
  my $e = $a;
  $e =~ s/.*\<//;
  $e = $eBare if ($e !~ /@/);
  $e =~ s|{ID}\+{||;
  $e =~ s|[}{]||g;
  $e =~ s/\>.*//;
  $e =~ s|^[\s\{\}\(\)\r#!%\$"'/\&\*\+,\.\-]*||;
  $e =~ s|[\s\{\}\(\)\r#!%\$"'/\&\*\+,\.\-]*$||;
  $e =~ tr/[A-Z]/[a-z]/;
  my $ghid = "";
  if ($e =~ m/([^\+ ]+)\@(users.noreply.github.com|users.github.com|noreply.users.github.com)/ && defined $1){ #get github hadnle
    $e = $1;
    $e =~ s|^["\s\{\}\(\)\r#!%\$'/\&\*\+,\.\-]*||;
    $e =~ s|["\s\{\}\(\)\r#!%\$'/\&\*\+,\.\-]*$||;
    $e .= '@users.noreply.github.com';
    $ghid = $e;
    $ghid =~ s/\@.*//;
  }
  my ($u, $d) = split(/\@/, $e);
  $u = "" if !defined $u;
  $d = "" if !defined $d;
  return ($f, $l, $u, $d, $e, $ghid, $a);
} 

sub simpEmail {
  my $eO = $_[0];
  return "" if $eO eq "";
  my $e = $eO;
  $e =~ s|git config.*||;
#$e =~ s|�~@~\||g;#$e =~ s|�~@~\||g;
  $e =~ s|�~@~]||g;
  $e =~ s|�~@~X||g;
  $e =~ s|¨||g;
  $e =~ s|«||;
  $e =~ s|»||g;
  $e =~ s|�~@~Y||g;
  $e =~ s|�~@~^||g;

  $eO = $e;

  my @z = split(/\@/, $e);
  my $d = $z[1];
  if (defined $d && $d ne "" && $d !~ m/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/){
    $d =~ s|^[^\.]*\.noreply\.||;
    $d =~ s|/.*||;
    my @y = split(/\./,$d,-1);
    shift @y if ($y[0] =~ m/[0-9]/ && $#y > 1);
    pop @y if $d =~ m/\.(local|localdomain)$/;
    $d = join ".", @y;
    $eO = "$z[0]\@$d";
  }
  return $eO;
}


sub segB {
  my ($s, $n) = @_;
  return (unpack "C", substr ($s, 0, 1))%$n;
}


sub segH {
  my ($sh, $n) = @_;
  return (unpack "C", substr (fromHex($sh), 0, 1))%$n;
}

sub sHash {
  # $nseg is powers of 2
  #  otherwise use % $nseg
  my ($v, $nseg) = @_;
  Digest::FNV::XS::fnv1a_32 ($v) & ($nseg - 1);
}
sub sHashV {
  my $v = $_[0];
  Digest::FNV::XS::fnv1a_32 ($v);
}

sub toHex {
        return unpack "H*", $_[0];
}
sub fromHex {
        return pack "H*", $_[0];
}
sub safeDecomp {
  my ($codeC, $msg) = @_;
  my $code = "";
  eval { 
    $code = decompress ($codeC);
    return $code;
  } or do {
    my $ex = $@;
    print STDERR "Error: $ex, msg=$msg, code=$code\n";
    eval {
      $code = decompress (substr($codeC, 0, 70));
      return "$code";
    } or do {
      my $ex = $@;;
      print STDERR "Error: $ex, $msg, $code\n";
      return "";
    }
  }
}
sub safeComp {
  my ($codeC, $msg) = @_;
  my $code = "";
  eval {   
    my $code = compress ($codeC);
    return $code;
  } or do {
    my $ex = $@;
    print STDERR "Error: $ex, $msg\n";
    return "";
  }
}

# showCommit, showBlob, showTree, showTag
#sub showCommit {
#}

# Parsing git commits

sub signature_error {
        my ($msg, $data) = @_;
        print STDERR  "failed to parse signature - $msg\n";
        return ($data, "");
}

sub contains_angle_brackets{ 
   my $input = $_[0];
        return index ($input, '<') >= 0 || index ($input, '>') >= 0;
}

sub is_crud {
   my $c = $_[0];
   return  ord($c) <= 32  ||
                $c eq '.' ||
                $c eq ',' ||
                $c eq ':' ||
                $c eq ';' ||
                $c eq '<' ||
                $c eq '>' ||
                $c eq '"' ||
                $c eq '\\' ||
                $c eq '\'';
}

sub extract_trimmed {
   my ($ptr, $len) = @_;
   $ptr = substr($ptr, 0, $len);
   my $off = 0;
   while (is_crud (substr($ptr, $off, 1)) && $len > 0) {
                $off++; $len--;
   }
   $ptr = substr ($ptr, $off, $len);
   $off = 0;
   while ($len && is_crud (substr($ptr, $len-1, 1))) {
        $len--;
   }
   return substr ($ptr, 0, $len);
}

sub git_signature_parse {
   my ($buffer, $cmt) = @_;
   my $email_start = index ($buffer, '<');
   my $email_end = index ($buffer, '>');
   if ($email_start < 0 || !$email_end || $email_end <= $email_start){
      if ($email_end < $email_start){
        print STDERR  "in $cmt malformed e-mail ($email_start, $email_end): $buffer\n";
        $buffer =~ s/\>// if $email_end >= 0;
        $buffer =~ s/$/\>/ if $email_end < 0;
        return git_signature_parse ($buffer, $cmt);
      }else{
        return signature_error("in $cmt malformed e-mail ($email_start, $email_end): $buffer", $buffer);
      }
   }
   $email_start += 1;
   my $name = extract_trimmed ($buffer, $email_start - 1);
   my $email = substr($buffer, $email_start, $email_end - $email_start);
   $email = extract_trimmed($email, $email_end - $email_start);

   return ($name, $email);
}

sub extrCmt {
  my ($codeC, $str) = @_;
  my $code = safeDecomp ($codeC, $str);
  my ($tree, $parent, $auth, $cmtr, $ta, $tc, $taz, $tcz) = ("","","","","","");
  my ($pre, @rest) = split(/\n\n/, $code, -1);
  for my $l (split(/\n/, $pre, -1)){
     #print "$l\n";
     $tree = $1 if ($l =~ m/^tree (.*)$/);
     $parent .= ":$1" if ($l =~ m/^parent (.*)$/);
     ($auth) = ($1) if ($l =~ m/^author (.*)$/);
     ($cmtr) = ($1) if ($l =~ m/^committer (.*)$/);
  }
  ($auth, $ta, $taz) = ($1, $2, $3) if ($auth =~ m/^(.*)\s(-?[0-9]+)\s+([\+\-]*\d+)$/);
  ($cmtr, $tc, $tcz) = ($1, $2, $3) if ($cmtr =~ m/^(.*)\s(-?[0-9]+)\s+([\+\-]*\d+)$/);
  $parent =~ s/^:// if defined $parent;
  return ($tree, $parent, $auth, $cmtr, $ta, $tc, $taz, $tcz, @rest);
}

sub extrPar {
  my ($codeC, $str) = @_;
  my $code = safeDecomp ($codeC, $str);
  my ($tree, $parent, $auth, $cmtr, $ta, $tc) = ("","","","","","");
  my ($pre, @rest) = split(/\n\n/, $code, -1);
  for my $l (split(/\n/, $pre, -1)){
    $parent .= ":$1" if ($l =~ m/^parent (.*)$/);
  }
  $parent =~ s/^:// if defined $parent;
  return $parent;
}


sub getTime {
  my ($codeC, $str) = @_;
  my $code = safeDecomp ($codeC, $str);
  my ($pre, @rest) = split(/\n\n/, $code, -1);
  my ($auth, $cmtr, $ta, $tc) = ("","","","");
  for my $l (split(/\n/, $pre, -1)){
    ($auth) = ($1) if ($l =~ m/^author (.*)$/);
    ($cmtr) = ($1) if ($l =~ m/^committer (.*)$/);
  }
  ($auth, $ta) = ($1, $2) if ($auth =~ m/^(.*)\s(-?[0-9]+\s+[\+\-]*\d+)$/);
  ($cmtr, $tc) = ($1, $2) if ($cmtr =~ m/^(.*)\s(-?[0-9]+\s+[\+\-]*\d+)$/);
  ($ta, $tc);
}

sub splitSignature {
  my $s = $_[0];
  return git_signature_parse ($s, "");
}

sub cleanCmt {
  my ($cont, $cmt, $debug) = @_;
  if ($debug == 6){
    my ($tree, $parents, $auth, $cmtr, $ta, $tc, $taz, $tcz, @rest) = extrCmt ($cont, $cmt);
    $ta =~ s/ .*//;
    $ta = 0 if length($ta) > 10; 
    $ta = sprintf "%.10d", $ta;
    $taz =~ s/;/ /g;
    $auth =~ s/;/ /g;
    print "$cmt;$ta;$taz;$auth;$tree;$parents\n";
    return;
  }
  if ($debug == 8){
    my ($tree, $parents, $auth, $cmtr, $ta, $tc, $taz, $tcz, @rest) = extrCmt ($cont, $cmt);
    $ta =~ s/ .*//;
    $ta = 0 if length($ta) > 10; 
    $ta = sprintf "%.10d", $ta;
    $tc = 0 if length($tc) > 10; 
    $tc = sprintf "%.10d", $tc;
    $auth =~ s/;/ /g;
    $cmtr =~ s/;/ /g;
    print "$cmt;$ta;$tc;$auth;$cmtr;$parents\n";
    return;
  }
  if ($debug == 9){
    my ($tree, $parents, $auth, $cmtr, $ta, $tc, $taz, $tcz, @rest) = extrCmt ($cont, $cmt);
    $ta =~ s/ .*//;
    $ta = 0 if length($ta) > 10;
    $ta = sprintf "%.10d", $ta;
    $tc = 0 if length($tc) > 10;
    $tc = sprintf "%.10d", $tc;
    $auth =~ s/;/ /g;
    $cmtr =~ s/;/ /g;
    $taz =~ s/;/ /g;
    $tcz =~ s/;/ /g;
    my $cm = join '\n', @rest;
    $cm =~ s/^\n*//;
    $cm =~ s/\n*$//;
    $cm =~ s/\r//g;
    $cm =~ s/\n+/\n/g;
    $cm =~ s/\n/__NEWLINE__/g;
    $cm =~ s/;/__SEMICOLON__/g;
    print "$cmt;$tree;$parents;$auth;$cmtr;$ta;$tc;$taz;$tcz;$cm\n";
    return;
  }
  if ($debug == 5){
    print "$cmt;".(extrPar($cont))."\n";
    return;
  }
  my ($tree, $parents, $auth, $cmtr, $ta, $tc, $taz, $tcz, @rest) = extrCmt ($cont, $cmt);
  my $msg = join '\n\n', @rest;
  if ($debug){
    if ($debug == 3){
      my $c = safeDecomp($cont, $cmt);
      $c =~ s/\r/ /g;
      print "$c\n";
    }else{
      if ($debug == 7){
        my $c = safeDecomp($cont, $cmt);
        my $res = encode_base64 ($c);
        $res =~ s/\r/\\r/g;
        $res =~ s/\n/\\n/g;
        print "$cmt;$res\n";
      }else{
        $msg =~ s/[\r\n;]/ /g;
        $msg =~ s/^\s*//;
        $msg =~ s/\s*$//;
        $auth =~ s/;/ /g;
        if ($debug == 2){
          print "$cmt;$auth;$ta;$taz;$msg\n";
        }else{
          #if ($debug == 3){
          #  my ($a, $e) = git_signature_parse ($auth, $msg);
          #  print "$msg;$cmt;$a;$e;$ta;$auth\n";
          #}else{
          if ($debug == 4){
            print "$cmt;$auth\n";
          }else{
            $ta=~s/ .*//;
            print "$cmt;$ta;$auth\n";
          }
        }
      }
    }
  }else{
    $msg =~ s/[\r\n]*$//;
    $msg =~ s/\r/__CR__/g;
    $msg =~ s/\n/__NEWLINE__/g; 
    $msg =~ s/;/SEMICOLON/g; 
    $auth =~ s/;/SEMICOLON/g; 
    $cmtr =~ s/;/SEMICOLON/g;
    print "$cmt;$tree;$parents;$auth;$cmtr;$ta;$tc\n";
  }
}



# Peculiar objects that have some problems associated with them
our %largeBlobPrj = (
 "dead-hosts_just-domains_web_malwaredomains.com" => 203537862600,
 "briancpark_COVID-19-Visualizations" => 171205213898,
 "benchmark-driver_benchmark-driver.github.io" => 161693451294,
 "cfpland_frontend" => 138600000000,
 "hackmud-dtr_fragments-one-file" => 137259845661,
 "CareyLabVT_SCCData" => 129131000000,
 "scriptzteam_UseNet-Newsgroups-Stats-v3" => 111159914988,
 "moiify_AutoGreen" => 109406000000,
 "benchmark-driver_sky2-result" => 101453703349,
 "dead-hosts_rlwpx.free.fr.hrsk_git_FadeMind" => 101243706223,
 "bowmanlab_MIMSWebApp" => 99034200000,
 "Yu-Group_covid19-severity-prediction" => 96430200000,
 "raphaelvigee_velib" => 95267740853,
 "MakeNowJust_diary" => 88554400000,
 "TsangStreamLab_TsangStreamLab.github.io" => 88303300000,
 "swift-zym_scp-docs" => 86196479061,
 "randel_COVID-19-US-county-map" => 81160799723,
 "anenriquez_mrta" => 79351900000,
 "benchmark-driver_sky2-result" => 73213620001,
 "DMR-Database_database-beta" => 71890200000,
 "mitchellkrogza_Phishing.Database" => 71867290987,
 "olebeck_vitadb_tracking" => 70824716844,
 "luisbtejada_test1" => 69363610571,
 "merkleID_covid-domains" => 63861262430,
 "dead-hosts_add.Risk_git_FadeMind" => 62766028343,
 "GeoDS_COVID19USFlows" => 58243500000,
 "hamlett-neil-ur_BizStratTopicAnalysis" => 55308958784,
 "olebeck_vitadb_tracking" => 54604616511,
 "damng_hackernews-rss-with-inlined-content" => 53554579838,
 "batchpause_PAUSE-git" => 48400418092,
 "WhonixBOT_whonix-wiki-html" => 48253300000,
 "Park-Ju-hyeong_Quant" => 46335100000,
 "dazaza_dazaza.github.io" => 46103700000,
 "dead-hosts_rlwpx.free.fr.htrc_git_FadeMind" => 45629463605,
 "raphaelvigee_velib" => 45213248868,
 "BlankerL_DXY-COVID-19-Data" => 44929100000,
 "lihkg-backup_thread" => 44723920434,
 "ln-state_network-graph" => 43903009670,
 "dead-hosts_Badd-Boyz-Hosts_git_mitchellkrogza" => 43381795047,
 "HuidaeCho_covid-19" => 43207300000,
 "cul-it_rmc-eads" => 41770000062,
 "trendtopic_trendtopic.github.io" => 41341658602,
 "choosunsick_Korea_Stocks" => 39468170418,
 "jetblogs_jetblogs.github.io" => 38964394686,
 "Ultimate-Hosts-Blacklist_BadIPs.com_KEY" => 38457900000,
 "asamaru7_train" => 37579158386,
 "dead-hosts_The-Big-List-of-Hacked-Malware-Web-Sites_git_mitchellkrogza" => 37170287458,
 "AdguardTeam_FiltersRegistry" => 35963900000,
 "dead-hosts_Ad-filter-list_web_disconnect.me" => 35778458670,
 "Ultimate-Hosts-Blacklist_BadIPs.com_Level_3" => 35644600000,
 "DavHau_nix-pypi-fetcher" => 35392800000,
 "LuizGC_wealthymachinedata" => 34853600000,
 "open-covid-19_data" => 34551970588,
 "dead-hosts_domain_blocklist_web_dbl-oisd-nl" => 33791419357,
 "kristinbranson_JAABA" => 33050200000,
 "LibrariesWest_opendata" => 32675300000,
 "ledwindra_nber" => 31722700000,
 "qgis_pyqgis" => 31690765131,
 "RaiderIO_raiderio-addon" => 31477400000,
 "rozierguillaume_covid-19" => 31340198554,
 "cipriancraciun_covid19-datasets" => 31333583176,

 "enosysau_enointel-beta" => 200000000000,                          # "Enosys Security Operations Team (ip address risk)",
 "covid19india_api" => 200000000000,
 "covid19br_central_covid" => 200000000000,
 "cipriancraciun_covid19-datasets" => 200000000000,
 "beijingicu_maps" => 200000000000,                                 # "massive number of png files",
 "Pontorez_z-i" => 200000000000,                                    # "massive number of csv files listing IPs censored in Russia",
 "zapret-info/z-i" => 200000000000,
 "acycliq_full_coronal_datastore" => => 200000000000,               #"some large changing data",
 "volzinnovation_fuel_price_variations_germany" => => 200000000000, # "some large changing data",
 "SockPuppetry_Loop-A" => => 200000000000,                          # "test script", 
);

#based on update in Version S
our %largeTreePrj = (
 "pczh2010_img" => 600000000000,
 "lihkg-backup_thread" => 200000000000,
 "eugenelabzov_mp3lib" => 342866000000,
 "otiny_up" => 221345000000,
 "dapplion_Ethereum-Mainnet-Blocks" => 196663178831,
 "parkr_status" => 63335763661,
 "archlinux_svntogit-community" => 44765415181,
 "sandsmark_scp-wiki" => 42512961508,
 "biorealize_biorealize.github.io" => 36736915460,
 "zasdfgbnm_archlinux-community" => 36329023062,
 "conglp90_UpGitHub" => 35512900000,
 "vith_archlinux-packages-community" => 24063000000,
 "chinapedia_wikipedia.ja" => 20598200000,
 "hk-hospital-watch_hk-ha-ae-wait-time" => 19003300000,
 "BuildingBlocksTechnologiesLLC_Data" => 17862600000,
 "samber_powEUr" => 16885037822,
 "insolar_constellation" => 16466764253,
 "revuloj_revo-fonto" => 16060863600,
 "regro_cf-graph-countyfair" => 14225966059,
 "chinapedia_wikipedia.zh" => 14096800000,
 "vrhk_vrhk.github.io" => 12796291825,
 "vith_archlinux-packages-community" => 12466763781,
 "zq9409img_qunagaoqing" => 12432340526,
 "vith_archlinux-packages-community" => 11596263428,
 "regro_cf-graph-countyfair" => 10854862254,
 "openSUSE_kernel-source" => 10815200000,
 "jlippold_tweakCompatible" => 10226593179,
 "SUSE_kernel-source" => 10201400000,
 "thomasNDS_lbl" => 9559910000,
 "lvsti_airspace" => 9510080385,
 "Homebrew_homebrew-core" => 9304030000,
 "conda-forge_feedstocks" => 8125286856,
 "void-linux_void-packages" => 7927674122,
 "minionsmanaged_observations" => 7324054293,
 "xxcode_img.ibz.bz" => 7056410000,
 "thomasNDS_lbl" => 6924695102,
 "majorna_blockchain" => 6612206242,
 "adriaanvanrossum_saasforcovid.com" => 6192540000,
 "greglyman_HogueSolarData" => 6097824986,
 "Jonty_uk_petitions_data" => 6048200000,
 "shinhwagk_test" => 5918462920,
 "kawadasatoshi_q_img_store" => 5550472266,
 "git.kernel.org_pub_scm/linux/kernel/git/sashal/deps" => 5442000000,
 "owid_owid-static" => 5377125430,
 "giantswarm_control-plane-test-catalog" => 5347003487,
 "bioconda_bioconda-recipes" => 5305494796,
 "DefinitelyTyped_DefinitelyTyped" => 5202710000,
 "marco-c_gecko-dev-comments-removed" => 5133780000,
 "newstools_2019-the-guardian-uk" => 4973440048,
 "StukFi_stukfi.github.io" => 4890750000,
 "input-output-hk_hackage.nix" => 4839560225,
 "dazaza_dazaza.github.io" => 4640080000,
 "SOMEONE360_homebrew-core" => 4609770000,
 "watch-devtube_contrib" => 4590562228,
 "AxelTerizaki_karaokebase" => 4544830000,
 "test-organization-kkjeer_app-test" => 4363369816,
 "ahs-ckm_ckm-mirror" => 4072498026,
 "Homebrew_homebrew-cask" => 4006360000,
 "newstools_2020-the-guardian-uk" => 3958431603,
 "plazi_treatments-rdf" => 3864314742,
 "imagej_imagej.github.io" => 3852490000,
 "kaboomserver_schematics" => 3725495209,
 "dlancerzz_hanzi" => 3470271727,
 "f-droid_fdroiddata" => 3420805359,
 "repo.or.cz_homebrew-core" => 3418130000,
 "onedrive-x_media-10" => 3371060000,
 "onedrive-x_media-10" => 3371057719,
 "schlattsubserver_inventories" => 3317485471,

);

our %badProjects = (
  "bitzhoumy_helloworld" => "damaged trees",
  "bb_fusiontestaccount_fuse-2944" => "32400A",
  "bb_fusiontestaccount_fuse1999v2" => "34007A", 
  "octocat_Spoon-Knife" => "forking tutorial, 41176A", 
  "cirosantilli_imagine-all-the-people" => "Commit email scraper, 389993A",
  "marcelstoer_nodemcu-custom-build" => "97994A" ,
  "jasperan_github-utils" => "4394779C", 
  "avsm_ocaml-ci.logs" => "4283368C", 
  "illacceptanything_illacceptanything" => "what it says", 
"hjdivad_git"  => "git fork with extra comitters?",
"08_git" => "renamed to iBeacons/git a fork of msysgit/git", 
"00027jang27_git" => "git fork with extra comitters?",
"git.kernel.org_linux_kernel/git/fdmanana/linux" => 'really common?',
"bb_Kasreyn_linux-next" => "linux fork with extra comitters?",
"broftkd_linux" => "suspicious",
"1095811981_studyCode" => "suspicious",
"szeder_all-git-forks" => "suspicious",
"git.kernel.org_public-inbox_kvack.org/linux-mm/0" => "",
"git.kernel.org_public-inbox_lists.infradead.org/linux-amlogic/0" => "",
"git.kernel.org_public-inbox_lists.infradead.org/linux-arm-kernel/0" => "",
"git.kernel.org_public-inbox_lists.infradead.org/linux-i3c/0" => "",
"git.kernel.org_public-inbox_lists.infradead.org/linux-mtd/0" => "",
"git.kernel.org_public-inbox_lists.infradead.org/linux-riscv/0" => "",
"git.kernel.org_public-inbox_lists.kernelnewbies.org/kernelnewbies/0" => "",
"git.kernel.org_public-inbox_lists.ozlabs.org/linuxppc-dev/0" => "",
"git.kernel.org_public-inbox_lists.zx2c4.com/wireguard/0" => "",
"git.kernel.org_public-inbox_systeme.lip6.fr/cocci/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/backports/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/bpf/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/git" => "",
"git.kernel.org_public-inbox_vger.kernel.org/linux-block/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/linux-bluetooth/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/linux-btrfs/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/linux-cifs/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/linux-clk/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/linux-crypto/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/linux-ext4/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/linux-fsdevel/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/linux-hwmon/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/linux-iio/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/linux-integrity/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/linux-media/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/linux-mips/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/linux-modules/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/linux-nfs/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/linux-parisc/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/linux-pci/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/linux-renesas-soc/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/linux-rtc/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/linux-security-module/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/linux-sgx/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/linux-trace-devel/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/linux-trace-users/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/linux-watchdog/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/linux-wireless/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/lkml/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/lkml/1" => "",
"git.kernel.org_public-inbox_vger.kernel.org/lkml/2" => "",
"git.kernel.org_public-inbox_vger.kernel.org/lkml/3" => "",
"git.kernel.org_public-inbox_vger.kernel.org/lkml/4" => "",
"git.kernel.org_public-inbox_vger.kernel.org/lkml/5" => "",
"git.kernel.org_public-inbox_vger.kernel.org/lkml/6" => "",
"git.kernel.org_public-inbox_vger.kernel.org/lkml/7" => "",
"git.kernel.org_public-inbox_vger.kernel.org/netdev/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/netdev/1" => "",
"git.kernel.org_public-inbox_vger.kernel.org/netfilter-devel/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/rcu/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/selinux-refpolicy/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/selinux/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/stable/0" => "",
"git.kernel.org_public-inbox_vger.kernel.org/util-linux/0" => "",
  "Tomoms_kernel_laptop" => "seems like that may have multiple repos pushed here",
  "gh-_c-spoof" => "", "adob_print-stmt" => "", "adob_dnsserv" => "",  
  "ArtKuz_team4" => "", "gridsane_team4" => "", "saneiros_team4" => "", "yandex-shri-ekb-2014/team4" => "", 
  "IonicaBizauKitchen_I-Love-Octocats" => "", "IonicaBizau_I-Love-Octocats" => "",
  "taliaga_tsct-demo1" => "inus Torvalds authored and taliaga committed on May 13, 2016",
   "BIGJosher_Pattern-Recognition" => 'has fake commit',
   "gl_learn-git-fast_rock-paper-scissors" => "",
   "uselesscomputer_uselesscomputer.github.io" => 'torvalds@yandex.ru', 
   "cktricky_funfun" => 'torvalds <linus@linux.com>', 
   "docker_docker.github.io" => "", "0theRookie_hello-world" => "", "everyonehelp_helpmeplz" => "",
   "juanmanuelcata_proyectoSGT" => "single repo for torvalds alias",
"gh-_c-spoof" => "single repo for torvalds alias",
"ElieJacquelin_CommitFromGoogleApps" => "single repo for torvalds alias",
"r1p_tinyBlog" => "single repo for torvalds alias",
"mrcolts_active-users" => "single repo for torvalds alias",
"ajorquera_git-workshop" => "single repo for torvalds alias",
"hwhollywu_gomoku" => "single repo for torvalds alias",
"xNerdRage_IntroToGit" => "single repo for torvalds alias",
"thachmai_mobiliPlay" => "single repo for torvalds alias",
"stephenreay_testrepo" => "single repo for torvalds alias",
"zyw327_okgoes" => "single repo for torvalds alias",
"society765_hello-world" => "single repo for torvalds alias",
"Christopherbikie_Osmium" => "single repo for torvalds alias",
"stultus_vinpoc" => "single repo for torvalds alias",
"rubarax_git" => "single repo for torvalds alias",
"alisaifee_jquery" => "single repo for torvalds alias",
"spirit986_AdminScripts" => "single repo for torvalds alias",
"taliaga_tsct-demo1" => "single repo for torvalds alias",
"ghtest3_test1" => "single repo for torvalds alias",
"veterolf_fluar.github.io" => "single repo for torvalds alias",
"zmap_zgrab2" => "single repo for torvalds alias",
);

sub addForks {
  open A, "zcat /da0_data/github/ghReposForks.gz|";
  while (<A>){ 
    chop(); 
    $badProjects{$_}++; 
  }
}


our %badAuthors = ( 'one-million-repo <mikigal.acc@gmail.com>' => "1M commits", 
   'scraped_page_archive gem 0.5.0 <scraped_page_archive-0.5.0@scrapers.everypolitician.org>' => "4243985C", 
   'Your Name <you@example.com>' => "1829654C",
   'Auto Pilot <noreply@localhost>' => "2063212C",
   'GitHub Merge Button <merge-button@github.com>' => "109778A",
   '= <=>' => "190490A",
   'greenkeeper[bot] <greenkeeper[bot]@users.noreply.github.com>' => "2067354C", 
   'Google Code Exporter <GoogleCodeExporter@users.noreply.github.com>' => "277+K projects",
   'datakit <datakit@docker.com>' => "4400778 commits", 
   'The Octocat <octocat@nowhere.com>' => 'forking tutorial',
   'The Gitter Badger <badger@gitter.im>' => 'The Gitter Badger',
   'root <root@localhost.localdomain>' => 'homonym',
   'root <you@example.com>' => 'homonym', 
   'testuser <testuser>'  => 'homonym',
   'Linus Torvalds <linus@git.org>' => "singingwolfboy_cookbook",
   'torvals <torvalds@osdl.org>' => 'Feminist-Software-Foundation_C-plus-Equality',  
   'Deleted user <ghost@github.com>' => "",'root <root@localhost.localdomain>' => "", 
   'tip-bot for Linus Torvalds <torvalds@linux-foundation.org>' => "",
   'root <root@ubuntu.(none)>' => '');



our %badCmt = (
  "c89423063a78259e6a7d13d9b00278a0c5e637b0" => 10000000005,
  "45546f17e5801791d4bc5968b91253a2f4b0db72" => 10000000000,
  "6b4ea721e0b9158d26c4f8fc85ab60c6933f73d1" => 10000000000,
  "03cb3eb9c22e21e2475fee4fb6013718a2fa39fb" => 100000000,
  "20ee59241cda54347832afca4a32d8474bc8c01b" => 33324118926,#and much more
  "011c51845b624f1f82653f87017be7a4d8ceaa4d" => 4007698, #lots of renames don't do diff
  "0f17bf2e73149f60302a0a2464b3fadf3ea3e6f9" => 16777217,
  "ce1407a59c910ac5dead8cb1b8b4841cabfce000" => 6649016,
  "f905f1dfa705708c4a85b04cc81b5823f1112d1c" => 6356922,
  "1f27d2f1525eb869adb8b3e2eaca949ed0e1324d" => 4007698, #2003849 blobs
  "565ff603ec3e94d69ac62bb1e785cb96c56f58af" => 3574908,
  "c564a0194505a4a9bf32785d1b24fe4f39e6d850" => 3574908,
  "1bde687e7cb3610a85b87f4ddfc01d1744e47948" => 3574908,
  "439acc4da37cc3843482ecfd939e7439948203c9" => 3522632, #3324492 blobs
  "83c453d73f1eac85263c89d5a50ba8f9ddfccaf2" => 3336152,
  "5aa5cbef68281f4936d2ada938dc434f4b0a9078" => 3362998,
  "fdb171ce6dbe44431ba0841acf005c7dbf55bad5" => 3190105,
  "1651ff7cb254006d82d2148c281ec3945f266b38" => 2918400,
  "3d156dd720d679df5cb2468c7eb4fe58dc642494" => 2219847,
  "61f824547f2e82c19570302de75c06f1d4f960b0" => 2541111,
  "3f631f976149d8702d0b1496df7b98f16a9357ed" => 2013166, #2013166 blobs
  "14bde94da008ac1c65e0c066ee269315e47c0987" => 7651931, #Completed Search Engine with Cosine Similarity and Champion Lists, storing the entire inverted index in terms, with each term having its own pickle file.
  "1682fa6408b6e0c8f131cf74e0b17a5870acc00c" => 2161208, #dataset: train
  "149d0c641a429719acdd5ee3e0c11dffa41ea6c9" => 1293339, #Update Git repository using egup-single
  "96cc354af7f67bb600e9e79c6c8cd5dad16ce51e" => 1000001, #lol
  "0a1fc2163e0faff92e0533d321af5a2ce0be60fb" =>  994111, #[egup] Update repository metadata
  "15f69dd2ce7b71657617e7f7f40232df7755a962" =>  839705, #update partition_failure_rate
  "0b24aed7c8e379a04d7fd9fbd56b6407acc04b66" =>  819200, #layer_2:
  "c2785b165b3d804b769207536a27e2606a254a42" =>  958884, # Added cifar dataset and visualizations
  "c2907c7d3bfaed6ffa39a54d44498a2c610cb75f" => 4098244, #im back
  "c9089ba3b4f17e006844befa9828c4e03b44723a" => 1899090, #[Automatic commit] Errors from ibinti/bugvm
  "d117f34065df34797cb8b2529d1f30142615f32e" =>  828546, #More websites and add HTML exports of mailing lists
  "d370ba139a4fecce298bda5f3662536d28928f5c" => 1151323, #Fill blank tiles
  "f94fa89009c8e3ba5e46fbf1c583114d9c6b37f8" =>  933725, #Uploading
  "fc4247ae1baf592a4b52a355d3047e1938ef3f9b" =>  941677, #DATA
  "695b944f918414ebc0608cb25b8dbb8fc906a720" => 1000001, #bash_lab v1
  "a69f8f2cb6eba2ca18870ac00d511f8ae7c360e3" =>  819200, #layer_1
  "a919d97b57e275cd1af964b4915f8889f94799ed" =>  839703, #ready to test
  "d8034ac8562b8c978376008f4b33df01b8887b19" => 1578523, #Replacing the 500k programs by 1m, and better folder structure
  "df3e25ef63aeeb62982740d44f2a8e6a6534ac94" => 1000000, #deleted
  "ac4ba8e8f32627854cf3d2cd5870c138622e9fee" =>  941686, #Json author gmtr-web <gmtrweb@gmail.com> 
  "e477a5c4173e9a568c352f9e743ec1e330aa8a2a" => 13300108, #edits author Muhammad Usman <muhammadusman@utexas.edu> 1583026565 -0600
  "e601b95f45dde98dd4d1f80a1d3304905a340ab8" => 1004542, # [Automatic commit] Errors from geogebra/geogebra
  "7140aaf36cca2e8ecf01cd765608208f44f108e7" =>  851015, # Add data author manhcuongk55 <dmcksclck55@gmail.com> 1579495353 +0700
  "0e2bfc6cfacfb1567b094e7f09e81fc925e83303" => 1359989, # LiamOSullivan/dd-ver1-data-archive rm sound data

  "0a36c08880da83a84209efe5aa90ca3f9b1dc453" => 10000000000, # tons of fake blobs
  "12ef405ef13a47da699aa2b8e86c4d49edc57e5d" => 10000000000, # tons of fake blobs
  "2c1e65d57edc4a9e57b74d17fec019be8d3afac0" => 10000000000, # tons of fake blobs
  "8437c8457efd83857e91ec68c6435aa7d5815c68" => 10000000000, # tons of fake blobs
  "142e0f29cd5bd79f2d2e3aab108a6bc4fc0027d5" => 10000000000, # tons of fake blobs
  "3f1adf76e33f5908bf8779ecf9e50216c5ea0d4c" => 10000000000, # tons of fake blobs
  "ab6e602c16a1076171b4b94aa0ab26b4901ddfb6" => 10000000000, # tons of fake blobs
  "65dd6581536737204c45de85838bb80ba263d59b" => 10000000000, # tons of fake blobs
  "859a358ac545e31f314e82ca1bec4324a0699868" => 10000000000, # tons of fake blobs
  "c34d3fd2632294a170cc9fc4155d97456067033f" => 10000000000, # tons of fake blobs
  "0ab1b1479f745997219c87493fc2aada83e52f28" => 10000000000, # tons of fake blobs
  "9039eebad1dd3adba84aca79a88af3c91e937986" => 10000000000, # tons of fake blobs
  "1a6c2b5d17b04daf9cebc7ac1686bcf486b121e0" => 10000000000, # tons of fake blobs
  "e28531ce2bc8cddaa28f1c856eb16562c0fd2f27" => 10000000000, # tons of fake blobs
  "27ddfc983d2c4d3d872190daadf3ea696dade0a9" => 10000000000, # tons of fake blobs
  "e79e8df920674d4cb85eb2dc318f3ee12d54a7d7" => 10000000000, # tons of fake blobs
  "9526a733a3f2570bb4b4b5491783a23f8db2373a" => 10000000000, # tons of fake blobs
  "5585ecc02727b59f488a97e6dd763700b9c9f377" => 10000000000, # tons of fake blobs
  "7c5e967d0f6b05cff43c45d44e80467beabbcda0" => 10000000000, # tons of fake blobs
  "77c1b612150ede5e0262d911257a7f7d902a9dee" => 10000000000, # tons of fake blobs
  "13dab7d0c4c7de1cee0a84a99d014a2db9a9cd62" => 10000000000, # tons of fake blobs
  "3b6e7e2216f0cb246b7dc2efaf60ea9e155815ee" => 10000000000, # tons of fake blobs
  "d0dd04ca9f20a79a07446788bda17bd70cd3351f" => 10000000000, # tons of fake blobs
  "73b7d5a2adf4ba61b63a008e4f4670a29fd8f3ea" => 10000000000, # tons of fake blobs
  "28d23b279edafe299e3990d0824f9a5b59778af2" => 10000000000, # tons of fake blobs
  "2c9da9e1f17d8ccd394d7b73879b967faa0f31f2" => 10000000000, # tons of fake blobs
  "1fe0c25da3c66e2115c2bbeb8b307b5851bfe908" => 10000000000, # tons of fake blobs
  "6762f9e2fbc2984f5c4b2f6fcccbb8b711ea35b6" => 10000000000, # tons of fake blobs
  "22292b51127117c42dedb34b555499d901f4367e" => 10000000000, # tons of fake blobs
  "1fe0c25da3c66e2115c2bbeb8b307b5851bfe908" => 10000000000, # tons of fake blobs
  "351ab852990bb7da9fe7f637163b93d5dd7a008d" => 10000000000, # tons of fake blobs
  "3b273eccbc8abeeb12632c5d1ec555317533af72" => 10000000000, # tons of fake blobs
  "7108364d8d19f9b6377e9a0cdd8b7938873078de" => 10000000000, # tons of fake blobs
 
  "a02ca3c3719eb34e8d8d521cbd6325871cfdf240" => 10000000000, # tons of identical trees with the same empty file .gap.json
  "4332d6eda8f6b3ce73571225409a07a11a856e1b" => 10000000000, # tons of identical trees with the same empty file .gap.json

  "66645f6a8d41bc9f1b31596b6c9c47e7a1b6a060" => 520530, #520530 in c2fb
  "029aad01abe478c2f3e844de698231f7dc2f7cf3" => 3793324,
  "07cd2db66cd48dfdd9632d18fa7a150c51e0ac6e" => 1599721,
  "0d45d1a714b1d95fd5258b3bbdd294897e29d5ed" => 683751,
  "0d9291b790a9e88c29246a740f105a05711ed24c" => 824097,
  "0dfc9793807b720923a99a6f68639695c45aae80" => 770124,
  "2267c4f139c7195869f5d24b14db0426b90bd2aa" => 707836,
  "226b606fcb2ec4dc46846751d6f801943c92f739" => 1989222,
  "229c2a315ea2f2c1b13ab40d88f3c16e02b56754" => 628225,
  "22a693c9de5c4619b72060ff9883b7a70d719b8c" => 660836,
  "22d719509de6b9bc537606b8f1f8fabeb0f30987" => 1105700,
  "2d6d5242dd8e521ffbd305265988526c469f9a5a" => 669185,
  "2d8b23c25acf88e1342bb7c1655625c6128fef87" => 855359,
  "2dc663b47b7d999c2545e41f33f9f166ff427eab" => 979089,
  "662f26d714229d6998d40d91423b51d7a9c7a9a8" => 990000,
  "66424c417f8b8d05cbead89bec8eeb64846302f9" => 774383,
  "66616e3d934973fe001adfd30b6bb045d87cfec8" => 703016,
  "66645f6a8d41bc9f1b31596b6c9c47e7a1b6a060" => 520530,
  "6665b2f3ada6ec1c585ca4dcd69bba8cf8604845" => 520513,
  "66ac0671392e55f9f26717d12d912be506bece29" => 523145,
  "66d9890c62c4e1baacdedd2653c68ef8bc2f6d6d" => 617679,
  "6d2e49cd628cfa43b98ced89acb71370ca090e44" => 619672,
  "6d32c8efbb971af33d4c12f6869c2ddffec2bed4" => 440060,
  "6d3cb75b3102e98c2f9a53f8b00371a5d8565de6" => 520380,
  "6dfaa2833450d1cdf410fda67a87e5c2fff2bf7c" => 505317,
  "8b5d8aa66e69b64092b1304910510c8474db9449" => 983677,
  "8d2c5f5f34b54d543862d70942d3cf5ab2ac58d6" => 578554,
  "8d34c18e1bbc121171a5340dfc62654847dd86ed" => 608994,
  "8d463bcbf3d83da7e400c2a752ad1811ae3fc125" => 517401,
  "90679fae3785ca97d7b7a66862369295baee98c0" => 539497,
  "a2c89d2625d552404b040e6e0c24e1d4088a134a" => 584909,
  "a2d04e9f17258008ba11b3a7b545f0867f6efe81" => 555012,
  "a2e1aea8797b8e2bed3953385dc8e0dccc9db271" => 1377218,
  "ad3b87b8f9e564c4a4e028036fe2abe1e4d5986e" => 510268,
  "ad44d8c300a6f93c1a0c5d4500d82b934cb0e060" => 621165,
  "e5b1a20e53a60d6da1e34f0d22b30170aa053f3f" => 539487,
  "e6541de24113b9cb4e2f19387bc1af5511ad799e" => 3997933,
  "e88c59f2fab3243c3d0af6cc2ae2874ac77f63aa" => 532401,
  "ed769eef9e9dd69037322ffd5c24470590328a09" => 726169,
  "ed89c009aab3b63874683404d989b40e225ce6f8" => 630643,



  "142e0f29cd5bd79f2d2e3aab108a6bc4fc0027d5" => 10000000000, # tons of fake folders
  "b55208a72f6443eaeaf31789f9a492c20dc021a1" => 10000000000, # tons of fake files
  "f268257b2f1517e4f870820a5a63cbe215668f5c" => 10000000000, # tons of fake files
  "c1ce17533f16f8928878c0cfc45cb4be1b32ca71" => 10000000000, # tons of fake files
  "5e4c1715341534fbcf4126c053bc0ff64cc48a7c" => 10000000000, # tons of fake files
  "f0e385e0fb36173c53f68f91b6e28023a039da02" => 2043846, # tons of fake files
  "2dc4ae3376734e12819ebce8140d35f211a8f857" => 1386254, # tons of fake files
  "cc646e6b0c4584134424ce0b2d385080169f3b81" => 1171240, # tons of files
  "eecde993ec799b0fb714bbd2124ec893c1125473" => 1130319, # tons of files
  "0e33a9c3e97a85c632f964375c5ecada305514de" => 1217678, # tons of files
  "209808f8bb917ad827f605df778f1b3413867170" => 1043954, # tons of files
  "20c20b16d41dd820737ead0f0eb3d31fe09e2fbd" => 1053734, # tons of files
  "609c5d1300e75c12239bf304661ab5338df4cc54" => 1984503, # tons of files
  "fa60ead1916232e59a569d9ee3858ec6a44c3c31" => 1518362, # tons of files
  "d91f4ab4b1793a7544a4ad68264662303f6a8d60" => 1518362, # tons of files
  "67e1f49d68c696d4ec1eddaa66327a5ec7e42412" => 1517162, # tons of files
  "6ab9ad6e8d47cf613e7587afd10ae3f5da8b0a0c" => 1516992, # tons of files
  "dbe1fe4b27d9f381b3db94a1602e8a039cd4c0ef" => 909063, # tons of files
  "8ca6512ce8b15ddaf67c1a1a84b5ed837041b319" => 909063, # tons of files
  "7c1f7ccca7d02522a07a3249dd002af1eec824f5" => 900348, # tons of files
  #719614 0e05305287c9697ecea4e32e6b097a96eba631f5
);



our %badBlob  = (
  "e69de29bb2d1d6434b8b29ae775ad8c2e48c5391" => 7826798, #\n 
  "9daeafb9864cf43055ae93beb0afd6c7d144bfa4" => 1524056, #test\n
  "654d0bfe943437d43242325b1fbcff5f400d84ee" => 1000000, #MIT license
  "869ac71cf7e4d72d9ab52f86d630c1c3f0c017ce" => 1000000, #K 14\nsvn:executable\nV 1\n*\nEND
  "e7af2f77107d73046421ef56c4684cbfdd3c1e89" => 1000000, #MIT license
  "68c5ddb060ea2e1f46c8fdffcda5826f3e462cba" => 1000000, #import { IconDefinition } from "@fortawesome/fontawesome-common-types";\ndeclare const iconDef: IconDefinition;\nexport = iconDef;
  "cc4dba29d959a2da7b97f9edd3c7c91384b2ee5b" => 1000000, #language: node_js\nnode_js:\n  - "0.8"\n  - "0.10"
  "ee27ba4b4412b0e4a05af5e3d8a005bc6681fdf3" => 1000000, #MIT license
  "f5e8cc6f41f19b931ec27412706eb7114c649d93" => 1000000, #[private]
  "19129e315fe593965a2fdd50ec0d1253bcbd2ece" => 1000000, #The ISC License
  "3c3629e647f5ddf82548912e337bea9826b434af" => 1000000, #node_modules
  "9ce06a81ea45b2883a6faf07a0d2136bb2a4e647" => 1000000, ## dummy
  "5e9587e658c3c3c18ab62ebc908568efd1226aed" => 1000000, #K 13\nsvn:mime-type\nV 24\napplication/octet-stream\nEND

  "8b137891791fe96927ad78e64b0aad7bded08bdc" => 957235, #\n\n
  "de6be7945c6a59798eb0ace177df38b05e98c2f0" => 650111,   #"module ApplicationHelpe\nend\n"
  "573541ac9702dd3969c9bc859d2b91ec1f7e6e56" => 100000, # more than that "0\n"
  "46b134b197f35e75e0784bedbf94a8dd124693b1" => 100000, # more than that "fffe"
  "5c15a99ffacbe23740c4b27cabc1df33988b3b86" => 100000, # more than that "<?php"
  "c1f9d5dd052c921bb709036a51e6ff77de303aae" => 100000, # more than that "<?php\n$searchnum=0;\n?>"
  "42fa765b495e581408e87614ac90a18b4fb03f09" => 100000, # more than that "<?php require(__FILE__);"
  "f57368ede135004cf1913c9296eaea8ced94ca63" => 100000, # more than that "<?php return unserialize('a:0:{}');"
  "06d7405020018ddf3cacee90fd4af10487da3d20" => 100000, # more than that "23 nuls"
  "2142470504f0374fee201d2b72d3e7915a2718b5" => 100000, # more than that " 0\n"
  "c227083464fb9af8955c90d2924774ee50abb547" => 100000, # more than that "0"
  "e440e5c842586965a7fb77deda2eca68612b1f53" => 100000, # more than that "3"
  "f11c82a4cb6cc2e8f3bdf52b5cdeaad4d5bb214e" => 100000, # more than that "9"
  "7813681f5b41c028345ca62a2be376bae70b7f61" => 100000, # more than that "5"
  "bf0d87ab1b2b0ec1a11a3973d2845b42413d9767" => 100000, # more than that "4"
  "56a6051ca2b02b04ef92d5150c9ef600403cb1de" => 100000, # more than that "1"
  "d8263ee9860594d2806b0dfd1bfd17528b0ba2a4" => 100000, # more than that "2"
  "62f9457511f879886bb7728c986fe10b0ece6bcb" => 100000, # more than that "6"
  "9a037142aa3c1b4c490e1a38251620f113465330" => 100000, # more than that "10"
  "3cacc0b93c9c9c03a72da624ca28a09ba5c1336f" => 100000, # more than that "12"
  "3f10ffe7a4c473619c926cfb1e8d95e726e5a0ec" => 100000, # more than that "15"
  "9d607966b721abde8931ddd052181fae905db503" => 100000, # more than that "11"
  "25bf17fc5aaabd17402e77a2b16f95fbea7310d2" => 100000, # more than that "18"
  "ca7bf83ac53a27a2a914bed25e1a07478dd8ef47" => 100000, # more than that "13"
  "d00491fd7e5bb6fa28c517a0bb32b8b506539d4d" => 100000, # more than that "1\n"
  "dec2bf5d6199c7cd0d84f3dc1e76a73ccc336302" => 100000, # more than that "19"
  "359456b7b6a1f91dc435e483cc2b1fc4e8981bf0" => 100000, # more than that "UNKNOWN"
  "26f8db8e299c51a7656b7cc919b0b1ef34489075" => 100000, # more than that "|||\n\n"
  "80e4a8c2bb7d22bdc32446770781fb16cb5a20b7" => 100000, # more than that "new branch\n"
  "721fd3588bb4010aa8ccf952344e06063b2a0756" => 100000, # more than that "existing branch\n"
  "c40910aa8d631dc41a6ec342a270a8c1e56f85b1" => 100000, # more than that "{"message":"","registers":[]}"
  "0d5a690c8fad5e605a6e8766295d9d459d65de42" => 100000, # more than that "my new file contents"
  "10c09bc50e7c4005d41f8827f1598b74e94cc3de" => 100000, # more than that "Here be even moar damned content"
  "2995a4d0e74917fd3e1383c577d0fc301fff1b04" => 100000, # more than that "dummy"
  "521d0e4dde3b141ab557b10589aa4e3f4a5f94b7" => 100000, # more than that "import Foundation"
  "8a2030a3614762e08d57a138bfcf1b29396eecd4" => 100000, # more than that "--- []\n...\n\n"
  "a686078a02cdf71215e6ce2f9f99e51f9bd5b18c" => 100000, # more than that "This is README.MD"
  "a726efc43fc177e976fd3b236a15756d5522d5e9" => 100000, # more than that "'use strict';"
  "b71f2c6f78b435e9e554ed689d94eed705208bf7" => 100000, # more than that "[{"failureDictionary":{}}]" 
  "0637a088a01e8ddab3bf3fa98dbe804cbde1a0dc" => 100000, # more than that "[]"
  "ba375f08bcc50596adcf448772aa249cc951653e" => 100000, # more than that "{\n "packages": [\n\n  ]\n}"
  "0cac463bc5168fa988eb04de3ce9389ce402cec2" => 100000, # more than that "'library(reshape);'
  "782ab67126697f00afc53b1af1a054ffb17e1e20" => 100000, # more than that "callbackfunc([])"
  "9fdc54fd03d4dbd561dff15acfaa20a8581d8b44" => 100000, # more than that "callbackfunc2([])"
  "85a634cfeb01e93be1f5d3e720be0f02d1c39ae6" => 100000, # more than that "Array.new.reduce(:+)"
  "2fbf0ffd710189ce2905acb59a57eba453b1b9f9" => 100000, # more than that "--- {}"
  "6a1fa8227d962757f27b6acd30e6b4ed5e69f901" => 100000, # more than that "[public]"
  "b510eff7158ff94f324a99374283722c20daabf5" => 100000, # more than that "Importing file"
  "755b8fd7c101cf89c1bf29303e7f0fab94c8e094" => 100000, # more than that "Importing image file"
  "66d6ed311f56612691e878681bf7b73c57385088" => 100000, # more than that "dummy file to ensure patch has content."
  "38aa015d1fce4924ded80cc26dedcd63e1be767f" => 100000, # more than that "<?xml version="1.0" encoding="UTF-8"?>\n<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">\n    <apiVersion>36.0</apiVersion>\n    <status>Active</status>\n</ApexClass>"
  "79f7797da27875dab3bcd0b496f6ff3c4c08f403" => 100000, # more than that "censored"
  "4b404d55133f3db672a5fb7cb9021302ad644619" => 100000, # more than that "strlen()"
  "7a5ab9c516cf244e80d69d88df9840af416e24ee" => 100000, # more than that "strlen();"
  "175d1866e44595d0f301a44ef5c419e0c0e6dfc3" => 100000, # more than that "strlen($nothing);"
  "23ba560dd5e0c11633bdb160b31482b9333be639" => 100000, # more than that "this is a test for git performance..."
  "2799b45c6591f1db05c8c00bd1fd0c5c01f57614" => 100000, # more than that "GIF89..."
  "f55d454174c86cf2a8bf76baec8c872de08c8992" => 100000, # more than that "GIF89..."
  "35d42e808f0a8017b8d52a06be2f8fec0b466a66" => 100000, # more than that "GIF89..."
  "37f380bf3351767c02170a533266a0ae76fc5ecf" => 100000, # more than that "div.feed-carousel{width:100%...."
  "47446acba96f9bf7eb8752ee292d85727b39f973" => 100000, # more than that "{"closed": 0, "first_date": null, "last_date": null}"
  "873fb8d667d05436d728c52b1d7a09528e6eb59b" => 100000, # more than that "file3"
  "30d67d4672d5c05833b7192cc77a79eaafb5c7ad" => 100000, # more than that "file2"
  "faa5f452cf9879c50c9553aefbcfea53d86a2c46" => 100000, # more than that "Current Working Module: EntryPoint\nInfo : Testing Game"
  "9eade1fd850b34346a1d946e0cc499ea7a01173f" => 100000, # more than that "Current Working Module: EntryPoint\nInfo : Testing GameCurrent Working Module: CTextureDx9\nError : Can't get image info from file"
  "b139528a39bef1d78139a00626636f9145db6230" => 100000, # more than that "{"type":"FeatureCollection","msg":"Authentication Required","status":401}.."
  "d4cda3bfd461a9ead8b0add136c8fb1e99c88299" => 100000, # more than that "{"closed": [0, 0, 0, 0, 0, 0, 0, ..."
  "745a4f0917626f3e1f2046b1db94dfa0da0c5181" => 100000, # more than that ".body {}"
  "734d80e1801769f3d6cf601fe6c7565f59b8595e" => 100000, # more than that "dummy.each do {|d| puts d}"
  "dac35faf8dc87d70cf98b1a6b398e2d025e8fd9c" => 100000, # more than that "/*\n jQuery JavaScript Library v1.6.4\n..."
  "2d52768ea853f55dd0f7990ac4d5f4a1a4babaaf" => 100000, # more than that "{"first_date": null, "last_date": null, "submissions": 0}"
  "b55c2060ab0b676f951b94bd8b10a09068b6e074" => 100000, # more than that "(function(d){d.execute(function(){})})(function(){var d=window.AmazonUIPageJS||P,c=d.attributeErrors;return c?c("AmazonGatewayAuiAssets"):d}());"
  "2e524d79a1c1eb7fdd54dfa53370904b1ee31459" => 100000, # more than that "\n/*stdin:\nstdout:\nstderr:\nerror: OK\nstatus: 0\nsignal: 0\nresult: 11\n\n*/"
  "3305b2123bf3fe557934c2f6225b76bb1791ccd4" => 100000, # more than that "   0.000000000000e+00\n"
  "3d74f8c7882420c26c6bdd0568cb6d98abd16eae" => 100000, # more than that "                   inf\n                 -inf\n"
  "40846ebc8b4ffc1680365d46a431973b0cd734c4" => 100000, # more than that " 1.000000000000e+000\n"
  "524970aba65dc6148301e831d8b37eea3162ea47" => 100000, # more than that "                  inf\n"
  "c6cf38636b3b1a3156e2facb19b110217276d127" => 100000, # more than that " 1\n"
  "d14d9c187395940fa1a76bb25024efca358980e9" => 100000, # more than that "    1.000000000000e+00\n"
  "f9e12117cbb3abbc8665f2d4d8b00eaf23c0686e" => 100000, # more than that "{"closed": [0, 0, 0, 0, 0, 0, 0, 0, 0], "date": ["Oct 2015", "Oct 2015", "Oct 2015", "Nov 2015", "Nov 2015", "Nov 2015", "Nov 2015", "Nov 2015", "Dec 2015"], "id": [0, 1, 2, 3, 4, 5, 6, 7, 8], "unixtime": ["1444608000", "1445212800", "1445817600", "1446422400", "1447027200", "1447632000", "1448236800", "1448841600", "1449446400"], "week": [201542, 201543, 201544, 201545, 201546, 201547, 201548, 201549, 201550]}"
);

our %badTree = (
  "4b825dc642cb6eb9a060e54bf8d69288fbee4904" => 1  #empty tree with no files
);

our %badFile = (
  ".idea/workspace.xml" => 2392481,
  ".travis.yml" => 4542349,
  ".gitignore" => 12910257,
  "CHANGELOG.md" => 1713048,
  "composer.json" => 1880991,
  "setup.py" => 2344060,
  "config/routes.rb" => 3696871,
  "lkLocation" => 1596721,
  "lkHeartbeat" => 1596725,
  "db/schema.rb" => 2522388,
  "LICENSE" => 2805076,
  "gulpfile.js" => 1015643,
  "Gemfile" => 2380398,
  "Gemfile.lock" => 2392408,
  "Makefile.am" => 509880,
  "main.py" => 1314110,
  "main.cpp" => 1426595,
  "Makefile" => 2463961
);




my $badCmtHere =  <<"EOT";
530be26dccefe81287d7807a573eb54510120310
c1298c2bd839d9dd982c744cc43272a416839154
8fd70c85f6fbe9a358be12aed105cfca2400050d
b3406a68e66cba4176a6fa03146659b45444df62
fed2395d609b949a03aac50f4b2a2a7363cbcbf8
641eea2470836203610c00ac2c37e48ccde44e8c
8d555e54adee625097d0840f123e21e0ad20ca27
f7f1d213023daaedf8c8826993045c73a704af9b
0875d5f3f10183e1f0b2c70a0f3adec8edfed181
5a8416e0564620c5854a0cefe782151417710930
b1bc69fb5b21b65be26c69c6ac80ad885e2cd90e
7ffa79fa9026904f01462bbd920674f3b8a11c12
f12cb49604a74635adff35a6319f057cfd466637
982c8e463348dc3a5910791cdec2f4fd08ff4f32
4a03ffe4ce4ec9334e2d5bae3c29fbd44ae09f31
8b41c04ea3d37ab454552b159774d1dc9947b1c0
fc60c19c68734e0bfdfd1c74f1b2c42c78b82bee
d7037833174f94e273eded4c973ebe58ff42ce6c
4ee48bb7b2e496bf11387804a3bb79c79c410143
721f2ae0d6811fbf56305c1e8921ff8d3c358286
7570ed9c77896d40cb0deff32b40160c83323913
b471e1d016c8b660c471785b792d470b426cb555
5afa074315002cc029414518723695beb9cf564e
55d868e580f4a50a007b4d9edc671e28e5da3ecb
918da2958cb640f06ca084e01672ff40cb9ea435
4d71ec7a7bf41bed90bfc48a64cc8fffde4eb279
7fb7b16790895127fc80ea3cb5b30fe43db02750
02f889869a7493cff2f8c23acd59aaf95d96eecf
fa9bc553629eaaa4b11587d4809ddba015558f8d
af21afb1ac0721fc1021b346f528c6b0833fb224
bc5dcd7800149b12d891b0e8e69dcf0552c67e14
12906572b7753457b57ea07bcdbbee68d4dbece1
a02ca3c3719eb34e8d8d521cbd6325871cfdf240
5c8c63622dce2c22168b3e666e2c798c97532596
8cbc4490418f30ae745d4727e8f9b4a584e0571d
0b7cd994ffd64c70119ae6df902d43013fa4cbbb
167084d2920e0cef97d2e7423917c271bda2ad5e
4b8e25121cbb761c240ad39e832ea52af897002c
dafcb85be825ac53a1977fa7b30a203a99bbfbdf
b4d54d3032a83e7f3f336d0221529b27a93ae453
8d27df35e595f7f20d67dccc7b8e9e00292d4aa4
713b00daf5e899f4e34d350767ee4574087f5560
3797f25f9dc5510a2714ed88d216d8b5a29f9932
5b9a3ca4e99fc85511c40719398388bb85d5d462
265ba7e8386eccfee989b02941a6fc9f38696b6e
37a63fe13df1b36ff0e5f53a636e32125b41b49e
6c96cf58ecc041238d18097d71a62e9de95fd321
8e3b110c4be659bd4acc0ffbac320c0b6ef4b535
d46be305fb0b531b0b1598dcbb9d0c9555fff1ee
1462c74593b138758fac096c9a26a69cb8e37148
5eb63be74d378614fdebf82ca8b0f39141af6173
be92ed1f2b486c4855fff687ed96856901d5eedd
62aefd3512ba993e58a695026f850282e18053df
ce95e2c47711f4533fc0b2cc4c74d62b18875671
2fcc4d1ef5b25dcde3adda61510415eadaa43d5d
9a694fd4e9dba38b5c3de1feacd46c456fc5f4e9
f2a9c4aa901212bd3c87522dbeb9e59fa1021fc1
7becd7b801684474a02b4e981cc57951ffe3f2c0
d0de9efb686a5e27ad6aa517a9ab4f86031c6cf1
97734855fcc0a246dcd7f413af9753410529efe6
a1b603b13e36b5395ead5cbf9517ffc6c1cf9066
26357a19a932fb00fe6a5587f30c5659315e7bf9
45918d9b231cb09773f1b3efe41ce6525bc43ead
23f949e2514cb196bc94215c4197ce1a1289a88a
8aa477fba0af4a4ed996d99298a97cd86549b23b
d2deb1114e4927fba301bb8bab5958e68d0c456b
a6a5dcf333e934b28ef8e2d8edf5e8090137848b
f30fb24079dd419b143fbcbd54ef3509b5bbb1cb
87f379d973e2ad9d0d129671bbc29b476f4acf5b
415517c2bea1e22c9a7e2896ba5df9b92937438d
eba75c1f4054e4f6e25f95bd2f101ba8d3439c77
b3c08b6754a24c6c547f2093b3cd551b12216d20
c0396420a0c5409871d3d18f1c0469249984c852
598e07a58ea2dfd3bbdbff4f6a3433a2161d1235
d4dd7a7717ca212902defae6392830fadc35af5b
4332d6eda8f6b3ce73571225409a07a11a856e1b
01d8959dc497fae9bb13a4e64fba05dc82a5aea5
ba925554311440c322f05f870a6de4d121e5edda
58f0797a600c536011b09f54b536be5cae4d47fe
519d14c952e0fe751493803e42ad8a72329168e8
66ec1ba691b7df3eaf12df2e0583be28051e20d8
48880c38421329dbfe1d1651e053b614b11dfb81
7dc7cdf2dce9234e2696fb26ccfbdb93f4bd0f66
bd26365b7cc80c5b194cb6763ba331d91373be79
85535a307d46d2d77feff2b4e32efc3bb4ad67a3
302195c197294c8d636bb3e41a302f85653e7480
c3c9928387b9872f5d895d909b2af4fba0794497
77968abca82c34323fff74751d6c059be463856e
d7e000e593fbed8f8facd42bdfb295fc849fba87
8ba58ff7027f010274bc9942aa3a681822dfeb11
e12b477d1899a31621f230ad9d9183e47ef7dd38
23e1ccbebb89a2422f6c836e303a3270d784f8c8
aabdb40b6b176b6780c119533eba7ebe88d30c81
850682366b60b24a50c2628bfe8cf862b3865706
cb840d21bf09e7bfbde12826e5802b22f1995a56
febed3551cb6f5e9bdaeda6d960396fbb2a25753
530be26dccefe81287d7807a573eb54510120310
c1298c2bd839d9dd982c744cc43272a416839154
8fd70c85f6fbe9a358be12aed105cfca2400050d
b3406a68e66cba4176a6fa03146659b45444df62
fed2395d609b949a03aac50f4b2a2a7363cbcbf8
641eea2470836203610c00ac2c37e48ccde44e8c
8d555e54adee625097d0840f123e21e0ad20ca27
f7f1d213023daaedf8c8826993045c73a704af9b
0875d5f3f10183e1f0b2c70a0f3adec8edfed181
5a8416e0564620c5854a0cefe782151417710930
b1bc69fb5b21b65be26c69c6ac80ad885e2cd90e
7ffa79fa9026904f01462bbd920674f3b8a11c12
f12cb49604a74635adff35a6319f057cfd466637
982c8e463348dc3a5910791cdec2f4fd08ff4f32
4a03ffe4ce4ec9334e2d5bae3c29fbd44ae09f31
8b41c04ea3d37ab454552b159774d1dc9947b1c0
fc60c19c68734e0bfdfd1c74f1b2c42c78b82bee
d7037833174f94e273eded4c973ebe58ff42ce6c
4ee48bb7b2e496bf11387804a3bb79c79c410143
721f2ae0d6811fbf56305c1e8921ff8d3c358286
7570ed9c77896d40cb0deff32b40160c83323913
b471e1d016c8b660c471785b792d470b426cb555
5afa074315002cc029414518723695beb9cf564e
55d868e580f4a50a007b4d9edc671e28e5da3ecb
918da2958cb640f06ca084e01672ff40cb9ea435
4d71ec7a7bf41bed90bfc48a64cc8fffde4eb279
7fb7b16790895127fc80ea3cb5b30fe43db02750
02f889869a7493cff2f8c23acd59aaf95d96eecf
fa9bc553629eaaa4b11587d4809ddba015558f8d
af21afb1ac0721fc1021b346f528c6b0833fb224
bc5dcd7800149b12d891b0e8e69dcf0552c67e14
12906572b7753457b57ea07bcdbbee68d4dbece1
a02ca3c3719eb34e8d8d521cbd6325871cfdf240
5c8c63622dce2c22168b3e666e2c798c97532596
8cbc4490418f30ae745d4727e8f9b4a584e0571d
0b7cd994ffd64c70119ae6df902d43013fa4cbbb
167084d2920e0cef97d2e7423917c271bda2ad5e
4b8e25121cbb761c240ad39e832ea52af897002c
dafcb85be825ac53a1977fa7b30a203a99bbfbdf
b4d54d3032a83e7f3f336d0221529b27a93ae453
8d27df35e595f7f20d67dccc7b8e9e00292d4aa4
713b00daf5e899f4e34d350767ee4574087f5560
3797f25f9dc5510a2714ed88d216d8b5a29f9932
5b9a3ca4e99fc85511c40719398388bb85d5d462
265ba7e8386eccfee989b02941a6fc9f38696b6e
37a63fe13df1b36ff0e5f53a636e32125b41b49e
6c96cf58ecc041238d18097d71a62e9de95fd321
8e3b110c4be659bd4acc0ffbac320c0b6ef4b535
d46be305fb0b531b0b1598dcbb9d0c9555fff1ee
1462c74593b138758fac096c9a26a69cb8e37148
5eb63be74d378614fdebf82ca8b0f39141af6173
be92ed1f2b486c4855fff687ed96856901d5eedd
62aefd3512ba993e58a695026f850282e18053df
ce95e2c47711f4533fc0b2cc4c74d62b18875671
2fcc4d1ef5b25dcde3adda61510415eadaa43d5d
9a694fd4e9dba38b5c3de1feacd46c456fc5f4e9
f2a9c4aa901212bd3c87522dbeb9e59fa1021fc1
7becd7b801684474a02b4e981cc57951ffe3f2c0
d0de9efb686a5e27ad6aa517a9ab4f86031c6cf1
97734855fcc0a246dcd7f413af9753410529efe6
a1b603b13e36b5395ead5cbf9517ffc6c1cf9066
26357a19a932fb00fe6a5587f30c5659315e7bf9
45918d9b231cb09773f1b3efe41ce6525bc43ead
23f949e2514cb196bc94215c4197ce1a1289a88a
8aa477fba0af4a4ed996d99298a97cd86549b23b
d2deb1114e4927fba301bb8bab5958e68d0c456b
a6a5dcf333e934b28ef8e2d8edf5e8090137848b
f30fb24079dd419b143fbcbd54ef3509b5bbb1cb
87f379d973e2ad9d0d129671bbc29b476f4acf5b
415517c2bea1e22c9a7e2896ba5df9b92937438d
eba75c1f4054e4f6e25f95bd2f101ba8d3439c77
b3c08b6754a24c6c547f2093b3cd551b12216d20
c0396420a0c5409871d3d18f1c0469249984c852
598e07a58ea2dfd3bbdbff4f6a3433a2161d1235
d4dd7a7717ca212902defae6392830fadc35af5b
4332d6eda8f6b3ce73571225409a07a11a856e1b
a02ca3c3719eb34e8d8d521cbd6325871cfdf240
5c8c63622dce2c22168b3e666e2c798c97532596
8cbc4490418f30ae745d4727e8f9b4a584e0571d
0b7cd994ffd64c70119ae6df902d43013fa4cbbb
167084d2920e0cef97d2e7423917c271bda2ad5e
4b8e25121cbb761c240ad39e832ea52af897002c
dafcb85be825ac53a1977fa7b30a203a99bbfbdf
b4d54d3032a83e7f3f336d0221529b27a93ae453
8d27df35e595f7f20d67dccc7b8e9e00292d4aa4
713b00daf5e899f4e34d350767ee4574087f5560
3797f25f9dc5510a2714ed88d216d8b5a29f9932
5b9a3ca4e99fc85511c40719398388bb85d5d462
9a694fd4e9dba38b5c3de1feacd46c456fc5f4e9
f2a9c4aa901212bd3c87522dbeb9e59fa1021fc1
7becd7b801684474a02b4e981cc57951ffe3f2c0
d0de9efb686a5e27ad6aa517a9ab4f86031c6cf1
97734855fcc0a246dcd7f413af9753410529efe6
a1b603b13e36b5395ead5cbf9517ffc6c1cf9066
26357a19a932fb00fe6a5587f30c5659315e7bf9
45918d9b231cb09773f1b3efe41ce6525bc43ead
23f949e2514cb196bc94215c4197ce1a1289a88a
8aa477fba0af4a4ed996d99298a97cd86549b23b
d2deb1114e4927fba301bb8bab5958e68d0c456b
a6a5dcf333e934b28ef8e2d8edf5e8090137848b
f30fb24079dd419b143fbcbd54ef3509b5bbb1cb
87f379d973e2ad9d0d129671bbc29b476f4acf5b
415517c2bea1e22c9a7e2896ba5df9b92937438d
eba75c1f4054e4f6e25f95bd2f101ba8d3439c77
b3c08b6754a24c6c547f2093b3cd551b12216d20
c0396420a0c5409871d3d18f1c0469249984c852
598e07a58ea2dfd3bbdbff4f6a3433a2161d1235
d4dd7a7717ca212902defae6392830fadc35af5b
4332d6eda8f6b3ce73571225409a07a11a856e1b
edf789321a46b419b926a07c1584f30a4177b489
a898e67a452df0d85bb5f3d5c4bf1f968adcafb4
e2061f45973133aa3574f5e9a83beae2939f2c89
edf789321a46b419b926a07c1584f30a4177b489
a898e67a452df0d85bb5f3d5c4bf1f968adcafb4
a62a0c92a6e58e2e2016ffbb63709e85ca7ce0b3
7e1e367167fb3563828bd427f5e97129bb4df2e4
892a8da3760e29ce9a0f94d1dae5077e3791b727
b8582b48d08f62be317a3f072c162c7a50ad1af9
d67d34e48db45bea67c82755bb550ff22ea16a9b
a21dc4e7afac023b149b0f1a039048e7b179dfca
50aa39079ed1c80bdd1ef5e8003eca7841920ff8
9e0eed2c68144146f3a0ba7c42c8c75a3e3afba4
c33d0c97ee36846223bf5b08383c10d149e9acc9
75aca7c78a4158b60b2ef64ea6ac81adf41f6ee2
e02d26c915bf0110cc87e7fe2aed07dc4fdcb49f
5b00ab5bedfc3b131dfb2d3391d3201d0de20651
b221d883030c8048fe585f019517a036d8e74d4d
a9f7454ec9d1741bfe6043d536bac0cbb30e37b3
a4cb2391a86ae549a1b74455d02172eded28c4cb
48155ee9c5ed65b01d5d6dd548e295969ddffa42
cc2c760417aee49dc4a9501db3aba19dc8c077fc
7bac5a6edf1eaad1d41b2e4c18945c7f0c34cd57
8816b4599daf06b7f2309c56a2df42e54987778a
c23210e72407d6c8886fbea6ab861589485be89b
034fa9b3ca474ec994f774f0d08dd5dbdfa66816
995753f41f4317f4123f7a4dbc71d9724a906cef
21155006a9088b2d0dfece1039ae5bb0b4d6d01a
88e70104f1335c9726c97d9dcf6bb6b9d9805f2d
8142ee527949b097e8bd9226a4acb83cb78de1db
6cdb2c3991c2b61f0521b6fddf8fe54c11a9c786
5d9890222a5fba7ac0043a0cea30f2429f826985
341916b25962e0321b8448733e570c07c89b4e1b
ee22f1bf1d048f159e673d8cf243eb46b7aa4aa4
94e80be894fcd32439c3085867f8914a16dd22bc
dd0be793180c2cefe2292a8cd4f83be52b7542e9
ffaba94a3ecf3777e202b719295a3af6b517fb21
0e6399c65f9d70593d195ba40d136872461981cc
711c6bc926b9a406d0ddd5cafdc3317ae6e27d75
fc5b838b67b98cc004c2c9aaac9562aa73641f49
3e3988645e6f011389a0783a98327d7ada38fa11
2a463c85d6cf5750a451724d921980e6d0c1bfdf
5d0a76f49efbe6c4383c27a8d27c3116a3ba0cd4
dfa77d99fbc336cee502d20af7afc2e78559b53f
f126835b67f102697fdfcdfdc035aae7de931211
61c7920d51ab2f07f6026de3f81ab156e0540899
28cdd038f68aede25fd218f68e632fb531f4b24c
f1a1808d56f42201911f8617257bab3d5c067760
dc0f13e1ea3c1e1427b18a4cae2303b72fdbc37c
5c1008f681955a45668164665a9d4f825b2fd919
c6e4c645044ca022ada731b6c5c30558b5758427
d3a9305804684fb9712070c8a7b99a080b2d26ae
b1992216597d122fdbd29762ecfe8c128490f7f8
511983db53b6af416b443f768708c3bec5ee4996
0d8067dc4f8d7bf42bc2c0c10c526cb4b8505523
8a5f795d623e091bfba856b49ec04a9fa88caf5f
59002054e8aa967b2173501b7f2fe6f2fc7642cd
c69d9fbd4b6b65e952c4ef5e74396e02c7eb7b59
c7fd8edb50e8612c10dc6ffc3ba6eb5120e06359
76980e254759751ef9e7a593b702d08e6e7bef0b
f23336ef1299150855b32a8634040392877785cf
5079397feb53569d0d62507d926a12784dd4c201
fa2904292da624437d410522c579ceff068ac60d
dfaa815d1e40e8848aa9f1818d7c6050cb1d7d1b
cd9bd46d66b4ee4ca1b667261fccdd591064625e
76976a6b2e7612e5583bd0319146687cd449c8cf
fc8f6bfdf36c58261c19aa81026745fb28bc0562
63659d79e91a48b339b2ddb31cee84f38159fe8a
79e968374c0e5481bccc3454dfbee1ce0378fdbd
304050cfcf661ba3721298429a71dc9d5e7dcf05
37084a71b8e503a808e7ff27314f0bc5862de3ed
6d57da910b5de0b1f413d737c4f45c5a1f655b2b
f05a5be3866b738857feb5ddfd98fd8b5e825a4f
5b82f8cd141e67473de07a81e868bfca24a5a71f
90a933e82608fc71bd576329562ff296f59cd1a7
b07e22183abe3138acccac9a41d03c563aef8788
349a2ef2770c9d86be52adca58ab34b9047dfe6b
d8eaec1ff802b13e3f5d20d0ad7c358eff57f120
1372ae13c98b5e87051f7eb24b7470da783cb8af
21385e73f3682cb386bf889ecb5c824ee9143c9a
6d08decba2362ec363c8b1a8c97b3f2df6482e44
b39267626e01312fa21a17d77a097be0538a3f76
e918867b2560d65ae796ee1a319ae909537bda4e
8b9510e83addf1d660b343ab2e0fe1f32194835f
648c50dd5f52e90caaeec7d288724ae175bd3a57
811fcc2c45d35854a095a4360620f5ab1ced4f8d
978324d267fe25c49364f2e192514ab745d4c44e
f486a696dcf53748807fd02baa876f9b2899598e
3338640620a8900778aca3cfdbb9cbbd383f0297
caa9ce8c20c86c52763b1913ba02cd480f2cc024
5fc9061a739556c7e36bd049150ff41984e062c7
9d9400881c4a56b09a27e2e8d3bacd0163f6ab3c
09b52b85ce82272962343743f199285e40a1a7a2
912ab980b0938a670ff461fe81f8954540943e8b
c74eef5152cb16b22bf7b2632385b08517d7b5cd
ad932f742d663aca806b433918a8b6ba30088830
82ede6dff6a3a3b9b8b412804107e689228d6ecf
d3a5df4a3a389e0ac2f28ce8a1088eba53b06a46
16b7bf67db5694ee721855ea4f977d5c033eef39
cf4e9224e65339e56cf5047eb76729a30439b035
9643b672aaf504d963c9d9a588ba5445f6dfeb6b
55e474d66aa7b43ef858ed3b03f1b457196379f1
893815ba4897e202758615dc037a38b9a42b024d
4ca9de424bd7f71cf8b44f6c00dcffe463e50cd7
eee47635b8b2e7ca8e5e5e2fd8b006c3765b821a
efcf573572d8576f26bcdc5ef8f0ab260f235a98
75dd033ea263ee52dffbaa108e98cd2b2ba42ef0
a27a2a0ffc3396f8b74b4dff43bb3ee61b108ee3
879b09e63a1c7c8b4e49941d5a553d8da9b43dd1
cc16b47c93299195738c272f51e344451f17bda9
b1fbc8a99e3537914ff8d94c85dcefee22fe49fd
1fc9a341de3042963c861387752b5457cc684040
66d0142941dc1d47585956726537ec850df4d62c
2996a038e255cff5f1a7d21a10df734f826588a5
7d4b24631efbfab5a48bbadca2348b6d8a8a9e01
637105681229cc9d7f281b989842b2b2b0094bdf
3b45f5602746b955ff20e74216c18ba0531d0c1b
da6317c9064fbd73aa634fa0e7782219f315fddc
bfd78cb22aea1ab82cf360b7722e8f98332567b3
e24d75e5fa195f36100cedb13ddc038554495c57
41209f6d1861b3520f5f2bea6d99bffe3f364c73
08bf1eb1032714f4cb102beaa73d5a71e7f29a17
382f49b7f6de41a7adbac13ae8c9ef0662204b9f
47ca2357bc40a91e972325561dc57834e166d7cb
023ab25f839d82b931aa481dae983e5283b4e8f3
0499b9b691ab90f3a30ee2cfa7158a183ea28ae7
df13dca54215d7ca13350925a796d148fbe69a48
059b5e6326af56579792c905227381565421fd2f
22afe16647673dc803b99286a0ea3a768945b82b
b6499dcc093c7f4c5fbc04cdf92d524881dd9e65
7cf325199692770c0e3b10f7a7167371d18bdc19
f56b2bfb36d86d2a7b83951e6db4f64df74cc096
9f46393a2567b3769adf75c1598bb98abb316c42
939d46e43644efa21fd280d33a43ab6080c87ef5
c1be9ee5c2b40b565f696a60d6dc5cf91577b53a
7c5baae7552c0711f37aceab2dba1d9d3558c4a1
0f2d7ce29bfb20ffb8439a8b6441128da3b224ac
8fbe4afca80bc528796b5aa4af9f474309e2457c
fbd4fcb5d675b2e505b2c59cfd4c97d21ce58144
850bab1e25596aad70aa1e539a30bd6155b0b213
70404bf8bab4bfc12fd6af8b4e63f560b2a1e4b0
6bce435bfc97eaec708680b12b910321d1ca84ab
251a5126b62d63799cfadcb3f46709c579b79e84
c7b1d43be31d3feb3c63389f8118905dccb5706b
5ec96c6e8a9b17e88fd2983ed0697535880cdb4e
1b29852bf65ec4418bcb9e9662d6b27893506158
2cd1736af3c6ad5376913fe8f7ec77aad50e2000
aadb2f89fa51eb17c1f54f7dac7cf45c48e571c4
d7cbce55087a70bfdd6dec4198e5d59677e628e5
31766d1104bb941daeb7cb4c89f7815ef7514891
523722c1ee72d80e4e8cd0f2974eeabdff695908
1c0b4afd25ae3bfa1c255f58dcf9696da00935d4
44e4d12062bf0406130eed38c276a5c8231ebec5
cda861d033eabce0ee71c347219b357a470ffcbd
028e340eed3751f7d2ab2e23e58477235992bd12
1f1ddb23df8fc07e0817145aad2f1737883acbb1
1adfca489a6b97386ab0129081d393c6f4709b5a
fbf21eeb8fc2092dbba94fa74f751b8f5ab7ff57
927e904be647e99b12bf01c39dcfcc29f6917823
8538e6dc5b9fe41b66378ed2adf1fb3b0c37f9a8
934f3ca8cd140841103b6e160b43b40d4018a2cb
e923210cf0dd2af67a9e8d3dc9b0bc62e5208f81
f2b77c112c68b61a728765c287cd1b93228982ee
d6a73b64a6c781b563f75dabb593ae37cbe78c73
a6f9b3a6ec20331dd027d99d659406cf0023ecfb
ab88ef36d3bc608c3153c75fef66c25119f60f0b
56c4c87ba93c9930e68ae481082b087e46152f14
8ef4b97c0cee13d09594895cd2cc59832e3134b4
c24da1cb471339cb66ec8527286e833b8dab19a5
3b95be03f6ed551bca92b3a8d2b030b00d38b206
c7a96b715f6d2a53eb0fa86f2230652cdb5d2077
10b7fb1b33dfa16fd1f7d34e521e8605b44165ab
301653e817d1165a9afd1acec7fd8fe81ba61531
b10f333d7d00be561d2c61a5ec1705ceee6bf2b9
50667f9690d456cafc6c5be757f67bb8abb78b6b
905008525662b7139d936c57aa7faff949881244
702a5dd06bd86acd8fc23a0cb20a9dbf34c7030b
2527f0a15baece3a2e3ff4acecb87c167d681d44
17e07934d5312846dcc944c3b84f4c2741b731ca
e971ecf69ad3167124c6fb89d58394a6907ab4bc
7e1c783c1d5d724e87496b04e9c64734e9d64180
7b932b8d3b99f72885070aa5689e078d15541f40
f1263a841b512a79c499ce5f700a2a28955e97ff
c3bdd2564fcbd881078aa36bee894fca9bf9b58a
4a0f08e0db95db321e0f06cce0691e6b79328204
14e900095855c97bae977f3b466cc1d621fdc6f8
831a7bc1848d079225dc5b7687bed6334568e5db
25dc0df34f5a9f2acd119d736bbbc73be9ee3406
35759910dc851637f37dd9d6fb3b0d2a21e51bd9
241a0b9fd5a585be4e793a99c53d1752f7979f9e
c8aad52d8084cfafaf357fb4c802d89ae88fe2f4
710e28aaf4ebab8fe3ee66804aafaae689cc0adf
5ee3a2b47ed83b710e00b2f174b888f0d650b96f
733020fdf40b90356c0e918dab0b59e395732030
8c8323ccbd5f33bb0659a0be46ec145233c7d47f
20a45b38dffe8ec42568b7daecbc2aedb42d8103
24205c84dfb2f371510d4576e06ad8d9708ffdfa
c7612b46ade643a1b1d25555a661e104b0017b18
90aa0b2daa4553c54db544a8884741340ac271f8
11624b64406b77272935363a55ebf860a81649cb
8185548634f35ebc5fcb52287004a678acb61c1a
c4f336c3a12b0e52da939f9a4a56916e85279b76
69e82accd8e392303c25eddfe61695e462bfb789
31b04935c9320de4a8cfff1ab6da621e8f96360a
afaf728a01868d87f902053dce7f513ef2892c99
a968fbef844d94b2bae2157ca7eb86e7f08a4fae
c34e5fce85741d0e6148021ca094343786333cc5
a50a9ce47f42e193f94f347a3b0aaf13743d7de1
057ebcfe791b00329693a5ceccc81a419d5257d9
ce4937b01eaf9381c1b2d5bd61ed5fe9cc1ddd4a
57dfab567428e7e4a1d329fdb9f7310ba35a1645
ac489d303caf97adccc6c0a05ee4dea844940f20
6314b1d12a1399202b4db3f82952881b6cd10061
ea7856e4234631a03155687fcf121e5b058298b3
cf1ac040673386e187a3b36263792ae9ffc3c247
1378dbce2add8721c9296230fc1c3f109314c478
b2922e787226dcedd86a8188de0a177de3e3db40
24730730c3dcba158c2df7a7b9090f925b6f5d94
f1b7c20c6dbbe7f443f93446bdc1d69703373aed
7d3c0cda1efe5ba904ab75a7b26231f9534e0502
a86b44c0cb0ca5e5713a20fb8dfc955ee4382a2d
338d91c4322f737532bb2770aaef4a638c98cb4e
10fa63a35c794c3a40a42fd1bb990a13cc0d67c4
7a805be9093abfce88d4757f163625561ac9ec79
27e676478975d25f3a1fd5d34f37afad932787c9
faf0ececdf98bca168fd96e68bff77dbecff3d73
2e26ccca0422f4c83f39424c630be71f70b5d55d
d272a0eafc445f8c525fa302d082d4178a1395bf
0cab78f1570d0697af32e0c4e64d8b25e0165f4a
2c69d6003f005c629a42ec89b98e0f0622bb5d49
50c1f18cb79a2f8d5c0ff10e6d5f4fef96f3b680
8b575f2cd33c5d9efc19c0802f2b4c36570650c3
37aabfa36c927475bb688ff572a8ea26ea2a6aa9
fce34fb44aa520fed40385d500bf455da3c94c10
991ca24958005bd6ab6449c015787a3636c9c860
8f28c7d8db11fc4738d16a8ad4c656e8c9eba5e6
76496aa04be51d0751886d4904d0f778e4baa886
e54eccc0247a0ad20833edb94af874904ffa9a5c
f20255e06141d0e1318d5aa21e626c6d6a649b93
528019dbc26621f394b0cf848670ecb7461a1b03
5c65557207320bbc53a83181771e79dd3e79a2b6
39261c70af1d1b836d8fc00ab66787db48e43b7d
4b4da7ce3cefef3eb3d42e56cc486dc3b8707fef
f66084058e2c03cc5b76106426bbd146bc4da487
0d8312dcb21a1028106a86af9f54bb1de3947949
4a15ae7aa48d98174e7374aea4a94e166558e15d
67ee37e72c41e5811f912193ffe1afa075a63b86
fe563fad98d3e7ca4e37bb2bd475dca5f6dc3f3e
c47fe01709294acfd7ecb47ed8f0b140d0eb248f
ec1e255990e3e34ef4ec81a37d741b363e1ce4d8
23485362cd30d2c5f625c0e12ba72f260f20273d
97d553ca6ddb9ff7bf58683015fd1e66d26bfed5
b87f93a889aaec036335aa06de11a5a43c510c8e
c613ea2209f35e36a3ad2093414bef2e7d6d5839
974be89b21cebbb22c9e0664576bb9ac7024adf2
22e97cfa1793d19374a2e85c2e876391f4be7a0a
fddeb4fb882b7074f850713965842093e6fd3d1c
7c4b017360bb20fc44cc2a5fe454664057a03526
c4559ffb1e58a78a4b02f2fe0a7853bd77763bc3
3e4a42ddafa0b0aab82b23a9a1e8dc373069f37c
a726f8687075d4e4f268ff5cc03d89ba9ee226a7
4dffbd74c6399bb3483ab38f282d33d085cf7bea
c9967d375933b9240cc5712a83f403fb4f015759
61e9a67b134bca9a03971cc32cf6777523d2da7d
86f1387cbd958e7a594036a42434808ca9bfcbc1
6e3ebc7e42c473834706c37455e2b0b0cb543a22
996928c330a4cd0853ec7703206e4c15ef998565
e024b7ff0bb18a5e093d0c707643dce1503d079b
4a7266f624996c4c0d14cdaad8bdefe86b8d806d
059d51b9e9d447b9e910cbfaf5c6c4b9a8146914
5569d7721fba1ff226e1853ed569c4b6fb356117
59abea26d2bdd8ce031cdf1de602094ea8041b1a
13198dce2405995425e4abb9a8be605ba9fa7f2a
bf101d9715a596a568bc86093602e5c9c9873d3d
f5c81a5f65ec08f8505ab6db5a523a2bfa3e3877
5d1a5f068e3495158b674cc8ad650b7c331b4c51
356342514233f4845cba45e7c704707992ed1b79
7bc48c21ba9db93474a065742e4182a6e97a3111
e1acc903288558dabddadf4b1a6a32a027119e65
eb661b00736260d2e4f9d25354864a0077fc3e25
6e0308f592093815a312e75249e75d85b5eab1fd
e01a1c9035fad09601622af8e7481d944c849f1e
56577ceed383952bdd552968b7fa450bf09ea0b4
6d434538f78c74f5733c5ce2f7b7149898646a1e
891ee11d4be268f9597a931fdce4da275c93a0a9
79fbdb2bee06b9b67f217953d45d3de2252cf873
f75fb6141cf154162a7a3e1ee7408836177341c2
3739570ee9975c0bdb39c64bcfea061a5129a851
8f84898286f1e7f0d481e0bba2a6c73b0312075e
35933ec11b196b4d1227f2f957f16cdab28b1683
d2154a3ecbb910f486abeac6cfed1620b9cd9b2d
acb6fc9f9186c03677eb43fc5e5cc7ebbd64be26
7ab1d077bf3f910f5c5f74f7b87ce407212e0a89
b0715f8eaf18af28d0b01d42711ec629294a737a
0c057d163e3965f193e26290c4be0e9d894bdab9
28ccfe384ca2915cbf2fbaa84b7138902aef71a7
2f15446b51e68d3d57ad272fb7344676b4ce4d9a
a1adfa8495be87d4474b115bbfad4c6fb36bf401
b8b774066c372c626e8151994dd95202bd5d16fb
3f9018ab8ff6cb03102457a4a564c0ec960de38c
a09922c44ba3498dfc0374e33ee612cd5490ccab
71c775a220f613bea20eb6c04667b955d145a6f5
5fae1c8507d2cd82299a6d55e987af6d8ab21121
9318705fd034264997dc36ada243af21a624009c
35ec12d4917d7537a8b40c3c2741245dac781c0f
a4a4df649b6c9c7f27f1d7caab29be1220eb3b9e
915449d24a95028c6b5b7aec56b7474bbb87014e
8e8c3ea59b10bf9624aca51e6c19a7173e233e44
773d406686a82c41c3aea59bce342a65fa185d4c
f4f7907e139ba3ef557493f0c7afa12f0859a869
9f4c1657a5218f6c895f6af74b9089e284245c79
6a7008423e8afe9fdf624e1c07bbb0834e962a17
56f5ca801529e0a7de357f38ba9093760c4a036b
b3d92b3a065366e575470e5d0a8893c3b0265e6b
aecb8f2270173eae88074bf287a15400fcf5e370
21c3fd11b1c77aa9369ee6d51cc339c215e4a990
6272b168800f179f9e5bd758f69776d30dc738eb
a48c02b8134ec788ef696669bcc5f9cca2e59192
e94ff72ad59cd937dffb7d3f0223a219f640ac66
c73e61760a7a8daf718dffc98dfc9af27b40a0d3
606029820370702d9b3d69151a04ee0070286bf6
e2b9b6d733c83b371627e5ec6f185395af056919
eb4458f0dbd21940a05cd4dae8ecb4b3b4bc067a
945e86aff5da4acd2c59df3c952738c4b9e3d11d
e251d3388d721ad478e527660af3d3c386143d0e
f4d2b044a34b4902cf1717e190d4a8985b363c4d
34d5e458abb4c3de3e97dd366fc13c0d99304264
905b1eb2ed5f4986723543f45cc813eaa342f78a
186275dfce3b02ffe3d06ce5565cd1944150edeb
cda59a03573223bcf5fd14c60b6c1a25970724f2
8fa89f4215e28d723067bd312ddd2bff7f97ca80
810e7708a5ede93cb89993d75b2b05cdfcae78a7
b24dc8983f1a24f3dbd54242503ec72b7f3d54cd
c43bfb38494bafb62b0b133d987bb93ecf206dc3
ff6badef8a18c8eaa6b76aa6d23951aee8685e9f
38bf022f3ee8998716900f1d79777ea31fa16c2f
7362986da3e95052d8e9913bd10bf4d20b75fa23
d248d2d6dd34276184adae3d601dc9dd3adc7f04
3d891cd1d1c549c6bb3ceed7452fd67da43f94b1
4a600613d0d8d4b0b58d167f487b0de242ffa066
5f6338cc70a8d64bc142f0ee4413ad417afee213
49828a05631f35b87094ae35fcc3c96f67727244
1e70b05118bc66dbcc29f07213123c8a3e22cb31
6e72d5eba9716b3c705294dd759748c7eea96b75
f645ff051b9bce6ebd3ad55854bea2b37f3f1e76
d18f6c25c871e429a4e8e6827440aef320a52e67
713b72a47989654278f4daf6f0c4b64b6b4a5122
9b383f253cc453e3592cc3de2073f3d01c1f55b7
2b5f869879e7de77904a14f90cd17a63b7a35832
c63ebe299e9598a1d02a3b19c4e38cc62c1ff78b
d7ff63a3a6baa1893d71b69719682cd2d652bf4e
b8bf3bc8d4db799f55aabd1b8b2c6287e89b6dfb
19829bd8426a16f0249a5d650c8bba9a26a2149d
4bf4fd5f034065ecbc78eb46a81d2cff2f46f653
3fa2b1a4726fdf6df4ad23fd28d491800c2137a9
da582821c554c403d197c3871d7cc843e0d90477
9ef843d15656bccfcec03c0d0bc59ad2280da01c
9e44153247a26811f41ac9cdb0103b1ab3d1e132
62c213d142fed00b97739bfe50b5115f198229ad
f1e084fb1cd73081628a28bf27b657ce28804fca
a70ae410468e4d96b70d9d0517b16cd3962e064d
54610d5250075f74f937785f502361aacd641d26
736d98f213626affc1a26ef61232b81f4c416002
1dac0fd2574101cd6c736bc8360d6a83019b9f2f
aef39d27117af73bbc69a9d3ef650a460ca13553
3b8f10d3a49b781723595ec4948b72ed796b3efc
580826573d421e038c476b1588af04c3d5fd6b8b
a31406dc1d350a0ad2f55d0b24f82b199340b188
a5afd87e5e976c0c6cef6cbcba5cb0ae81fb1851
abe5e116850cf9f87472467f3cc356b36e63f606
79dc0f3d331d9f1052b854f8d9cb28a7368507ee
39d27b26a4f7e3788508dc432f4526d879cf13cc
ab83f9df31f57d93bf0ba51905755059d231a9a9
984c029fe45411381bc3e9efc4b58c18af0fd131
1b32ca6e843cfb026bf52c590c3ab8dc6c508d43
e1db8eafc2cf3a0bb61133bb4582c43fe048321a
9abe4606d0352ef0853c67ed66692f2caaf8c17b
f363d5489af738316791b8477337aa5d6c5d045c
87d24f27dd25e20dbfb1a909480d0b87e594d387
6a38faffada22349fc03447afbbee5e70191f8d7
0116b75da702a306faccf6993e1417ab263d9127
b29c0d56f2852340c330541ab6735e37e6dc6765
cf2de6878106f68908e337b30ef9e10409c954f0
c3216017bce41d1118da7a932a4fb80aeea893ee
4f45d3159ef3a0d608210c211d28ca13cbbf4258
3f437160cc0670567acd1e0ad85f5574ef66d306
b49dc4ca7b56a7394fd0a2b16f20c1b17f06aa89
02edb3083b6979a401c6cdce458655db4230a1d5
991b434744b4fb35e6939d0d9226504aa641ce1f
37dabcfd9e7df462ef114b447935de3b505149c4
b960a8ea6965dcc06d6929a98e7d05aa5f3882d8
e885a6176edf716b9dfb95ae0cc5e4e61e6f5dad
760dc5d74c16349e12de70cf508af5988e43cbfd
2c6e4a74d06edfe6966e8aa1065b5650392df429
8808bb7aced576f2f36f6707179d2d895ac0e1df
e36845c50282791e69433248be589061e8039070
0f469b2e5fe2aa6e7e174c61d9f62604f3d832ba
ac922ce672e4a5e41a252e8f7220d89f100fd91f
aed8b01c613be9f2af0770684cdc2c283d891777
4cef3bf8876ee1fafcc2de7d0687132615440d28
5ed190ace76d60ece8c4c58f5726b0da96991511
afe8c9673b98cd5bf39241a03a657e40fae2c5e0
45249347c243c7514f5106aa19fd7be0674fe7a9
e615ce49280b99f8f5b433c492793cc34ad79a51
50e670a138535b397538ff476a0c2983984bca88
36a77166577457011ca80c9422f656c01732f07b
38dbbb371b159d1d2d0ae051a584b18560b4a378
54d144cd06c3d4fbe009ada3b47c60772a5fa493
2b49b632fdf679fac74e4f9d349181a03f7a2b18
e9881d52c05fc0df1d304f7a4c6a22331cc3d4db
2c505933d009f02bf41d084ccc1a513e891fd44a
c54e094c2491f197ddc3ba8c0cbeaee2828f9d0f
e759bd3d169cffede22e4a0539eb5f0fe1d9166a
246d43c10b00c0717c52bd3f640a51c6461b186a
f0951e759f4cfa8c0b08b81c50b5c0a1baa976e9
7e017d725979aaaf13bf900d675ae85ae19cb47c
daf6d7c4e75cbf59166a74f7d3026e7b3286924d
84ff834c3d66f296ed61ab4e2b14eaf8451fbf6f
f5f5993dfb7d9ba1b9e00d2de4d38fdbb309d71f
21e2e4caf3471137d193d53f99fbc13c97755e55
adad658c0a9c39da3bff5e87eee14104accf6eb0
e797054a2e20ce15efdd7294952fcba716d83349
3d3db72cfed830b4b393682270095c774fbd8f3e
d0e99c4543e74b0a9ecca38bdadc1676b64a6fb0
799559c0397aeaddfecf32d4e58bc453e94705dc
a2ba6b2a37c139f19d23ba650fae494997240841
3c1681d9fe2f3aff18c965ebb9bbac5f0b3240ab
d2bf49d60d802457f42e2291aa7ad8a9429f1518
82f3c4cb34fec3f06512bef98b79e6444e023c85
7151ff5bac4d35caba6b1d3e3e96d42a92ef7497
0527300712cdfe8e0b506d504a9c99ed0b6e5e4b
b7133d62219d7b4eacd3097188aa97dbf86d76c8
733fef739c985ffaf1b01e39365742779671ebc1
cfaebccde787de8d89350a9b088d6ed416a3418a
3ee3317f16107a7d301315e2d2044edbdd6c0026
12fc44ce0e81b1a70ae3cad5f3c0b0015b31f077
6bb2c488532a7d9a352d2eb14f7f8d074ff54967
ffc1b72db99df47ff0573bf333af295d02e7e392
73c124a953bccb43bd48eb28f8bd85d0171f9f3b
b7022d1ee0289a89ca096ac303bd3ce0089dc241
3bfeeba7aa13b1a895d9836b9ec3c1dd4127336d
38006f36d0382b6d86a25c142edb348d85ac42f0
5836104f8b824b515114e05937870778fba90de3
280119f6abd5e1ec22972833511779dda2345b2c
5fdbd9a0feb0111c258d5c30c73122e2ec2daa1f
009e8aa2830d0be786c97fd773b42e4aca2d4e19
a2d99fccb0db837fa9572a73b4434d35276ee91d
ab2d8f391e65f54769f6e881e8dda21fb541329b
084be332143eab545f428e2df6f992c30e1a090f
3e1eca1a822d6272b3efd3fe7d871f47328adb88
6f9228c030bd00df5c7480b4c7cd5c6144d8e0ab
d6eb92c1dd3883888609cd3a176329f02b0d686d
2d2ec1e36d5defdd15013d8afd8cfbf851088fbb
c37b20d96c26e1e30673970ab99f7aaa32fd1610
7668f2bdd7fe6d1f93d62dfb91449a1cd13f8f34
a93c581ec40af6baff7791c5051112dfdb793dbf
eb0e3ca6449a9a2f00dc9ce283e4c099c0d5a02f
c57c77af390c21f114ecf8243b17144548a85a56
f7ed2c71c21dd602a334c7e62d5400111c75f0ac
5001cb8a720566fee6a7fe7d68cc6a3f8dfb5ddf
ab7464c969032574ec034fe0a962fa36dfb896e3
cfb3c31c377bc57aabeb74a7489f5d125576c201
78fbcaa77e8db20440bce37c6cbe612406b0ddd4
7ce80976788bc05ebd2bc4e35307e0c9871c83e3
fc7e5415d8e6ba0ec7bc0c3ac45896040fbcc8af
90540a7c8a649aab3c4089df3369940d223cae86
f24e5d179549b776a2cb616c0649db350e8fa97b
73cedaff24f374f6b768d7e58a22f7c543230c27
ee07118597f6baa4a937b9a1aba2b0230f01c96f
66464cea32b205c19ef27108eff956aa3bce59f2
22ca6caff4f0d5a63f1946ee7be7fdd79e240b35
dc08cb40f50d606e3dffc974c5db496be541a90f
4343c41505f8eb473ec752ed59b378e594d6568c
c3ba8f19764c7a812170cc6f2b292386fa031fb9
4d3277196ab56d973038309c5c5d36e353353716
7b207e821657ed2e86f7b0c2e7e54bd0a9ac10f5
e8b5d122ee32ce0f3c7437202648a68e4086b00e
f845d4cce18b5b32218c155a8cf00dc88bc2245b
dca5a0d9125b8f8c257f585c2a6bfabd30409a1d
7deb535d17926b311881a481974527bd7a3d64d9
1fd6ff36bae25111420188d0379d5e54751e5bbb
e5ce13a480452eea36bc1138b33cfeed4f5b0390
3973a6371ce06d55842f0ffbf3d33cfe6c4e53b3
7b0b80d6dfba61c06812d4c541dcc30e623f7b7f
b299e16f90f35139aaa7f0feecbfbe3a4083523b
867f099ce6de59bd3961af02138b867263b379df
40d10a76d88e6bbaa15b08f3521acb083a9a9a04
b3664261329918955af3cd5dcf55c2529a3ec907
60f7f79e44a54afc80e49dab1c84f36152c42a05
2401eca3eabd16c96eebdafa8fe84742ae397ea2
55904d4223f30271c8f4ee9a5ed57325a2a956ce
c4dca984b232f470cb293888283753dc9bef5780
e010fe25922d759abf7e1d0bfcbffb7fac1756cb
af33d619bdf8e46c830991af39a3c1743b1958d6
01446245f5de081aa80033a16883ebcd85d0109f
46b034deb5d4c93d731c742bf27534102fa47551
6a131e86b465859704c6a685089b17d2a014f868
2b5e334156deb5215567c2915881cd2fc943331c
5cbc5cd6b61b783bfedf0af599de225e294c39b0
7ca6162ee5bcdea35dd99ee5506160bfb7ed6d95
54437fae713734dd870db03b8be5ca3442984f05
db3e9edfe4b956f070ab464d325a86d8f200c78b
0819e7c8fb44b413f7a3433adb3e2d07cccf3d10
7de8fc388f81a47ce68fa9aff71e01cdd0c9ea50
043f9bd563470dc8b584ffb72cd9c8f210a04a37
ba73d7d1362b6bc3c8d22bbc97b63f8cc361d006
4619c5f50706a7f6124835c16b6a6e58fa3b6e64
c350806ca28eecfed208b2ee160ffba270d079a1
5a227e21f5859f2ac1bdb7be548a29b6d74e70ea
d6585beb32aabd195b5eabd8e73e11368aa73b8f
deaef2a775a84463ed1ab73de67fc3e2faff224c
d1811c8a78ca39e8b94e132c636ad289684ed7b4
f23f89a03c2f8e198872a3d0609a29bca32c48a6
4958c132db860995a0210713b54c06384982d4f6
baf7c95a082cfcbd6a73f271301967acef15b613
b71fe23438a8f5b05531fc523c65d65540b97e82
a34051e56b6beabf3680ca615dec1e429c3c8ef8
8d399a1b933c38a92ef46d57ecc030526dd3f3bf
6e0a0a6624f308be48fcebac32ad8f4741e27d6e
cd801e2aea94b07cace949f611b13b2a06543fba
4f8ef38aca8c424877195494f676a426dea5f9bf
66863257b0ed291e079f251c49d900db448cb7ae
fcbfbdb2168d1594f76dadfce148874afec8a102
cf07d2acc210f5ca76febf2f6a50763d2c689b18
173b3913ec0204300307280f12cef5b033ec9fc0
a9e664e6c06d41d8e45af20479e75dbd6f0c6b5c
bc488ba035d83909919bd7a1b304773a79c38ab4
2270fb320663fd8dafc4a97ae0191dfbd97fc0da
120792b728e9f97c30edb8a318e50988431b3971
41b6fd7302cb17269b8faaf6e5a039d24a3feb03
1c293c3d898f02ece87101d2083e637b47465c0b
d8037b42063e725502528a5bb5696b82a5afccae
d4ddf4b6f6d84375862afa6e140c248f6e7d73df
ed6e9ae664b465d53b5890a66f187ebe4fe280cc
92a0857b0c3c8f9a8244e3b5a1f9611b696b997f
ea2fff2d0a8023c2c70f96e2461d1bdfd3a24074
be7f6c031c0519b706d4fee57955990018896787
7b14ae1d32bf52f1e465df79e7347270cf48f6d8
68406fe879f066979fe8a1de1c4249a6e51dd76e
5c9431482dbdb3bc38dd9ad89abd0a1d137d31b2
16e02c540939189973d79623e02959b547733247
c42a73d4c59b0252a6e6b8213198162682659921
b9c5d19fd2d3308f5a816853f75a51578c235740
b2d2f7aae7c0e1f8bb1e23ec23b85dda6716ea9b
62fcd6aec95f5d1be3394ba10bc88a6950061176
d106967363c65629aac5ae1ea2958fc8a9c38ef1
4c0e0d00405eb37dd41d434758fa2207060b67f9
67817af4b7b5e6f2262168a10a13ef0c78cceb3c
951fec0530e71469989a65cb64b46c1e415584ee
8f4dbcc21edfccc473dafc491984bc24d51a66af
72f9391bf670602ef70c6289d91a1fedff0e7bcf
293b7ff7710619b24f00c1679723f78d37570942
8b9484c05e7b2ee5b2a6d0aafd45a7f2624db798
9cecdd14965ef666efb2969d04dc1ebf96abf08d
7ef57ffadbe3832c10f1b4256b34ed13bc1c9312
58ecf568e6555d0655da0a2da7a3771eb8bc4f81
037fc38bfcd8433e65aaa15e9b3ff5bbcc2eb50b
0e83f954b3bff4e65ac4d5f76d9c2ce6c9868373
9e258ce9a32dec2a9042f7d925390f92a61c8b2a
c1fe1f82f74677a24f1eb20984cc84cb2a3ff239
03934a44cde17e53177b171bf4bf2b548f8e24f5
86b4aa447393b631b9d8a29171213c2ff3daa462
c4b979c8cc5d018516bd69eaf033f781467354c4
e35711ff34b1ce3501ad9686689f12315453a559
10c971865a6dc309467650260b03666981975bbe
4543158155d1716f3efaa8346dbe9d1254eb7572
8d868b9a57c0a23761ae18ab9f1cbb453fb94f7b
310f6e30af4fb1a0e2c527ddb0516f41a12322d4
883998d3115f135a2f808f85762c8cdf98b18399
adfa97667b969314b18092d9dd6582f25cbe54e5
271f7339cad024f0026bddd199d32c48e0bfc47c
d1baf8bc29942d72639919b75f691f8f8ac14c89
2aaa2a0cb928394382785cba005ceb056dc51060
2625982a59d7cd885692a3b8f5dcd006a03acfe7
0918c11de8432dd2c85625fb844f1b7a917b8518
549f0d90df35c7e94efadb48467d5c64cb3790dc
dafa8aac718137796d3a5cae2a227b7c5ae5abad
ef50947375bd9ec4817f5509523511557f018af8
49492ff45aea18ab52927f80ecfe59269fb34f4d
02d3cb52c383f55956c1382850dfe91f36b89491
d25055f8b4dc1662b1bf515a085a16620acb26ac
c31313d6981cdf7fadb6243401cfacf701ba8f70
8d72f20288d7f0ecad1ae110886ceea5ee09a65b
e43769edb302190d6ef0529dcb3405d6ed177cc8
852f76978be246b4a32685ababb733d2bb88c573
34d560d2cc237b6c5a6809ca02801ffd73393836
5f6992993e61d484bdd5b9fc070870e4cdef86f6
a206aa0895fc58b83ff6e860d65942b2052c2547
441eb129a2211af4e575e42973f1a31cf5e01b18
93869a4b1596fd89632cf91b6564523e81b1a54c
86557d9c9e259cf35761d14651a79d40274dd5c1
797ab84d1f40d7b3618f3c6eeb440c5bbcb3b1c6
3fee1451ec3588a0a8a29c24a422cf376f8e73b5
b24dec2ee5d1e5a6d05d178b3a192cc6096f4a80
785428a346470917330912d0349c89a88a597ef5
5db3ae53f7145c9881ddc6b82e02cad6538c6106
de5f63d6c35e98e34a786ca4e391337f518d8b6e
ba9611eb2c2e5714f06492789229578f1d4ac88d
a84bf0b3f42f70b65f00dbd9443ee6268964b59e
6e79b4d43ecd38380b7ab6ee07e4de54e1ac13ff
fff9faadf6b58b787ded2e2c9ac4881ceec60903
ba935db929ae709ddc75c3a3dd2b9a62937e8735
6177bcf03a56f06e9451d2b0df2dd2197a0ee6ef
3a83f1f5adc4563bc27335b38564dba814c7f612
b48fb66dab3ecc161661da8dc1e8f14227ca4eec
b63a5c5b76248ca5da6c4b488fc95782abe0f726
412d90f302df2494572f5e45d7017a799862e554
24d16e79ce0283b72927cb8f8df61a706e12e6fe
f98f521b880347d1f083e94f822b0f0b233d3860
97df550dbd52089dc88016086b1ab44d4000924d
ab2f3e19b4f53d69a745df083ee468ccd29d15f1
36c77e892101118ec21f02080ba4877ebff9ba78
532ebbff272a2ff539b0bb6633493fa724c1e194
c24d04d9ba87ffdffb9fd9ffd8130dd2fa1e509c
de16d510b3951bd34411eed3e165f244efef11df
cd0f56642c29f3033ca9b4ce047a922e01d703e5
40e4d7cf73af525ac2116f2b3e508723f87c9462
faaeeb9b92895b30d7aac67279f2fde315775d3a
13ef654634944f1636a4fc61e59518d90d11ac3c
662e52958c8e011c4b8543aa72a2570cd13ae5fd
e734cfe64f34e2094a624d391de6c366ebc9dcb1
b0e58a18c7b8fa9f838279e714a9feabd0c76d17
d6174ae210aafe1acd00adf8430e2b8f65061ce8
df6328cdc7c72fd1ffd52665a0926b2e03666083
38ea9def7d49635baeb9783423aa84e9595156c5
08a2554da402faf9beec76c46d45f52e430b5e80
df47fc41f736e645801fa204864b50f97c4cf7ee
d58a9da26151af7845b7c197fe352324d5ccbf82
dcc33e4af976dd9973175c6c97c168759734e346
824a8d15f73648b2ae584defc060042b6529bfff
beef92ccbe03452d609002542ef0ea7948cc1593
40eaa06734b133dc68e3e0e6063a5bd47c720caf
f1d9207b7b4a41a8bf56cd8dc2c823c6cdc662ad
d2b0f3f4e833b24fdb8689ce6415288a95efa37d
1ff1581bac599ad768cbcf719a21453645d3bef6
0f793f0c00ad45cd580e78e662e772b4546753c2
1278d47f65975afde08e9c0ca6b50b2114831548
abc9fd7f0257160efec7fdc7cda3d3df5a1a3305
9aad92db99d4292172edf88a3d6c5965959b0469
b2802e569deb756ccfda6b8af434c756595963e9
ae12ea7d2eb2c0201f12f3c5524ed6859aac59d7
e03f66d0503e7be35dc62275b34fb66614d2475b
a3ac4c1a6fe4abcfebeaddce0a2c80a0e0ab1715
b5808c84230fda68a9eebfb5f90e86bf3882f9a2
604be549e400fefd680862ba8298e6c3b13db421
302d5f8dc2118f15e0db56feb56b6ae1ba895333
103623c820684233b6ae75004849821bd57126a0
a072c8162cfc3a9af96a9ad8735e229cd24468ba
62738494120aeb5b16318aa9384713ef9f3438b0
bb3fec688370c1dcd2191692086f225be6bf9ced
0269488fa5f40ecbad9993d05b867ceae9993015
69b67e89fda1912a55fd95a7f098e1d4d44c4b83
4593f60e656a1ee45514b81a68238be9cb132ab6
026bd150b101258a3921c15d61a3190e17e98a6d
808fb524d0c784edac0e7ac373e64b3116345bcf
4aad5fd7681c67ce18ebd86bd0c090de442791a2
c2cac02582afdc68448da1ad79ce8036fc2eac99
65a58093401392defef82560b8bd3d79c8cecbb1
dd35b157d0cc44baca05573136333fe5c080f461
407e7dbec6ca1c6c7e11a2ab680e86e25d1e4eb4
434a4ac904aaf1d0178048e1ec11c7d3f897bb38
746845a1637aad6c5786199a02804cd31de51f54
b6c2bc7869abb49b98d5aa3fbd03b42bd1bda8a2
63645bbfd23501094e53af48372d85a35b91bd83
d48b4e1a4bb770115ca73786904954ac92d13be8
715e3d23c60e194e439633afe06c6acce296a130
20f1336a6d9c9928d354a47618a8055d8030b8a3
fa7a301c7359abbcb9a4b35fb2579ebb227fb544
26e7743b2438ac074fb12c4d096267656d6ef024
080b7fd8c50313a9e59dfcd17273b72b6dc7f79c
dd35a5e5353bb2ea8769265cbd00b485fc53fd31
87a821edf9c21097559c4e1ee0db8cc341a9d7f4
e490c540378d84eba2d39442420a6bdffa53eae5
fdf0cf648190820220f4ceab84da4d556d61d108
5a2a511b0b5a03691da57dd64bc5402c22824fe6
ad59c45898addd1c21c2b3bceceb9cf822cacb19
e32da8b7862a5f59cee56e80f303a36494aa4a8b
b60f7f9f2508dfd79b2b0630b1c07a21f58d0ca8
6a04fc738be7c0e9a130cb7918de655da6945e5b
eb850ca3a9760cf7bdec1df5de9d9edf32eab8cb
26ca2012c16d08995d4929842726c36c291c3757
0e0f1c34bfb5ce342064532765d5f3513f9b66c8
16e33e2d634b0cdf692ba08b2d53b6f0569c341b
19883e4de626f831d12167e6b84753a2b358e3ae
2ec39c551ea9d409ff2509b6df254673d3571ffa
82005a196e1c963d38a7236ba4e331f512537aae
a4b30ba44c1ce091f67e4f98f97bf628d5ac4989
8499c5e6bfad70631a5575a57816121e7a59d25c
97ee6f91388a08a0113efa75be1368dd8a0d366e
6c3963a9523b89f2edc72fbf346f1c83d7e56c00
8d0da5847587fdfc87cc668418d5883b5493d7ed
b62273a7a3d20b9dd1db885fd32d2906da9e784e
011388a76afcf38015d3fccb81fb19f7e266de62
b95bfb8237dbd87bca43ed61dcdde2d6788095aa
ff393633143b6a31a1065391ed0f3ce9c2b0b786
0798f7f053da423a7899a49438e23a0843e6c953
e663040e0b9fa96a14b86e9fa679a49fcff120f7
0ea40ef62e2680a7b50ee03b99817d1c68090117
83d876c817e85d7072553b252c4b95bda234eade
f921dc3490dde19e3947d943a1e1092ccb6049ef
6ece1fc6c08405ce792f8f2e46814fa70b5e4bae
c5151f74bd1dbb1a316d30bc348afde8313d032e
6960b35ac03a7420445c23fa4c7ee67728302805
86eae9f9d8c9e7f779e4631c3e7076fca5a821ce
99cc88de11cf1aa3a1bf392fc33b80b1198a7200
d63dc1840fed4a2c9864fc60c00469dbecf3417e
cb8d0bf639403956a8489fa58816c56d15778796
afeececad0f92a80f4d9783d31cfa10ee0a6adfe
51d7cf2c0ecfe13c33312370e269d7f0a30623d6
512106d123ccfff47ff093f191afa3dac7ec434d
b69452fdbd3e7719a98f0a9707371e504f59b7ed
a7106681f656e1ad54b861fca43bc413e43523c2
2aa9d80794cda130df74f38a41fd9ba912ddd014
9d64581ceb64e3ab3d920ece8dcddd1a00e36223
1c16dbd15541151af421a8da94c1e9fa3ffe9c48
ce132c47d6253e284d6137bdd8df91068e194486
02bce6878ebd936cf521ffbeffc2849b5e4831f4
eba57a7fd9288a21300ddf2be0b36e202004d3bf
704dbd933f36619f06fda870fdcf6142ac648535
860c7aa5b78dcebb64fe7e2511146c5a164bd48f
f7b9167e0ebf24e5a7819a39e798955f2c550bac
0c15f74c52735a35f80f053500de2da89c2339db
87146c48affe17645c5fbc5356cef138e118657c
8428176ba73c44e5d93f8c428395974bfe95cc8a
536f05d69dd74cb291e61de62b4b1bc238f82619
36721415264f959b4511b103ac31745abd896291
f47e2a40b8dabfac1436ca94f6627b040773e0f8
9487a241b6e7a6f7d68ebe5e865d33ff6ff8351d
428f44a595cb1d127cf69d78bc620a3b7008b4a3
4da80d5200d38f8913e2fad179e11eafb18effa3
42844a4de891371c0a38ee6f8dfd9443de7cf1da
4843d6ae5c86b449dc5d5145a8a1fd002f63d696
8b48bd10a39f16a99fe15c85a7a175b6ce140073
950fdb944b2f8001aa45b6a486794e78b81d54b5
fd99e5cff4524a954ebe2e337086ef14973d2ce3
2fd252f3cc4ea26e17da6187588e2b7c1e5b7582
3201a226d4e190528e3d8119ab6832864d875cb8
de132d1ff11ae62c31aa6d47203cb02530988eb3
ef0018b1bc6856b7b1e200a8d70a4f49300e9acb
ae0326d5df314a261329d7c37fd960908b2bb767
7e5ab22f54eff5cfeb30f42692f63db33db26fc1
deff9330c3701cc34b0774c34a042575a36a1f17
23ce321e14d74f5d3422a8271ec4f6483ca6109f
091cd61daac5bc2001f8051a2cce4bd5e28fa8a8
7ed7db56a000f940c0de020d16dc33d0c7f2e99b
6af4d5982b547c9b07310064e73b5260bbf8479a
49d26a323dfb08efb59165c6f61ecf24490f5011
090ac110377a5d04524e3f4bdee51e13319bc07c
0a235f94a34045bebbe6c6cbaa0d544149ec0136
6368fc6d2eee0a2273486d8b817a528bea1f803e
33782161fd36d238a484da4e73d76f546198d61d
32d1cc772ea9092718a7e5dd7cb8d0c864a9ae37
4792c978ebddd25c570596e0cf2867b854ffe5e4
98cbc0def5fcfb2c98353ce0ef2cdf11e8e45d05
8925e9f67bdbc5e6c9e9771b2b6a627d96984d57
e20085f95616677388e10622bf730d471b10d136
6bb9607cd0a637fad301aaeee98c572faaeb1c7f
c8cc1f999466375926ac3a135043e6c2d9be0f4d
3209dfcdde90019f7f337ea417fc2c77e6c7795f
b06509859e09dc3aa2393d40616d0270b4748e1c
3d4b2ad701fde2b97d777c6666f9c5f124827400
62c7bc002d154c80d1bb7856386f2a44cd98d43e
d0e0e5b5a5bcee21559bf3dc804f5a84591531b3
42eb9ce75080a0d6160140b6a0a57fa13908c98c
bdc116ec0f25cdbe1cbf1b8fa0726479d155aa9a
0c8608ab76ce5777cfd2342d68ac6994a390f984
50e9c8cd0b7f5d822163b6a54ca57aa3ca2ef199
be16269c4f54accdd2d264054219147b3c5b2a55
12e071672c9b9066dbaf387a039498b10baebca8
1aca5c3fa50d7b460c6633dd7fce162245240494
c99c93e299c228476ef3182d490d79313749da6c
cca07cea19ef92493791597065a38ba5efb7ea7a
bf46b1c0a4992bb4db8f8c883afb1ca10257951a
2d5fb272188f3c08f4fd654c3269ac3462b564af
d4234b5ca801fc3c18e38f70b7470654ab883d9a
8de217ca5455d16ac743e992876fa48021d143f7
8f06d85e83a7e59073e298d6c0595edb42c754b2
1cfd0fe2e20afd14ef12ba41e3d01aecd7d3bd40
fc381a729501945f498f2d551baf1da0119558a8
fce49ce135501b28030cbd4726b28e21431dbfc5
55b2a94f80bb4a30e7ccafad53a045764e706c07
48fadf1003f605899c2abeb7ec6ab33b0f2b1c46
38fde954527741407b103dd2820d80d57e9832b0
0ed69b526db6d0bfeea376017f3c29e072057ab7
3add7c5a6714839ee307a055158f958b1d0a5888
33312658bc6f4bc9477dea91f5b683a13286535e
45c742bc345864040f25ed2d0b38d07e6e10c94e
cb53799e3d99ebf06039417f76e447dfd28872d7
bab81b32ec072994efb8daa4abd52b0d5ca3b460
c938dfe6780d9802a3cd7b8a5ed898bdb306e06d
2e7c150f6e9d95b52259040d460561b202a7472c
160e741ef8e0d03baa7eea350ff95cf89a08740a
5744d07546fcb3db7536ab858e6fc95f43592e9a
3509484a7565fd81fa02c0ba289b92cbec45e2aa
32c50cd43542fb51078cb61397d4f7a12a823723
50a284a17d589c7f951d262136678ec1bedfad1c
72ea5948118883887905ef0eb765b933c62ac1b4
14bfe382ec4bdbf9936c0672785759669a24b6bf
f54096948ed9c5dea22ee72373d053331f0d63d5
b5612fd9b9c6873e016ed4b4aa9facafea2a0c89
d687728adc462efba6bbe96e7d69e75039cd20aa
f01ae207ff1b53e5f7a2604dd8ad9858800ce7c3
a4f1a744dc79cc634415e34dd4fc1c3921d92d57
bcf9dd499f48440e4c4b08d8895d762d61423ca7
73b38b956b21742b4d69b8e6c7565b185ce9e2cf
517f7f169b3448653bb6d1f7e37b3ff77b2f5785
9156aa161877e6d826dbda6b51647bcf387e62dd
0bb32e82db8c6b582ac74030c4473bab90b619eb
58b2b689c1ea6ad699fcd71ed0aad6c7dcc9c74e
59a206b0cde3416e9b2b61b93bb0a262d81377be
50e4a0b03fee7027f1dc42b18a3495d4ab0d07c8
912fe0580e19ae5d6800d1933cc259b31a8c2578
cd5a95a34cf0df900e34c0ae35b3a9c18b6ab083
2bd29f82c4f7f676830b7a7213a419448fcfb5ef
ff621e57e0e8046c9d23a77a5ba4029ec445fd13
5d3a2f5ad1767b4c3cc6685c689b7e883dffff74
5927d98713a80e54fe8e7700c079f71242cbad05
e09dbf3eecbaad6c26b68cd2db782ba8ce317d71
1da8ae94768977af07a84899309451fd424e270a
eed30ad1e32b584fa82ca862ebf80f70fba0adba
60120acc8d49408bc3cc47fe25da78216491e787
7e58585952612a6fc5f82953596d3c599e99366d
5d8ce607666e8fc744a2291e61ce650437ef6d98
50e7c6ffb007aa154c170e0cf6a0c09073fea051
cfd4ed56fd2a163b68ba85c8b266cb236019a566
d50ef088bd2547db3a4227d16444c7479fdf3dbe
51fd4d23b3f80bddcee9ddb00821d0816cab81d8
91f9444ca684a0b2e9bd0064294d7f01b187b440
43557af997c82a1378f4fa3f73efb74f827a8867
ab58fa17bd1b806f7aa6a1f59027cfc4f09c0afb
bd651e49c6554f29ffa45757c788bd169311a812
ea90e25f876538d3e36097a09084cd4172c6ab5a
89a22523d6c283d2517a21a8b33e60e4ca148945
a8072789b2455274d91526d69b350b6a218e5eba
e34b039a003098f47e2dc44311eb090392becd9c
d953be4672fc1aeef236a15c4e398a51202540a6
236a94333ccd1cbb5954b9405d745805aa0e3649
4a7ba642a87691cf6ca4a70c836f29bceb9b4677
ca938a9f03ddcba184315f1096ddb0b663d992e3
882eb51fac2b3708ee680df3015f3135d7e5f59b
661d9113a9e0cab0d694ca1e54c27762ac3e3cc9
55ffdbb9fc7f5b57c257a34eb05344fb7560e86d
9b40adc74b8fe26f1af64a8d871866ef61f166a0
7834c414208007aaeb964ca20524280cfb592fa6
cb316f39f5adf2aa805f577e9ab7d38c06d75bda
3932ae33d67cb8dfb33225a3973e4b51814206c5
b543a7bc2d0e59bbf690d6260dd4fb8b40d7ddd5
e3e0aaa362473a1d4b9882144327c17ed13a155d
433234ef938449ed0821b88a9a8a85a2e01a4829
91c689f5754b939e98f713b534bd08f552e2f578
67f79edd3f17500f82a44b1dfd7745aac55c4eed
a54b9164ad214090d4ab0c9713eacffe92c319b4
b01cd000dafc306f910722a5c7ae547d7718cf27
27efc254134cac8c62c40646176ca803074c08fa
a8c2cc98906aedc321ca12306320a0a43119578f
8fc9c170b581c2047877e191ae2d713be20ef099
2e44f963a7c9cdff7f4cfef49a45eb96b99045ce
26a75c3d669190bd8edce7e6582023f3dc3e6e86
69230fb27875b7144dca2bbba0e3c98d0705f937
99497da10824664a0300e7fb48d63174339046bd
ac030a817958867467ca5b803937a5fe07466448
dedd1bbbff71e138fe5a9941630865f6effaa8a6
2c678bdff6149570ed94c9503d226fd62ad5d522
fc6c8916757e4da6fccfe65cbce9ff304d0441ab
6ae8977e2a5cff570a85452152befc52b625da83
eefbf535594c3e4615285ccfbd771e8c99cdd984
25f7cd967b9581645e96368e4b0407646c644a75
cfa37b15f4ffa80c208dd4e56c903c9cadeaf4cd
2d9676a9fe3cc416ec9203c8f2f89768d1519e78
61931acc1898bb059cfae804b55d3ba6c2b87e23
219aacbe4cfb98f80eb29db31f38fbadbe3071c1
8f92b268f4c191326a4469b2fa2b7a7a39855099
a98aedef64366cc54f37156a7c4acdd8a63eed03
f03c7b80af6127826fd3e3532c3a1b4f97a81067
328f7c4130b0e567ac3255158ea55823d4d30789
010ed905effc10a940d4fd4a8d1e241191433277
dcf4b5ba8dd53c6c890c70863cd6b24a8b90c3d5
592a0e968118c0fb4a54358ded8bd5e67843518e
424fa356987982740f56768479ae74da3e600337
def6e7319eb6ba56bb521f93c4f63c722d10410a
527122083bb89ccfec28a8bc507d7dfb7ec1834b
c191ad59c27d89c5045d5f2c36a40ebf545fcc02
69cdb734a7ccf116b0fef678acd29e26aaf41c8f
933902ecb53d988b68744f36d14fc61bb4a2cf88
b42eade17456e8223792313c4912086f92ae7f70
5cc32efa46344835f7709f00d0918d92a6290206
a693c2ea61bfb0f0480f8296676b0bdcc8502871
9936005014ac377b283ee763568408f55b891d0e
70463731d1de837b8e565e614351020ff0433900
74b084b7c5b39948f45f4582c8f4b8d0552866b7
44a8f3270ded8e71aea29deddc0aa5afc41a1f2d
e1a2b261dffec2f9da25a3083a738952e62c27e9
da90645c2a3a584865aa3163cb0f1fe4e31eb2d5
783578e81263dfbdc3ab97799377476f9febaf49
d48db9d9da7fd3be060260ab9aa07e48ca47dbe0
adb4678c989700ab74edf816c2d8bdf57f6f33a6
dd857052bfacb3bf20144e8b7aaecd36f9a278bf
bb7666b0dfeec3bfc926add36dd61a9dbfcbafe0
b259e3cf3f77da7cbc402ec37bb1097e2f3403a0
25fd5dcbd4f55ab4bda82cc70bef1fe049d85147
2ea246f02fe353abb338fa400cfd2ea4716710db
11114e87b701965ac1d862f1d3279ee67c035f09
327746779cc01082f9588f639a3581529b13aba8
258023e47ee9b22ba89860c1a4e17ba72a434ff0
ad81aa214d42ed45ba5b9073adde7d03c78ebb13
90de7e9c711c2d3ce4a580674b2cd85015ca0b70
f79f10a40ac8a2d4e6a9881f3f4726da3bf1e0a0
0f7b03757dca9488192e3e4213d9d1fb92a0ba1e
04d3429ee476a3b1438094c35e3eeec9f5a68e28
85ad812287433c136276d05ff82603d982785590
58d4dd896224a285452a054afdc22ed94198528f
a672135367b8bc7df52828eb4b95980e2f34856f
8a9c83e9c9fb60e27aebf6d859432d4332abdf21
86540e1e242320fa038fd7ba1486bdd144b89e23
c2d67e85e43828b397d00091400bf4ae88360dae
95a756c5d7bcc2d7686e3bbb1af554b8f8a06c31
9196c29ec70e2d8ce0029df08353664a7f1c5e1b
0f121b965995188055bd9b6697191d7c38542f39
315e48a12ce887cd68ff8af714d9f48e5dd8f24a
f6cea02320abc5a47a6c3b5649f74e07224acc4a
b8b17ae6a410af70bc92bad52a2af1a7302e53d9
bca1d9d8480caa312f914fb0b398d386b95abe8b
578b2912f4355d9f43990a5214593991ec68e2bf
28987ac5671cce4e8984dae84b0aa27018b77099
2c59aaa01631f9a0a6e62ce41927a1a87802d57f
804d82964a0c3213abcb1bcacd6a41a57159c125
3bcf3ccb44ca00e17f4d62e752cd31dd39b280c0
5cb4d110b96a7cbbe7551add3877d8b8356b5fda
692b12bd56fbad3e813398375db05673753dc203
269aaae65b4b8d1879569b13e8754f5f4484a68d
a7203b8776cd6f4b14a67f59c6a7cc4459563c36
5367b574f0a7c95cbfc9bae0ddb70bc2ab7dd7f0
ea6160d6fcf8a9fd271fec73c9a49fa63c739fe3
b08bd050d95d66decd9960a8e4a528294c47d3af
5fc2f3759e23f6b5359d9bd9a1ba08008eb2fd6f
e1d89c4c92a46bd0818996035ebde70251227e01
88f52ae60be08acbad6c4d799a6b4e1551775c47
3f57faa6156ce360c93455a2911f7aee2afd74c8
124e7b49ca8f68152ba7ac6720932ffffb8ac90e
64bd9b31692aeb92a02e4ab1222e40033782fc6c
3d06884d818ee908e754a59b47c17649bed55b28
72ac282b1c910ba0781f86c18a2eaec0f988970c
ec1fb3f84928ca0c4b53e4492153261e74dbea7f
38237dfbc91e42fd2ecfcb25d7cd767b3619bcf3
5358647836f906a4a976f26bacbe2597bcaa1eb6
9546b3ac20096b9aa0ddc9c88a3242b639bdcdc6
9a6249da82d8030330b46d497b5012aba3fcd940
88a9ba7a28a1017db4b6dc55fc83516deca806e8
33b1c89e8f7ff4915a0bca049cbfd195e2d75c35
94888362deb3fe6a2c77f6965a2fb90d396e8ac2
375b15189396d3cfffdd880235dc3dbd6d9f90f0
f94ff3798c5ea0e60cd545f87b3260ae8ea600cc
7fb502951dcaeabf951ad4f85d1cf81283e2135f
9b6275d0165a1deaac165013b9fa6015679e0102
8c4f011150ef73e2f357d0c356160c6f87f11fe9
d6e197ed698f14e2b6e2da231f17177b782a6d3c
4ee62bd7073a03a4058562964094a0276bb5445d
e673a3fd2e2396efbdcf0a5e9f969570ab953037
60ac3dd57c3f67c80efe47dba62b36835a21266b
820388e84a6add2be5723569f3e07d0b0b086988
2f90f009b90b84c8d156291720f6ff8ebe69b8b7
f98ec061cab6d960debf7e94cfbe698428c86323
fcb21829df3513c508e537db3b48c15b86a0e703
4dfca451a4bf268d265cb1d7c9d6f7dd5cfb36c7
334a298622d5587dd0765cf7dc9ea2a3a1eb7f5a
6064332f1e54545db1f2babf051bb843e844a8ed
eb919106ea65c79852a65b2f08ecc6c412bb6608
ebe4b37271cd821d1fc7e8ea55b4bbb145fe8a4b
d30d2f0be58f769b50f56af4bf7bd06ea25eb771
e26b77c1022a8b42d14696c91f32b9d69836b30d
f20a70306fb5cfd2f4bd8c9107726690f0987995
4cdb1f198f34b1b10fc6564ac06c37627d5886c7
443329d740cafd7faa744ee34d9312d064144a0a
46e3d02464bf4f4c57bfa1e4bd46430b3b224be7
c330f2c065708e0c016c3813a27ad1104082945c
8a2a0148cdbff99b4241558a1590b3b2f3fe7d0d
3b347fd98e962280db528618a077f804630ab703
8addda3775c297f0bfd7c00cbe3810d6b9641159
bce7487455f2e109c36a02217c039c7f6d4aed26
98a1f7e007edb9aeab7e2765a71cdb2cfe96409f
da5677d0435e14d6355bade9f1537ea0c339f937
a50ea3e7d7c491ecce00e4f58d90da8738604781
b228d02baaad5bdd2f5b5d0b2be1c459f31b7712
2e908fdab836e2031dd4b0c4f1ac69f6699698eb
dd4cd1356731fab2ca49671cea7b8422e34e36f6
779a34aba0506018f5fbfee4ffd4d5a36ff6bbb9
a5a5fb75e68da8af4046e6435d1f5ddd59cd94ae
98e4496aab74e9bff4b93bcd695fa8752968bb8c
92d9ccca657ca31253ebcc71ece306aa0de764e2
2164d8137fe8c410d6c4cc89a5bc72fb542cca91
447f9548f7daf611e204b181e354fc37a0a099ae
8886fa7141590ef829b22be5f1007ef4ff076191
771ade7d0307595637391da189c8e2c9558e47bc
544316af4ad6d2c1e4b6772bfbe110ccb2f9ecc1
abeb0774f63e9639a4932b859d86f13bad7ef69a
fb23b99e711ddc00ed18e817f682c301ce1e15ba
bc0ebb2ec3df701a04dabcd96d40c3110be27dd9
31b7a107c03d889000d56d076670f7d60ae33740
0667df2a422c46a5df0d3f523cd97765cca8aff6
b07e47642f706ff8228fcdd35716b4f7e0e32587
4eee69e08bd7d0fd4331275e1c6027a546dd4904
800455124056131e810ebdcda1ad79fe9eabd205
c024a033d187f9d591b52a6531b40f253627594f
6bc2cf2d4fb2ff29c9101c00d2c7e9bc6c47ff3c
a3af98765397af8f2e17417a6366b0562a4c8f21
98f7662a0d90b56bae7662735f7a4f8eb8c3fb03
fd82e214092b9f40748455185b4dde1c96787bf8
e486571960f415c0e0790e2b55b06ab3b2f67974
00a8afaa3b12d947786e8c983430fa6aa8472e53
fe0cbc870525a0276b71a18ebc6ca096b59a605c
764998e80d6991093dd6cae9d519353392f5e51f
5dbe3da2794a1393af2ea2a640c22914d66c24a7
8bb4bbea921dfb75d572c86b0f0b44e2f3632844
30d1248b910389e0927b2820b77b716a2466ec52
c0a02d9f2c7fb9cb066bdb4403534dfc9daf17bb
206661ac7c5d572dd5e34ec0f317c2f0fc6e30a2
ea287fb4bd20de714fd18cec99f4da0215ca7385
d2a740249683972433443e7d3f13ea42ac69a30a
4dee4014b5fd737df2a2b1ce56f1db8a803b9b2d
5f16cd06f07b2fbc0d13f7665c17e78104799c42
6ee7657484322d83014427d88e228eb29a0d7126
c60da80eae2075c90eda4042873e17d09c305af2
ac9636762de002f65c86d5889179963582fb8b88
36b5a651b9a2ed8755d1b7a14b50ec11c58faf39
999cce9d552fe22c9de334100a7b3129381ea0aa
703b09c568ce70fe9d3ef065cc092dcb2a63d21c
37563c00512a439554214f5e5c2fc803bbbc8a64
471f61801f574cefb9e17dbe7dce92c39ac69810
ae19766748c0e95ff80a70a5cd8a89721734462d
d7fe16025f61957d914a8d7053fa42a0c3f6ba51
743d2a9fa7b9d6970c13d1bb334e71e2e7a85da5
69825540d8df4f76c5c4f0795d17037edd0a19be
c1e6044bcca841e643b3a0e5ccc1c0a85387d1a0
49be3aba902f8474f9c3838634f9ae78bc651753
57d76f06935691c8fd77003434040745e82c47e3
b10790eefb0d21baff6dc078f833a617d1504553
2e8fbcef85b07582aa6b7ebc7fe768f2335d6072
3e0687e4a74727b04f79b5d8ce6e5ab1c2d45e9b
80e7b9510cac3df1cdfed46117380a6132dce237
75309804195256cc319320000d50a1a6f41d3f74
ee0743f9933d337cd4566585958b1e5d6f10aa5c
4716baf55830347667d4cd2a634af3fe64333ae0
cbed654a0a9e18d739142e34ab6f1de2bc7c30d8
b6fca6bd28787ca92337abb2f345821a28036c40
92f058e6c218bd2b326b3ddb8e1f1c6550f1ffc8
e526af7c5a81b9f649e3301bface3da97c681ab4
2604f840fa8b6049081a8fac5fcf1b126b40ae56
85c1db291a462f1db585d4a7fe66df08d7dda113
bb5a6865ffa8b3352c0c6006a4748d873d608a35
6f44870ec4981b94ae8a90bdafebd2145f67a32c
1f543468ab6c0c913dfdd2bce99634ab5ceef3a3
72682117a0832c0e2500809967414ed6bcef8105
46771f342f8ea5c9169fe6565b3687f3f65f79d8
2b98376da3c9ad6751490a568c6e3aeaf7fdeff2
7dee1a389520fe8fa7d14d4d54baff467dfd6752
f35a2b86beb7113d69e0cf1aa4674aed1e40bd56
d1695263bb1f3b7202f2b3dda49cbef3bc001911
963d81c0e7a2a80fddbcb9dcacaeece203ed038d
8f35b0db86a281e280e890db662318d49425c6cb
f754ded289bfc16c0a18f9ad22311f2ad125479d
9dc3a04cf90bf3e326fcd88cdf897cf041c6cebc
675becd6ae8b4df4651309b1bdca4a0e0b0e147e
6bfde30f7ed19040d03b63960c093c98f4a2f049
579c9e207e19cdfea9ed18a630f5b2c109b46029
854b8f375a43aa1664867c8833e681ff7955b2bc
56873fb3aae505d578982603581c381083f5c604
2486a8c3681d879c11d7f9c65bb32eb41ba2d39b
32089e6b6519d735b3e84a6ce12d58b111ff375c
55009a37ad77c0848fb413e2ecde393da6337bb2
a04c2cfe7f5fc5120ae8a4d372a6c6e1171b8485
4ab2fb9c69dd590aa9bebc8ff6ef74a859fc70fe
03e2d7babb734f95555b75b66b1ec6980ec9190a
4c1912e76a6bd51252f635d3c4fe5cf9fd515597
3f85ea58ab0c0b8c103b782fbf00dbe372fd61a5
18536ae08dab5e9b01381def61d0ce6bed49c7f7
f39005767cd0ed6b6e08dc5c6718ea4b769bef04
c143e57148f9701c2242b1c0c4280294ed037fa5
df2a8ff21e0095234df031c80ec01937eb6043ae
98669ebc44b5efd721847f41a3ec0c351bc3137a
8ba57230552847f45d51a4e670241829497aeff5
3512543f37cb6160d8a7887831aa43948ef79b71
1947a909465117fc05abb214aa6696d5522ef983
32eef61d9b9b7f4b4b958dbf47c0b10dd7746713
17084f68a2333cdbad5af39624555f1464e85cd5
fa6e2aa81d544f19cdf5daa8d4cd040fde42353d
b6330deac663164ec235e9efeb421d310dc074f5
e5bf5f03d0b17eedc64b5b5f187af3f135dd5eb5
5329a3f991dc3d30541b0585e92eca1c846a1791
3cf095a4f68c7fe0b5b13b1fdebb91d3ab927c48
49ac5ee13d7398975f494ea278e720b0a70e3aa0
1687da95e8ce216e110ee6d541090a90cea39cdb
ee14785b8085a1b34ed46d0421283ddf8696cae2
5b751cc17c6be0d9a40d31818b7e5fabd6524920
e18b5986b3aa2f9749ece281939da2f9e20fa526
c872cafc89c7e596bbe8cd70a0b6e82071b91061
024287fae63a62e8a4c8df2b5218c5e52b113a52
b275418471de857bd504987fbac5a8a06896ea23
042a10d4dbb2083a36e9fbb5ba2a2c0759b818f1
d5d53ab356719ac02be76506ff22c1a3b28e45a9
172eb1a1292e5f6b344a74d0228a3b01738d3de0
715bd06e7eb87639519002b1524c5e48df2b4ae3
efdf333dc4adc4416b7aafc4ed2aacd6d3bcf16a
377ebbce859dd00f6fad77bc3501fc0ca862c3c9
a200025b108bcf5821a079bf63c39191ea0b9f3c
658b77caab5ff540a1e0a36482ce05dcaac6d478
3cdb21a1370c48029ea01dcf17e9cdeeac0ba723
0ef0d1b3d18eab2128d3e84806881b015324b2a7
ba944ab390d35976ce05c0f0cc90ce872d27bda8
e77c0a5a04d19e191dc74ed89d448dc110353034
fb2d3e03ed4834c4a4c31c7931b9ada5c5cf7b4b
0d3731686f7873838ecfa4424d36be825a8fc730
9dcec446ea1c584bec134049bfaec454007cf1f9
a33b3bc25773cea4952f7757d9acec725ec7dc90
bbfae4d87a619f055306efd9c557f121fbce5eef
0710700453c2a89f306bdd5468978cfba0fb047c
2629a7682174fedf1f1b7d8736c9eb08d3171b63
5eaf78a101ba78d898a63dcfc7770e301a661bd0
a3ccc9c86bd525ac7f20adf430b25df0be18bce9
d7b89204e3c20050857803dfc08f4183b235b844
a16f8ead6ba6f90a98a1d6612a5c272b5fd6b459
bd752eb1ca55142d5ca73ede5e24347028504ac0
fa57832db968087dd364fbf377f7f2d4f9f88433
6aadfde6f0a231fab3ff3aeee3ef9427f07ccdef
17f5795df156b3f1ab767cb6d67ec31821efa251
62fc365300a538f39a9a7fe5983a958e7fd5c560
68076a3de8befe07fd09e67c361a85f8e2073f2c
2e86e5c8f5fc206a5f05400bdb753b6aef0851cb
a3e7de2d30268562d02761d85a57e5b3c20e9e15
3390da2635c1a4c64e4303d374f208c9128f77d3
1ae2d1313bf4d56bd1f14798096303333c7b2592
68ea3b1d8a95b9ac67db8b0bc5f12221db6a2d48
9ac69507df119f43835f5255a1f9ff05438f95e0
f6d71aa309158f8bcbf78ab21ac197f423f800c3
708d40d480cb37d95f28a996822bcfe0043e4b50
4914f1a1ebfff6f91f5188526d2d3e68f3a55574
e0dfb64891c07b6b9e4dc88626dc0a0e4cc71836
8eefafb8498030c5314df331ba56dd485801dcfb
9f700bb823145f33fa2e4211be7fb47ec1fbe4e8
0d27bd00f11dd36c0568cffd4c136e9fefadf01e
cd4a91f3fda4b7e297a318b67b285383d43543ce
4fb71c5fc0d2ca7a44c437a22e87fa674861265f
51d351cd13ed695d9164a4c2328d164a369f4fd9
6d986d8db990718541616120716c2113e8e62154
b323b5c8373530d37dc6a49d091dc2c7b2b4b78f
6c5fc693fd88a6e9bb043d63b330b9db3f1ffa2a
d82ed4127fd25224d3a1407a157408b980f7a8b5
fa730fd0e5876a111a3e02b5b7d74f098b91aaa5
b307925a675956609ba1f0c6afdc823548f884c1
7c9eae851897169463205e7c4f8f90afa722869e
d03dca09bcbff46271f21a8d07f0bf52807a92c2
69b9d7da24643c7a773b069a041bc34d6099ccd4
3dbc5fd6daf1a9df24871bbb29319fa80feca349
a18102d9368c4458adfb215f1d867e0ca0d26f99
4cf6bd78119b8d1c1edad725cb883c21c5f24281
5fd9c351426ba91a84a681f3cc3f2609856cbfba
7bcb6cfb748d9bf12477dd035a8444fc559c2b1f
b0930989f0abb0456bbe7623813db1974a106206
fadceb13510b2532918605e341c39aad99c52495
198077a316e98ad5ca59775e21fdeb1d370cead4
f19ee032e35e7e154412f7a4182105f0db818cd5
ae7de5e89f6d2eeea9c9aca5398055d406101a85
7780c033b0ce8f263b28584eb1e2c575bd0663c9
023b8ee623ff98d11c694a99443f7e1c3cf35d11
e8668a8829605f715d476f3fedec3895b0b4face
d882ad5e98383e4aa776a5455212f6e0cf306c99
271246352eb1c4ccc3c0f61eb8f621ee4a843121
ffe4cadb3815036b8fb79bf530edd74377422c01
fd305e7309935f3acf9921d78edb4daee22f9d74
fed1bcbbbcb3aed072e38ca732e8783072cfe649
6bf6aa5c3bcd6755f507bd89d74f611b44c6e026
588f5847d33187055ba159b110d6c3a6bcd91131
b8b2749d6844021fefbca9048f335ba728c9a265
2c1712db1b6a0014361aadc0e24ac195ff7593a5
003be4c1f376142a7abb8a258aac8c0a9f05823a
51d14a434b1767d5b6b62d643de66837d01fd4c7
b292046f397bc354f2c442d979234c64a949346d
10c82dce21ef9cc95dbc2f4ccce496e78d7dbeb2
5198f9988af97fe386f8052e9196e80dfb86e364
a20c96e56556a8fb605249b2fd03204b24fbbc32
f1c8abe92eddd8d4a9cebb6ee20e00b538b34aa8
07e913bf7c99a091e7a3a50bb611210aba898ed6
da51db5d5d55512fd5671542e5604e31f1b7a121
66d9d847d435b1e0cb5e3a9cd6f956e66859d26f
c6d2e85576b2f7695f381fa6f837067dbfde4acb
4aa1967e30b1de82b07ae42f84748abac4820422
6232466492d2539f34671e473f313efc077cf00e
517a78012181096dfb26469cb566df65dd2ccc19
a1c0e8f933f61e7c38255d97824b256b8c173d1b
14bf2a879f04933a9c0d2d60810f25557fab5627
349aef4264947e74d5a650559e02dc653adebbd5
df6a9afa6879ee234ef2ea59e7a9e9f2a3e47eb9
f4677bddce1f0cdc368d4cb3650835211ea50455
f52e3b3653ee5d15f2f72280ef80cb77a746aec9
16cc6c92e87febe9a727a8c94dea691458c75afd
bf7609f3957fae3aa83e10e475729f4989e3e48c
592ecd8d46fdf0c56a7a7dd7403aa2c022702498
21236c0bc7b6fa6c818f52ad8ba4cd99e514d96b
b215bfcfd537261e386a374b88547fa89f9086d8
a0f2f10903dc148e040888bb333e8062546583e4
2d4cd9b18c38dafdf74392bc1fbb83417dcd4fd5
7d75e1b595d7173821d380fd2f54182b67bd4d96
db52b3b9b27ad647766906ce8729b8ec3a73b258
86aecdac0abd88c59a1f616a5d051b8531efb17a
84a949197cd1df5413a8fec5d44cadefa446da7b
7fdd756a0320e827c95cbe545075948c2a25478a
22ab0e7147b3e6081b62ea3d1152a82011a86989
67e5461e9a584ad26d3fad60521166f2d475492a
c6bcbdb2e293a70b0602a74d44ab53748a964244
35bc28453dd46ea64ae6956cd5450b50284c78fd
fec0100201b421fa1cff5edeebc9f9778ed532ad
95c56e7688c04834aea9a9d0ee0c5571a4ab2dfb
91360c51f047bef5cb8a1d9372e8b17870c38ad9
7f0a64d97ae9366b7afb4c604b322219db431308
98d0dd8e5d72607e4fa292f0cb02713cd38d0ff6
e09739ae87b65d3ed76c0bbb2b2c2009dbdc961b
ac24817ce75a2d0e4927457515e5c67db18e295a
0b35f06e90c17de552b54a0475291b6b98a823d1
53c8afccdf0b5627e76abbfae1f34a80d9a92ef7
641a795e2a6ab5f5ea43736e553b04145a714f5c
667dbcbbf2828b537c347f446d6fddad66bdfadb
885eaa1e416e188f4e0c0a516e8a8773b874cd62
84d5115f6a97d50134297ed78a05571de6c4f53e
02b62cb6571e4cb949616727f242eb367b681d84
2d1182f8e4f30c26a04bfe5c5c5bc8ff88904803
fe34e39fad81115a52b1c6b2e9dd212fa89253af
e3e542f98f1ee6743c903bccbc125c156ae91db9
e712995d117d8286fc22c5d46a7ff8cd85191adf
8c44fcf4326909a2e9ccf4c397bf988f5af4447a
43a56c4f0085c5b993eeb938b163b8909048b0c3
b6ad3915bef3392a075596a3142d26d4eb7b2a03
ce4012a34456b09d72a5c5fa5820cb14acfe8706
39ff16d580f711d6e0e4b380ca985a3771ae3928
c51f4b7786eb6a865afe6b19e85c3249c19ef6c7
1c27106c91643352b82e84c0bf0afeed1d436452
8b00ab690a31396460bf558e8a4b4737eb4d4713
9aaf561a7593da6edd5f859ded3e03faa369df68
30a45243322a17c4736e7132057a5a1196e315b3
da598ea6d787ac5230bfc897048367654795606c
f192ef78e0193a2f11b6b7e5c90c96a792031822
0cde456591f3129f1c828e88d0bcf67fc59ecd81
733d1d4954003d74802baf291cb4edd62b71b247
d2056cc1600d243c20685c567030c7b4df70bbbc
54484a982fc989609a0c7d572da128e83596cb15
6b25759a332ee692ab9f07c998703cd4e6c82200
e5dfbc5a6a93c3406b299cb5f1242df7fa40df00
cb99b33813a36ee1cc775c2b05ad4f689a6dd55e
c941610ebcc82734897be7f6b0238e00698edcd0
5056e85ac0f78878b78c3753a2f4803c54d5c52a
b9201a27f6e5dc96f99f665d2519350ee015dd54
0559848889c5cde825e1a8b0e56c6c434a2d9054
2afe860a0665bb758bac152ff5e425937934ff41
3a314c19627d5fdc6f004fc8b39fe3d85d1d59b1
43b6bdb23e213737defdc5cc873666d3a8f50bf8
73a7440349a590a11bbd4cc1e3206c49029b7590
e7eeefe62a4aea278cfe40d6565b9607f7d1be4f
a1412a276626647ae2977c5e544ca048797e5058
9a4569af22ac1fb4e458fc67d1227225084ba8cc
9969298e01e2eecf447b9f93f6cb1e823b020cd3
edc62c0519068f4dd74cadf1c4e2b1342d8bdfb1
feb88274d30ec20726869b32dd56a32d8c7d7c22
b2dfc0ed1e2ab5dd4877577ee129865c7a824d8b
a0592ddf15a857d6db40131a14f28aa032197af8
87aea0f841bf9f44a7b374d3cc2fbc3b34e4b53b
cf0188f8f30ca471b06343c93b6666ec29c38457
cb6c4cc702bc17ea4eb5e41c79374f71839beb87
00829437765aeb41734671fb7f8de46e331ec537
12a02920e2d263e1e9f69c646298b00911204d8e
c368b86c1d0ca718f1e9220ca2c77e8a3c5fcf94
9057398c6b0ed0267f8204d610b99ec5b06ba9af
18edeab1e06ae93667de36564298ef1e86b64871
8052079bf00c09f56795c0e45c509bb95fe1e7ed
8e2b7e3d18a4dde1c792cd58c231e767fa6e21b3
63af784124221c85b862b9ab6356dc0468ecb13b
4529eb79bf6092e7d68ea8c417f9e654ba57a391
3ab97192f2d4125caba070c5a527e46b614d3313
1f62011d5229a01c840865120cce74c3211af0ed
9db9695bf9f0d66b9c884dbcbbe6c281173f9497
db4258f075a3449986eb7c6dc80033c3889871e6
da263f73765e37dea3b70443f3168fa9fa522bcf
0cde7bd764d1d9b51a73cdd18dfaa48553ed44ea
cf3950913741869fd4afdf41dd523ae1bb5d107b
e1f7d5e380228451a22072bcc0e3ddd50ad64edb
fe2ba59da4a3ea6bd7cd128193169ca7efa0c47d
7a436de900334cea03338acfc34770dc5083da42
5d282a32c50b63228a59a23673809aca8a5538b7
2fdbb96d042d4e030e1b0ccb86b8e429ee975f77
760f0098ba23ce839dfaa46856664a018ee5abe5
10c009f7d39ed0bb8cd1e7835ea67f7643c0822a
b20358b7606fead878b67f0ad7216510474e0f15
bc0280840eceec49ee7edc65221c27d1f36179b4
c9aae4b6496f87ccbb41a2baa36cbbf6ffeb76ba
1b1e139bb4669590490d62c92a2f4f23c7e5dbde
10a5299eae9011f1209c624abcc1171e1b16d5c7
86dfd6f526a1940cf3716bd9b5642c63f3affc58
6cc1644148a142c27e82ad84ea6844be5a89e08a
f205009e39182f9cc8eb11670c2af807934edc1b
a992351582a7757cea40eccd26765ade13e1dd9f
54adc9b4b01bc9cf2fb137f82f2096b980869df6
2d518760ac3dd5a982e6c1184cbc5aa6d5099543
b9665a2f2783eead90e2d1d4e0ef36a07ee89514
cb49ec8d4bd08ac2eb8553af7645d31fc8097d58
6f27ab7732c7494d004d7ccb274921bee9edcac0
f9caa45c226b3365e149c94f89dec23134fe327c
014b4bc7df948a4bc05051957aa4cf89409685fa
7a5408a6410968fd3d57b3e5f86267ca3eeb8468
f9a687faca3aaf6ce4939486d3fd748dc59a4dcb
933af8e0befd53f848506ccd04ae2431362ea37d
d9ac5e13889b41e8a64996a04e40eca9d4205373
12ea4f2fb53ceb684bac138aeef420d1fd146f87
008e7e9034dbdd1545cba4711c11345f38227633
cd6be6672eae23e26fe9bd250d3e3e5f29c6525e
7d1362638fb2b21ff25f66ef62e45349fc35ee01
a93cbfc0829da93d60c1a9432ea5f677c9a0afa6
fc2e3ab2ff5e13e294993aa77d577508dd3c49b3
1b660fc5931ee25741c5012ee87d651ccee45813
6810493dac023a605dc695251ce4c5efb9d1ea07
5cd4d4be6d531b9bc37ade1dd771671ad16e2453
a97f1e5bece140bbf0c80f1b1351f76cd036ac89
0605d8f6187234330f764b5367f874c1442e9137
d5c11064c58f47e1cc4baac7d9458185e849e7f0
3240c5d72fe2ff5f06eda31546fdc7f6cb3cf9ca
251c59f883ad1475413db3cd6ec44896b3f8d8eb
be4f1fad4057ed029d94e6a4eb3608be1cba1ae0
c9905394ad6e5f68d5af33e14e9a90b786ddf397
248886f85bbedec975f056b97cdf3e99041aec17
6fe5f7cfa31bf404247cde0473dc9dcc8e888191
081f1dbee6fcbc02c0a5cd5749d078a7ab420987
03a1f50d9299a82d984e87f4ae80f54b607c51f5
11fdc2c19989b6de05840996d78b309ee3921187
529081cb29020a98dcaa0a9a88d9569693b167ad
66b07cbe9fad38da535658c9a233073a031c075f
0bbf4326f4cb9dcb10d3f7f62a1a8cfcfe188625
3920e02e7e18a5fc9aecaef2ec72d3a50ce59e81
7484e945ceb8e8348873b76c1f00c304e32c77bd
0609d59bd35d50cfa55971a5653e6cabe2799315
eafc96cd40a669db6f41d868770abd229274243b
374987fd1424ffb5432ee218f08a0c29e59d47fd
c6da14ed10d45e6788e3a0a593a9ee3f6da8653a
610eb046ec9fcdcac8ad20324280aef83f18caca
50c2339f3a59bb4f2a35d0e2a01e120cd21f0938
3be7ddc1f4557804ca48af99519a2e7388e39650
17407452c0918781c76a3b50149464f81885dd09
114f65c26add8beabf315ea2a4d6e44bf087f733
e7ca62b07c22bbe3b0016b9bb4ffd4c31cb5d249
1e4ab1256feaf20368f9b306ddd0eece97080912
14da61efd475ac3c5d50aa825cd4ea5baaaf5150
1da47bfe747c7c5e7d3df02b6c41395ab6201fa3
3f9eb7729db4254fe68307f2a7a5844874dcfadc
8a189d2801763f8481294fb5286eac003a314666
e92ee987ec21f1bbc014d102c2869faa71cabb92
4b36dcb4f7e34c45b1209d3a726576b8b5296f76
c1f6d9cf6739137178f11f69652bfd8ed77e417c
4bbf08fc76fe9098aea960efb7616da5a8d1dfb3
6159252e0c9cef4bef27cf044e952e2ae8e63c38
c5e447be210a22bcf738f64ac1bd058766ed07c7
8a4d2721997dda379fa0a06f96ef85b4972b2329
f48901262a02ffd9ff849f490d3b4f84d76a471e
43b0489c4595e6f4cf75254aa9e842ae843fb167
628b6af8589998e2b250e5260f180b03e7633c5b
d1a8f52873346f50385cbc3b51f8f23fc3bb3d7a
01daa730b3df76d94bed35870fcb7966726df175
f22af44e178ee90ea5cd2a1985d685b52ed4f50a
b14260f9ccb2f7feb469f75b1e8ec900e530202d
21708c958d802b421cca46a47d6294142a16d94d
043b9acaf1ba1e86dbe57cd9d2fb4c48c6c3d2db
5d795401b367291fbae50679b427827870963aec
de2e2a33b55ed0b0ea264b0d7acf32e1e9abc178
068205dee0a549e73cbf0c66598dd9dad5db7a1a
4eb850f8eb7e5882625ff9e3c37a9957630aab1d
52a60a70b13c6f73f22b156117f405ed66b31649
2354328aed9c70d4494f474dc29018af39643749
bc400a885e96663c21d162bbba7b21b0fb61d804
3014b67ced4ef222b1cb3fa7e4df53e505867d20
10d2b3560592675a17afd1ae93a047cbd72c8511
995e2ddf87833477252a97c65dbd45f06f55548d
049c2e7ef949b12fbd2941823e59cef13691a2df
611f8048a18ffac3aa6cc80eb7783095121ef1a8
1b3f021f404f7ae6e88d75a82e07e82857ca7995
040c4fb9765eae14d83b137bdb415b3a3d7b4334
18ec7bd078c560dbdb935336eea8510a56125555
f5a2829f3f2d5472f73f8551c6bcc973c540c7c8
8ee9bcd3b35108804b6597ea22e6b085d413330a
0f67fb557cef175e14c7580aeba002dd68e13f83
8ed2e45ea5cf4f7aa18c18303f28dfbb20d21e61
4295fe817076eb12441818c2caa123a900498b48
ff6437d3d7dd546117b151eda2d19b15c976819a
c78d3e5491cb3d1100e9ab8c94e21487f5dab7e9
1ed70eca87215bee81009f5310e23ee80d5373a0
f4a2a2ea83411c5884eba88cb01c1951c1dc8aca
1c788077a3670754772d27228249cd7fdc883cf5
319806d4c9135453f9acfe1dd9a9dd584c4ace15
b99442c9b42ac5c458a10677875dcc62c49446ce
3d3d5663b550b779058c563b0b5bfea39da4f7dc
fac859c1c0a66727700d87815cbcb20e3a05b400
11db54c23d84c653ba58f5f00d4f9928a358935e
ecc92c4dfd4ed6b6dbf675d7f74c086eb4c7bff9
fdcf2713f12a22d7f0e24968e4fd7b0b30fb6768
e0bac75521cd9cf3d1d84d9f30d31769b7ebd59f
27f4007fed3f76a9674d6572ebef0d2e45815ffa
42cddbba878bbdbc86d6e8ba4c7edf54008b6c58
8530496afc3643cc03d795a7a07923ecedb4ee10
0925102e5ec8b84d1751c4568e80d79289bef89e
ca25da4af4030c0a3368ad9c34f54b5b55fe8553
904859f91fe82a7932698732e1fe0efedfd21a4a
c3adde979e05adbc5bf4f7f319952a78f6c59f98
bee63ed69ee8b868a4f114f0df16e35bccb09e43
a14d8aeda7df1ef60d8637a29b184f9fbc58653f
575ab884f193fa565e6193fb539a9a4ed510d459
c6765c67f2f7f8bea5f2759c4c0109c201cf112c
e95569e5c4f07ce3545962e6f2d57c48ffc0d2f6
4799a68ba83deea1db45ac756fb551ad23599a0f
05e503da5309343fa5a55f4522f3a89f7d625850
b92397a0fa5f139e0adc44337a62061573939001
55360b17ae2b2a218fb4c4ceb8a6a9df4fa7475f
8ca07d6a9054dfa2d87e2e52eb51c13b33808eea
81916b9337257edc963798ec2d96879076ad902a
f6ed39b157f857a51fe9cc826ef41e5c2c17df15
c897722ec8ccdcf7aca9e491b1dc47269f7f2a83
8404abc523ab6f3e95aba126858e2c65d6d05d76
0675f9dc19e241054adaf1656d2d87bbbb0757d4
571125e7bfae545f0ed04b688a6b3c30b6519819
f3c21b502e1b27fbc8365e043fcc06cdc4ba3fe5
45ad0c894a5516636386da7a05091477bc30bc49
7a61f1c1bc5b764b093318f80fdd1363a732daa0
886225a9e2b75c15c9feda889bfe9cef025adbd1
4c3be85b09bed5843be9343a33a1b9470f2a087a
54e150ebb550fea23f107a1270461aad928c37f6
1c2d4b9bac292a251591aa9b7f4c2cfec9884555
7d3249757060fda10692f24513b2f4deffd16925
7f27eda97a4dca36ea5b163424f1069627c8e625
6e635215a1a3be44664f38ebba9ed28caacf86f4
d0e3b6a41e54d4df1ba3386c6720732ffa775f4d
e5e1856790401bc101d7d4ca873db671c4fe2d6e
d815dda02536cb9029041aeeeb926ee0443db8ed
a8d4ce14d424bf2f02330eda2c58dc5ad03f406e
5bac2582f5584848cc81fb70b18a2d89638ce025
b99e366cb32a7e1714f654dcf92d2644bc6bde18
3ec1a58ac04c08fb42df1672b844a51f33ac84b8
65db553b86e98f73a654d293b922d21194f6e14d
9a6ec12e2a8388770b5883e442cb0ea7ca2b9dc6
054609a5b23ec2bdfeb1328c4d0f1228bb0ee01a
7b61390f745e572d84687c46721f342542343461
3fc90827eb04d822d5f6f0a3c4c3088234df6b51
ce0bc99c53085b7a8f09e708541e81510ce23161
6791208866e5b2a67e1fade8138b066cb9fbe56f
3eb901e2d7442f2d3b72a686b3efe2d58e0afb51
d2cdc3f952be7932777f7c26d4b41a20103dfc48
68f0f050d86ce0ffd4069719bcf91cf866927b85
e67aaf1da42dc3bf729f97671f0bb69ca7c84255
23cfdb0728353f2d1fdd3d3f462a64259e8a2d9c
6f946a8c3af1b624f67cc11e9e99e59ed807917c
7888c3d76cdaab57718fa56bb3e5d552a329f78b
1de6bdcb24470e5926a6abe355137165ddb48e22
553eefa6f442e91722f3168ca283ee73afe95772
e9e39ecaa673516b621da48e5bd6348e209a3558
f33e06a4dc8304cefce8415e8b3016b2ba3e7d44
8ebd997375adda790b5255b7c09f4b0827ddff79
0a64e9eb443f1427951dc354c94d2962c00595b4
1532db74165f1d088700e7a1977af3183f6dcc55
4e02a6f67d488c54383c4e3649a661eff284aaa7
07ab166d245612014a62db3c16ec0d7682cae1f5
41d0064159f191e84ac37e061f418f934df77a6f
a0f45e0222e1f6b3f86ed0f7c81c40d91893ee3d
31d8fe1b920260cc029007387f7aa98fb7f3638f
aa0631e18f8ea90d49a29039284ab46143560283
0076f41abdba4e384810764a30507eec11e1cc17
cfd4a7c9a1eb1254cf2e221f0425f1e37f5d6469
eca5319be012465fa4a53dfc750e515fd184e205
ba5921b7408fa0a3f3d0c7bb8043d8bcd1d9c5ff
2767da42f0c02aad6fbb14fb4986ade726d2207b
c9b1c716da6ff441a2b130ae88cc6da54d0f862b
07941fbaba63b21a69fb7120efb0ee06ef1c4716
be74d11bd5fd31892404b8a45980aafadaacbbdd
3240cba536e51afb38fe49c51786cff03f6fa9c4
1041f81cdc9ff16f4cb6b3f93cce08f805b844e3
505ca8fadc6da85219056b06f08bbd47f1951cf2
9df492b28fc5db6384833f26507ac3db5d135308
55a972332c975aceb33a2209270e97242d761a08
0a29a460ae2798e2c5e7b1cd9b451128c6bd5088
ac2bbb8159aeb0bdf92429d3c4dd3f0479e6fe51
d2be2fd23ceb4b7622e5fe94b7087bbb36390b53
5b7bcc72c3c9e51510d6a0f5e3afd10b179a85b1
4f1fcfcae517526693601e81633f4141354f5cbf
2ac6ada677d2905ae2fc724301563b2c6de6b948
da8ccfe5809f6a6d4d0f2fbdb700088a9c3d7422
efc2346eb0fd36d2d671070a87687179a0504b24
b9de6f695bd59453226a18203ccc521771e1d830
87a2abfb89999b4e398759a02e9958432c2b38aa
9dbbb1d66c3650bf663ae36a6ef6d3ea2bb4aad3
4c3148dd3684586ce21cc4dced0f0cc897713a62
29aebf9dd04adf248c3fe3f3d6b83512e05dae83
0283a5f0790017370ddec8cbc5664fc7097b4c70
5283fa6221b618bac402b77db441873b4196b95e
b7fe1044fea2776495b8b3c2eaedce72a7e141f8
b59e38eba28f1768f0ae58c9b2ab45f0ec8e7ad3
d211cdcbfdcc56be47652673bdac65e6936c5a95
6bcb7bce8d956395981fc595012eca9af355d753
86dc23b5d6213abd3c4de1422a9a239241b473c8
f7d378441ad9b2f75ab70df0d18ad5c33f76b39c
2d2d230d97ba3ce1a6a10e281c18afd3772ad3f5
17df1176533f33096b33a579e6262fb7f4e3d6e8
2198036b0c3a720b0465cfa2cdec97dc2c6ae821
b035189205ed3fc53367bb1d8ec329ab4fa509ca
7da2bab030932a7108275f133eb25de10142ce4f
be50007fe2cafa041ad838e838488a5874eeb538
fb921edf70d04163da452b751abcb3030a246cc1
926e1ac2178ccb0e6cfb1a8e3e10af96d063e484
fa7f2a00fa6dc80a4f988980f0aa5da64cd56d4d
efe22744f61e5d82bb1a5de559d8617df099e32f
79c5942d8e9626262d5769a14a125ba2c6d73722
b65156883bb215579bdbbb53fa7de3555e50b841
d8e844e5ed42dee158c383299d41ebf79742687b
fc314bd8620e6722023feae859b8d74e46cbec3f
007bfb87af2a672f7c880a2ce8192f6b9039de02
209808f8bb917ad827f605df778f1b3413867170
20c20b16d41dd820737ead0f0eb3d31fe09e2fbd
20fb16437f3838ff81e2b4b5149a0913cf93ea12
609c5d1300e75c12239bf304661ab5338df4cc54
41428cdcf4786080cad8d9b762fbd3bbfa724c61
41de84165a40be0cb2d4197048e9027a58e78184
6135aba15a6e1eddd45eecd78cac97abeeb5de74
8183114cd7d5be771975d42a7a66ff36720913dc
02a57abd239ad574ab32a9ba919a7129cc66e4f6
222539b8a606517984ec0676ab896b2829355493
22be1ef73324ebe06595cd2738b0f4f04908bab7
621d831ef500a9f26fcf88a192fe26db51766cf9
6224d7b05fb8f594c302a140948a48934bae3dc4
82147c8bfec21d79e3abb46fa0fef97a0e415dc8
a20399b32b130ca9e2fd996acfef3fb552192c05
c24429196e9b368e26664f052daed83fc80abc38
c2cab417369e53af5941e83d1d6436a7d4ea7fe5
03cbfeb29d73d3d8ab4d44d50a865e3c1ba55b12
03f74aca74312dbeaf24d7e61306dd6a786dc3d0
e3c8f041392d2d4e5b1a39e465461e040406ee89
24647e26deac88d6ede6a5931c60f78821ac1f8e
0518b9b0e7aef06583fc8d8d79a12aa4bbd6ee9d
05a1c723ae6e2e11b6c3022fc004be216ae0e186
6587958fa08c2c8a9497a37dd963ccf2fea60d35
65ada044e784e0834121eb4f72ea8d3320abab22
854692a6df3fb5f51be215a2fbccd7188307f978
86c7b94db0191602492b44fbf2e837309ae54929
a6993c7c2fe92fb85c01597a8f4456249ccfebf6
47ef318abe2d7b25c3bce667eec84d0989045e9a
08f8673b1e598985c80e02a80967d04e4f907a3b
28a6223c8efd1d756e232d49c040b7c18d92730f
482cdd3b74abdfb8a96cd410f80ead8119e1f1cd
6851a4ab03b6eacd7edaf13ef6a013ca39cece1c
686fa2c50138dcfb4fea824ed3403a0f59e3da43
c833e564343ea913d1d22d9e8ecc7d3ae2e493ba
e8d33bab4f1cda42be49f4bb30091b746b39a6b4
092c71f2c1e27ba7975af25e5a6e39a2fa66ace0
095983c59b69b33ed10af56e9bd76c9d2731e28f
09febc68675f4122f2f63e1c97239e539b892d0b
49645671bea541756630e5c3c50b0dbcd4d97910
49dcf2b27d3aee19e09c29a85fe5e79bf46f4c37
c9ef5628d438f5282f0bbd6dcc84af746640ae38
e922cb6f860727de230726d2870231ce246adf4d
2aa5f751a8480196ff4295c3ec0b924328265865
4a791bbbe8da318dd8ea93976892fbff59b13d01
2b206d6bba69664b521ad523c4b852c1430870da
2b2b4a5bfcb9d92a284e888676e112ffe20f6297
ab1e4548004e0ffe41d12c35b5d92addb9039827
abdd6cbef26f5482985c5bd4d4b969bac963ce4a
0c55e5b979350beee41a43f2ac0fb9f99d5ea0cd
ec8eb098b6263512e1bb1d3401891845e79050fe
eca21e001c2539679045e8e3dacabc12ee22620e
0d664ebe1b49cd80fe0b2f54c031a45d1f1beec7
2dc4ae3376734e12819ebce8140d35f211a8f857
6d3d3fbe90ec209a2876b11c2fe7ea206a34d31c
ad55545b489fcbe8a4a454df08804e28650b35ba
ed992fd7032dbfc577379e7a82204553f359eba6
8e2dc94494f7741e64c538f38f9a399e74f5ad8b
6f060ed87a8fd44c04d2c52e2de52daeac3d843e
af9a13ab471e10e7d1cd001065786ace4002a605
cff2095e01167338f146e59f1305bbf2a073ac8a
ef04bbb897750d92c142003b0cc79dc03ae9ee14
903e13af0725e57cdae429128514ad16fb8b0fd7
9043e5e2be2c77bbddb409702dd032018939238f
1190405d3d8c343a64de1ce1bb5c144440e84b4a
712cec6c481c3d78c52698a10644af9aaf7e241d
716e16cdbca877680642b8ccc5076adfcdf2c278
71fa168eb17bb302a525bc3654eb844e6d778a22
1208c8738efc896fe681b58f321062d61d5712ec
327fb8232938e1610efab882d55ff26aac82b353
d2ced6ca799e75015c213fb528e83cd33215a336
f27c339134f5ca49142f4c0e859df43fab5fbdbb
f2af7cebe4951163ebd922bc784effdd1e7a1ec8
13e95b0e7cb4d8806de8559afc9f9cf7a1bba674
53b0dfcdbeb00c387a52462d5f16f0355b23e762
d3bc4c2e7749aebfe0ab7b0911fd9548b109c19c
7425d707f2a019191c994967485ca82d7f91aa73
94c3101d4449e9fbe8c38c29c5507289f02dcc85
b431899d6c48b71790388f8a4077ed560b107dd1
d44eabfac9d6db3d1b94e30a4470de0e450cc523
d497382ba886f49e76e48b1b8a4dffe2c9fb9f7f
75525d1acbf0cba22d1b671ff0608423ca999bad
d5f2ed6ae3a251bf6c36793ccbd10e2cd1038548
36c01ea243c567926a0cd50d1922d0fa2c4c7193
f65b02c388c8b77bdae7fe0f83b37d42fb79351e
17d318e7f81d2e0c9b9cc62a62e3bea33a02a4d4
185e80c01be5d7d50ee57f17135d10b51d9cf6ed
78a26ba648a10511bfe0b0c9689d4a76fb43fbd7
78ebe6cd6e052cbccfaf435cd7325e7fb5fc5ac7
b8643053c19f4a861c738221597d472917070351
596deaa0cfd99c27f3b940a81a5a46a40dc17721
59dcff185d4ad5759d2439b27be0e67edcad94c7
3a5680ab948350a7b4f772af15ce6f051482d5fa
5a69b52d69914b5c03574807fc40b2691f2b38b2
ba1e83c7b9b225d3ba236e1dcf6d92629eb7c989
fa21b4eed76d2bc76ad0e356f7a4c7dd32832435
fab3aeaac8467d85ed57d938aa5be6483f4bce17
1b7abae0eda2b39e6ad74c8466cfa7aefdf038d7
3b4b728858985c5aef80bbbfeefd53cbeb6ad290
5be7d6afad622f64ff78e02e773a1edfb075efb5
9b4db3c1b2ba6e16a65b141206c8fc56bd7b805a
1c8d7ff3e588ba144dbe46eb7ec81b95e0c8d5f9
9c83616e4fb77abc82c13b9db09d48263eb5b563
1d5d3b52db292de3f24eb714e9cbfe739ed119ee
bd2a9599ed9ceae3250817def7b28956197659e6
1e6b8513937ee046cacefaf1fa8cd86ec8bd77fd
1f7bc59f471e7784a70c1a87f9b38b851715bae1
5f490301614bc59fb9523ece7ea3cc309d8b45db
5f99cc017db0b993081463cb1e3c8ebcad6ec65a
bf1332f6fbac397d5c2dd61fc7bc2dbe07820aab
3759c6529b44b636b845fb1c8a0f42c4d14d7150
41428cdcf4786080cad8d9b762fbd3bbfa724c61
41de84165a40be0cb2d4197048e9027a58e78184
6135aba15a6e1eddd45eecd78cac97abeeb5de74
6224d7b05fb8f594c302a140948a48934bae3dc4
82147c8bfec21d79e3abb46fa0fef97a0e415dc8
a20399b32b130ca9e2fd996acfef3fb552192c05
c24429196e9b368e26664f052daed83fc80abc38
c2cab417369e53af5941e83d1d6436a7d4ea7fe5
03cbfeb29d73d3d8ab4d44d50a865e3c1ba55b12
05a1c723ae6e2e11b6c3022fc004be216ae0e186
6587958fa08c2c8a9497a37dd963ccf2fea60d35
65ada044e784e0834121eb4f72ea8d3320abab22
854692a6df3fb5f51be215a2fbccd7188307f978
092c71f2c1e27ba7975af25e5a6e39a2fa66ace0
09febc68675f4122f2f63e1c97239e539b892d0b
2aa5f751a8480196ff4295c3ec0b924328265865
4a791bbbe8da318dd8ea93976892fbff59b13d01
2b206d6bba69664b521ad523c4b852c1430870da
2b2b4a5bfcb9d92a284e888676e112ffe20f6297
ab1e4548004e0ffe41d12c35b5d92addb9039827
ec8eb098b6263512e1bb1d3401891845e79050fe
2dc4ae3376734e12819ebce8140d35f211a8f857
6f060ed87a8fd44c04d2c52e2de52daeac3d843e
cff2095e01167338f146e59f1305bbf2a073ac8a
900c687c4f869d711afdd0b9c8fdb1a95ccf657c
903e13af0725e57cdae429128514ad16fb8b0fd7
712cec6c481c3d78c52698a10644af9aaf7e241d
327fb8232938e1610efab882d55ff26aac82b353
d2ced6ca799e75015c213fb528e83cd33215a336
f27c339134f5ca49142f4c0e859df43fab5fbdbb
f2af7cebe4951163ebd922bc784effdd1e7a1ec8
13e95b0e7cb4d8806de8559afc9f9cf7a1bba674
d497382ba886f49e76e48b1b8a4dffe2c9fb9f7f
35c27d9047ca5c581fe87f65af0feb4ba3e012c1
75525d1acbf0cba22d1b671ff0608423ca999bad
f65b02c388c8b77bdae7fe0f83b37d42fb79351e
183f74580b0c40e5c0e070304428e79fcc77cdf1
185e80c01be5d7d50ee57f17135d10b51d9cf6ed
b8643053c19f4a861c738221597d472917070351
3a5680ab948350a7b4f772af15ce6f051482d5fa
5a69b52d69914b5c03574807fc40b2691f2b38b2
3b4b728858985c5aef80bbbfeefd53cbeb6ad290
5be7d6afad622f64ff78e02e773a1edfb075efb5
9b4db3c1b2ba6e16a65b141206c8fc56bd7b805a
1c8d7ff3e588ba144dbe46eb7ec81b95e0c8d5f9
bc6c2b26c91b24aeddd718261ad73fde45d278f7
bd2a9599ed9ceae3250817def7b28956197659e6
bdf8963c7efa036470d637d197dd3d465b979d96
1e6b8513937ee046cacefaf1fa8cd86ec8bd77fd
deffad232aa17239ed384597c15053b64f4328e1
1f7bc59f471e7784a70c1a87f9b38b851715bae1
5f490301614bc59fb9523ece7ea3cc309d8b45db
bf1332f6fbac397d5c2dd61fc7bc2dbe07820aab
df23837816539a2776921cdb55781353c65616ce
df6183c5bcb6fd83b1210b7597d7c68370256f68
EOT

for my $c (split(/\n/, $badCmtHere)){
  $badCmt{$c} = 1000000;
}

1;
