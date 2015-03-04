#! /usr/bin/perl

# Last update : 2015  March 4
# This converter is part of  http://gokifu.com  project
# 
# Magical Script for converting Tom/Tygem Files
# GIB Format is used by TOM & EWEQI client 
# GIB files must be converted properly to UTF-8 
# example of use 
# ./gib2sgf.pl  1.gib    
# as result output  1.gib.sgf 
# Vasily B. Yevstygnyeyev <info@gokifu.com>
# Licensed under GPL License

use open qw/:std :utf8/;

sub  readit  {
    $_ = <INF>;
    s/\r?\n//;
}

$file = shift;
die "No source file given\n" unless $file;
die "Expecting gib file\n" unless $file =~ /\.gib/i;
die "Cannot open $file\n" unless open(INF, $file);

#header of gib \HS
readit;
die "wrong file type" unless /^\\HS/ ;
readit;

while(<INF>)
{
    s/\r?\n//;
    ($s,$b,$e) = /(^\\\[)([^\\]*)(\\\])/i ;
    $_ =$_.<INF> unless $e eq ("\\]");
    ($skip,$skip,$wr)= /([^=]*)(=)([^\\]*)/i  if ($_ =~/GAMEWHITELEVEL/);
    ($skip,$skip,$br)= /([^=]*)(=)([^\\]*)/i  if ($_ =~/GAMEBLACKLEVEL/);
    ($skip,$skip,$bp)= /([^=]*)(=)([^\\]*)/i  if ($_ =~/GAMEBLACKNICK/);
    ($skip,$skip,$wp)= /([^=]*)(=)([^\\]*)/i  if ($_ =~/GAMEWHITENICK/);
    ($skip,$skip,$res)= /([^=]*)(=)([^\\]*)/i  if ($_ =~/GAMERESULT/);
    ($skip,$skip,$wname)= /([^=]*)(=)([^\\]*)/i  if ($_ =~/GAMEWHITENAME/);
    ($skip,$skip,$bname)= /([^=]*)(=)([^\\]*)/i  if ($_ =~/GAMEBLACKNAME/);


    ($skip,$yr,$skip,$mn,$skip,$dy)= /([^\d]*)([\d]*)([^\d]*)([\d]*)([^\d]*)([\d]*)/i if ($_ =~/GAMEDATE=/);
    last if $b =~ /GAMETAG/;
	
}

$moves="";
#INI 0 1 0
while(<INF>)
{
 s/\r?\n//; 
# STO 0 113 2 5 3 
    ($skip,$skip,$skip,$Hcap) = /(INI)\s+([\d]+)\s+([\d]+)\s+([\d]+)/i if ($_ =~ /INI/ ) ;
    if  ($_ =~ /STO/)  
    {   
        ($a,$b,$n,$c,$x,$y) =  /(STO)\s+([\d]+)\s+([\d]+)\s+([\d]+)\s+([\d]+)\s+([\d]+)/i;  
        $col= $c == 1 ? "B" : "W" ;   
        $moves =$moves.";".$col."[".chr($x+97).chr($y+97)."]";   
    }  
}

$outfile = "$file.sgf";

die "Cannot create output $outfile\n" unless open(OUTF, ">:encoding(utf-8)",$outfile);
select OUTF;

#hack no white nick
if ($wp=="")
{
  $wr="";
   $br="";
   $wp=$wname;
   $bp=$bname;
}
#HA[$Hcap]KM[$Komi]EV[$ev]  // не знаю
print <<EOT;
(;GM[1]FF[4]CA[UTF-8]AP[gokifu.com]SO[http://gokifu.com]ST[1]
SZ[19]PW[$wp]WR[$wr]PB[$bp]BR[$br]RE[$res]DT[$yr-$mn-$dy]
EOT
 print "HA[".$Hcap."]" if ($Hcap>0);

print "AB[pd][dp]" if $Hcap==2;
print "AB[pd][dp][pp]" if $Hcap==3;
print "AB[dd][pd][dp][pp]" if $Hcap==4;
print "AB[dd][pd][jj][dp][pp]" if $Hcap==5;
print "AB[dd][pd][dj][pj][dp][pp]" if $Hcap==6;
print "AB[dd][pd][dj][jj][pj][dp][pp]" if $Hcap==7;
print "AB[dd][jd][pd][dj][pj][dp][jp][pp]" if $Hcap==8;
print "AB[dd][jd][pd][dj][jj][pj][dp][jp][pp]" if $Hcap==9;


print $moves;
print ")\n";
