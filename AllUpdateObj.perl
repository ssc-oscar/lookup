#!/usr/bin/perl -I /home/audris/lib64/perl5

use strict;
use warnings;
use Error qw(:try);

use TokyoCabinet;

sub toHex { 
	return unpack "H*", $_[0]; 
} 

sub fromHex { 
	return pack "H*", $_[0]; 
} 

my $debug = 0;
my $sections = 128;
my $parts = 2;

my $type = $ARGV[0];

my $fbase="All.sha1/sha1.${type}_";
my $fbasei ="/data/All.blobs/${type}_";

my (%size, %cnt, %fhob, %fhoi, %fhov, %fhos);
for my $sec (0 .. ($sections-1)){
	my $off = 0;
	my $n = 0;
	if ( -f "$fbasei$sec.idx"){
		open A, "tail -1 $fbasei$sec.idx|" or die ($!);
		my $str = <A>;
		close A;
		if (defined $str){
			chop ($str);
		my 	($nn, $of, $len, @rest) = split (/\;/, $str, -1);
		if 	(defined $len){
				$off = $of + $len;
				$n = $nn + 1;
			}else{
				die "bad format in $fbasei$sec.idx\n";
			}
		}else{
			die "empty $fbasei$sec.idx\n";
		}
	}else{
		$off = 0;
		$n = 0;
	}

	$size{$sec} = $off;
	$cnt{$sec} = $n;
	
	my $pre = "/fast/";
   $pre = "/fast1" if $type == "blob";
	#$pre = "/fast" if $sec % $parts;
	tie %{$fhos{$sec}}, "TokyoCabinet::HDB", "$pre/${fbase}$sec.tch", TokyoCabinet::HDB::OWRITER | 
			TokyoCabinet::HDB::OCREAT, 16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
		or die "cant open $pre/$fbase$sec.tch\n";
	open $fhoi{$sec}, ">>$fbasei$sec.idx" or die ($!);
   open $fhob{$sec}, ">>$fbasei$sec.bin" or die ($!);
   open $fhov{$sec}, ">>$fbasei$sec.vs" or die ($!);
}

while (<STDIN>){
	chop();
	$_ =~ s/\.bin$//;
	my $readFileBase = $_;
	my %id2n = ();	
	open IDXR, "$readFileBase.idx" or die ($!);
	my $base = $readFileBase;
	$base =~ s|^.*/||;
        #$base =~ s|\..*$||;
        $base =~ s|\.[^\.]*$||;$base =~ s|\.[^\.]*$||;#for, e.g., sources.git.github.com.2.18.blob.bin
	open my $fh, '<', "$readFileBase.bin" or die ($!);
	while(<IDXR>){
		chop();
		my ($offset, $siz, $sec, $hsha1Full, @p) = split(/\;/, $_, -1);
    next if (!defined $offset);
		my $path = join ';', @p;

		my $codeC = "";
		seek ($fh, $offset, 0);
		my $rl = read($fh, $codeC, $siz);

		if ($siz == 0){
			print STDERR "zero length for: $offset\;$siz\;@p\;$readFileBase\n";
			next;
		}

		my $sha1Full = fromHex ($hsha1Full);

		my $id = $size{$sec};
		my $n = $cnt{$sec};
		my $fb = $fhob{$sec};
		my $fi = $fhoi{$sec};
		my $fv = $fhov{$sec};

		if (defined $fhos{$sec}{$sha1Full}){
			my $nn = unpack "w", $fhos{$sec}{$sha1Full};
			print $fv "$nn:$sec;$siz;$sec;$hsha1Full;$base;$path\n";		
		}else{
			$fhos{$sec}{$sha1Full} = pack "w", $n;
			print $fv "$n:$sec;$siz;$sec;$hsha1Full;$base;$path\n";
			print $fi "$n;$id;$siz;$hsha1Full\n";
			print $fb "$codeC";			
			$size{$sec} += $siz;
			$cnt{$sec} ++;
		}	
	}
}

for my $sec (0 .. ($sections-1)){
	untie %{$fhos{$sec}};
}

