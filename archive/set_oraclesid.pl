#!/usr/bin/perl
use strict;

my $filename = 'oratab';
chomp ($filename);

my $ORACLE_HOME='/oracle/product/12.1.0/db1';

open (FILE, "/etc/$filename") || die "Cannot open your file: $1"; 

while (my $line = <FILE> ){
	chomp $line;
	my @sid = $line =~  /^(.*?):\//;
        
	foreach  (@sid)
        {
          my $cmd = "export ORACLE_SID=$_";
          my $cmdpatch = "$ORACLE_HOME/OPatch/datapatch -verbose";
          
          print "$cmd\r\n";
           print "$cmdpatch\r\n";
          `$cmd`;
          `$cmdpatch`;
         
            
        }

}
 



close (FILE);

