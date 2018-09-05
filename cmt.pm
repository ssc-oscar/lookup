package cmt;
use strict;
use warnings;
use Compress::LZF;


require Exporter;
our @ISA = qw (Exporter);
our @EXPORT = qw(%badCmt %badBlob %badTree seg signature_error contains_angle_brackets extract_trimmed git_signature_parse extrCmt getTime cleanCmt safeDecomp safeComp toHex fromHex);
use vars qw(@ISA);

our %badCmt = (
  "c89423063a78259e6a7d13d9b00278a0c5e637b0" => 10000000005,
  "45546f17e5801791d4bc5968b91253a2f4b0db72" => 10000000000,
  "03cb3eb9c22e21e2475fee4fb6013718a2fa39fb" => 100000000,
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
  "b55208a72f6443eaeaf31789f9a492c20dc021a1" => 10000000000, # tons of fake files
  "f268257b2f1517e4f870820a5a63cbe215668f5c" => 10000000000, # tons of fake files
  "c1ce17533f16f8928878c0cfc45cb4be1b32ca71" => 10000000000, # tons of fake files
  "5e4c1715341534fbcf4126c053bc0ff64cc48a7c" => 10000000000, # tons of fake files
  "f0e385e0fb36173c53f68f91b6e28023a039da02" => 2043846, # tons of fake files
  "cc646e6b0c4584134424ce0b2d385080169f3b81" => 1171240, # tons of files
  "eecde993ec799b0fb714bbd2124ec893c1125473" => 1130319, # tons of files
  "0e33a9c3e97a85c632f964375c5ecada305514de" => 1217678, # tons of files
);

our %badBlob  = (
  "e69de29bb2d1d6434b8b29ae775ad8c2e48c5391" => 7826798, #\n 
  "8b137891791fe96927ad78e64b0aad7bded08bdc" => 957235, #\n\n
  "de6be7945c6a59798eb0ace177df38b05e98c2f0" => 650111,   #"module ApplicationHelpe\nend\n"
  "573541ac9702dd3969c9bc859d2b91ec1f7e6e56" => 100000, # more than that "0\n"
  "46b134b197f35e75e0784bedbf94a8dd124693b1" => 100000, # more than that "fffe"
  "5c15a99ffacbe23740c4b27cabc1df33988b3b86" => 100000, # more than that "<?php"
  "c1f9d5dd052c921bb709036a51e6ff77de303aae" => 100000, # more than that "<?php\n$searchnum=0;\n?>"
  "42fa765b495e581408e87614ac90a18b4fb03f09" => 100000, # more than that "<?php require(__FILE__);"
  "f57368ede135004cf1913c9296eaea8ced94ca63" => 100000, # more than that "<?php return unserialize('a:0:{}');"
  "06d7405020018ddf3cacee90fd4af10487da3d20" => 100000, # more than that "23 nuls"
  "2142470504f0374fee201d2b72d3e7915a2718b5" => 100000, # more than that "
  "0d5a690c8fad5e605a6e8766295d9d459d65de42" => 100000, # more than that "my new file contents"
  "10c09bc50e7c4005d41f8827f1598b74e94cc3de" => 100000, # more than that "Here be even moar damned content"
  "2995a4d0e74917fd3e1383c577d0fc301fff1b04" => 100000, # more than that "dummy"
  "521d0e4dde3b141ab557b10589aa4e3f4a5f94b7" => 100000, # more than that "import Foundation"
  "8a2030a3614762e08d57a138bfcf1b29396eecd4" => 100000, # more than that "--- []\n...\n\n"
  "a686078a02cdf71215e6ce2f9f99e51f9bd5b18c" => 100000, # more than that "This is README.MD"
  "a726efc43fc177e976fd3b236a15756d5522d5e9" => 100000, # more than that "'use strict';"
  "b71f2c6f78b435e9e554ed689d94eed705208bf7" => 100000, # more than that "[{"failureDictionary":{}}]" 
  "0637a088a01e8ddab3bf3fa98dbe804cbde1a0dc" => 100000, # more than that "[]"
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

sub toHex {
        return unpack "H*", $_[0];
}
sub fromHex {
        return pack "H*", $_[0];
}
sub safeDecomp {
        my ($codeC, $msg) = @_;
        try {
                my $code = decompress ($codeC);
                return $code;
        } catch Error with {
                my $ex = shift;
                print STDERR "Error: $ex, $msg\n";
                return "";
        }
}
sub safeComp {
        my ($codeC, $msg) = @_;
        try {   
                my $code = compress ($codeC);
                return $code;
        } catch Error with {
                my $ex = shift;
                print STDERR "Error: $ex, $msg\n";
                return "";
        }
}


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
  my ($tree, $parent, $auth, $cmtr, $ta, $tc) = ("","","","","","");
  my ($pre, @rest) = split(/\n\n/, $code, -1);
  for my $l (split(/\n/, $pre, -1)){
     #print "$l\n";
     $tree = $1 if ($l =~ m/^tree (.*)$/);
     $parent .= ":$1" if ($l =~ m/^parent (.*)$/);
     #($auth, $ta) = ($1, $2) if ($l =~ m/^author (.*)\s([0-9]+\s[\+\-]*\d+)$/);
     #($cmtr, $tc) = ($1, $2) if ($l =~ m/^committer (.*)\s([0-9]+\s[\+\-]*\d+)$/);
     ($auth) = ($1) if ($l =~ m/^author (.*)$/);
     ($cmtr) = ($1) if ($l =~ m/^committer (.*)$/);
  }
  ($auth, $ta) = ($1, $2) if ($auth =~ m/^(.*)\s(-?[0-9]+\s+[\+\-]*\d+)$/);
  ($cmtr, $tc) = ($1, $2) if ($cmtr =~ m/^(.*)\s(-?[0-9]+\s+[\+\-]*\d+)$/);
  $parent =~ s/^:// if defined $parent;
  return ($tree, $parent, $auth, $cmtr, $ta, $tc, @rest);
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

sub cleanCmt {
  my ($cont, $cmt, $debug) = @_;
  my ($tree, $parents, $auth, $cmtr, $ta, $tc, @rest) = extrCmt ($cont, $cmt);
  my $msg = join '\n\n', @rest;
  if ($debug){
    if ($debug == 3){
      my $c = safeDecomp($cont, $cmt);
      $c =~ s/\r/ /g;
      print "$c\n";
    }else{
      $msg =~ s/[\r\n;]/ /g;
      $msg =~ s/^\s*//;
      $msg =~ s/\s*$//;
      $auth =~ s/;/ /g;
      if ($debug == 2){
        print "$cmt;$auth;$ta;$msg\n";
      }else{
        if ($debug == 4){
          print "$cmt;$auth\n";
        }else{
          my ($a, $e) = git_signature_parse ($auth, $msg);
          print "$msg;$cmt;$a;$e;$ta;$auth\n";
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

sub seg {
  my ($sh, $n) = @_;
  return (unpack "C", substr ($sh, 0, 1))%$n;
}


1;
