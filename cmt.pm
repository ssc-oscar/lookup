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
  "c1ce17533f16f8928878c0cfc45cb4be1b32ca71" => 1366738243, #this is greater than
  "f268257b2f1517e4f870820a5a63cbe215668f5c" => 1309902811, #this is greater than
  "45546f17e5801791d4bc5968b91253a2f4b0db72" => 892148431, #this is greater than
  "b55208a72f6443eaeaf31789f9a492c20dc021a1" => 654088805, #this is greater than
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
  "de6be7945c6a59798eb0ace177df38b05e98c2f0" => 650111   #"module ApplicationHelpe\nend\n"
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
