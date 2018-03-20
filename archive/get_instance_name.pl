#!/usr/bin/perl
use strict;

my $filename = 'oratab';
chomp ($filename);

open (FILE, "/etc/$filename") || die "Cannot open your file: $1"; 

while (my $line = <FILE> ){
	chomp $line;
	my @sid = $line =~  /^(.*?):\//;
       
	foreach  (@sid)
        {
          print "$_\r\n";
          
          
        }


}
 



close (FILE);

