#!/usr/bin/perl

# Original script was developed by John Collins

# Current script has fixes accordingly to support latest NGF format
# Last update : 2015  March 4
# This converter is part of  http://gokifu.com  project
#
# Magical Script for converting NGF (cyber oro)  Files
# http://senseis.xmp.net/?NGF
# example of use
# ./gib2sgf.pl  1.ngf
# as result output  1.ngf.sgf
# Vasily B. Yevstygnyeyev <info@gokifu.com>
# Licensed under GPL License



use open qw/:std :utf8/;

sub  readit  {
    $_ = <INF>;
    s/\r?\n//;
}

$file = shift;
#$rfile = shift;
die "No source file given\n" unless $file;
#die "No dest file given\n" unless $rfile;
die "Expecting NGF file\n" unless $file =~ /\.ngf/i;
die "Cannot open $file\n" unless open(INF, $file);


#event 


# Application and type  
$_ = <INF>;
s/\r?\n//;
$ev= $_;

#readit;

# Board size

readit;
die "Confused by board size $_\n" unless /\d+/;
$Boardsize = $_;

print "boardsize " .$Boardsize."\n";


# White player and rank

readit;
#($wp,$wr) = /^(.*\S)\s+(\d+[kd]\S*)/i;         # relicts  only english files
($wp,$wr) = /^(...*\S)\s+(...\S*)/i; #this should for any language

print "white player ".$wp." rank ".$wr."\n";

# Black player and rank

readit;
#($bp,$br) = /^(.*\S)\s+(\d+[kd]\S*)/i;
($bp,$br) = /^(...*\S)\s+(...\S*)/i; #this should for any language
print "black player ".$bp."black rank ".$br."\n";

# Website name

readit;
$Website = $_;
print "website ".$Website."\n";
# Handicap

readit;
$Hcap = $_;
print "Handicap ".$Hcap."\n";

# Unknown

readit;

# Komi (add 0.5)

readit;
$Komi = $_;
$Komi .= '.5';
print "Komi ".$Komi."\n";
# Date and time

readit;
($yr,$mn,$dy,$hr,$min) = /(\d\d\d\d)(\d\d)(\d\d)\s+\[(\d\d):(\d\d)\]/;
#die "Confused by date $_\n" unless $yr;

($yr,$skip,$mn,$skip,$dy) = /(\d\d\d\d)(-)(\d\d)(-)(\d\d)/ unless $yr;

print $yr."-".$mn."-".$dy."\n";

$outfile = "$file.sgf";
#$outfile=$rfile;
die "Cannot create output $outfile\n" unless open(OUTF, ">:encoding(utf-8)",$outfile);
select OUTF;

# Unknown

readit;

# Result

readit;
$res = substr($_, 0, 1);
$res = $res eq "W"? "B": "W" if /loses/;
$res .= '+';

if (/resi|Resi/) {
    $res .= 'R';
}
elsif (/time/) {
    $res .= 'T';
}
elsif (/(\d+(\.5)?)/)  {
    $res .= $1;
}
else  {
    die "Confused by result format $_\n";
}

$res=$_ unless $res;
$res=$_ if $_ =~ /^\d/ ;



# Number of moves

readit;
$nmoves = $_;

$Aoff = ord('A');
$adj = ord('a') - $Aoff - 1;

print <<EOT;
(;GM[1]FF[4]CA[UTF-8]AP[gokifu.com]SO[http://gokifu.com]ST[1]
SZ[$Boardsize]HA[$Hcap]KM[$Komi]EV[$ev]
PW[$wp]WR[$wr]PB[$bp]BR[$br]RE[$res]DT[$yr-$mn-$dy]
EOT

print "AB[pd][dp]" if $Hcap==2;
print "AB[pd][dp][pp]" if $Hcap==3;
print "AB[dd][pd][dp][pp]" if $Hcap==4;
print "AB[dd][pd][jj][dp][pp]" if $Hcap==5;
print "AB[dd][pd][dj][pj][dp][pp]" if $Hcap==6;
print "AB[dd][pd][dj][jj][pj][dp][pp]" if $Hcap==7;
print "AB[dd][jd][pd][dj][pj][dp][jp][pp]" if $Hcap==8;
print "AB[dd][jd][pd][dj][jj][pj][dp][jp][pp]" if $Hcap==9;

while (<INF>) {
    s/\r?\n//;
    my ($m1,$m2,$pl,$c1,$c2) = /PM(.)(.)(.)(.)(.)/;
    my $oc1 = ord($c1);
    my $oc2 = ord($c2);
    if  ($oc1 <= $Aoff  ||  $oc2 <= $Aoff)  {
	print ";${pl}[tt]\n";
    }
    else  {
	print ";$pl", "[", chr($oc1 + $adj), chr($oc2 + $adj), "]\n";
    }
}
print ")\n";
