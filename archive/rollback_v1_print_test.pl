#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

#Directory Variables
our $ORACLE_HOME = "";
our $APO="/oracle/APO";
our $shutdown_log="$ORACLE_HOME/shutdown.log";
our $PATCH_ID = '';

GetOptions("id=s" => \$PATCH_ID);



#======================================
#Capture ORACLE_HOME variable          #
#======================================

open (FILE, "/etc/oratab") || die "Cannot open your file";


while (my $line = <FILE> )
{
        chomp $line;
        my @sid = $line =~ /\:(.*?)\:/;

        foreach (@sid)
        {
         $ORACLE_HOME = pop @sid;

        }
}
close (FILE);
print "ORACLE_HOME variable has been set as: \n";
print "$ORACLE_HOME \n";




#======================================
#Patch Compatability Checks           #
#======================================


our $cmd_check_patch  = "$ORACLE_HOME/OPatch/opatch prereq CheckConflictAgainstOHWithDetail -ph ./ > /oracle/APO/logs/pre-patch_check.log";
system ($cmd_check_patch);
our $cmd_check = "grep passed /oracle/APO/logs/pre-patch_check.log | wc -l";
our $proceed_patch = `$cmd_check`;


if ($proceed_patch == 0 )
{
	print "Pre-check failed. Program will be terminated \n";
	print "View logs to check failure reason: \n";
	print "/oracle/APO/logs/pre-patch_check.log \n";
	exit;
}
else
{

print "Pre-check passed. Commencing Patch \n";



}



