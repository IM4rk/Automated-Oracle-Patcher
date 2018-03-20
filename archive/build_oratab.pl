#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

#=======================================
#Postpatch                             #
#=======================================

#At this point, the patcher has two course of action depending on wether the database is a Clone/Primary  or Standby
#Segregate Primary and Standby databases and store in a config file
#Detect Dataguard instances and write the result to the config file

our $ORACLE_HOME="/oracle/product/12.1.0/db1/";
our $cmd_startup_standby_mount = "/oracle/APO/stop_and_start/dbstart_mounted_standby $ORACLE_HOME";


# Decide wether to old dg_list

our $cmd_pmon = "ps -ef | grep -i pmon | grep -v grep | wc -l";
our $proceed_delete = `$cmd_pmon`;

if ($proceed_delete == 0 )
{
 print "not deleting shit \n";
 
}
else
{
  print "deleting old dg list \n";
  my $cmd_rm_dg_list = "rm /oracle/APO/DG/dg_list.log";
  `$cmd_rm_dg_list`;

open (FILE, "/etc/oratab") || die "Cannot open your file";
while (my $line = <FILE> )
{
        chomp $line;
        my @sid = $line =~ /^(.*?):\//;

        foreach  (@sid)
        {
          print "$_ \r\n";
          my $cmd_setsid = "export ORACLE_SID=$_";
          my $cmd_detect_standby = "/oracle/APO/DG/detect_standby.sh";

          print "$cmd_setsid\r\n";

          $ENV{ORACLE_SID}="$_";
          $ENV{ORACLE_HOME}="$ORACLE_HOME";
          sleep (2);
          system($cmd_detect_standby);

        }
}
close (FILE);

}

our $config_standby = "cat /oracle/APO/DG/dg_list.log > /oracle/APO/config/standby";
system ($config_standby);

our $config_clone = "grep -v  _ds /etc/oratab > /oracle/APO/config/clone";
system ($config_clone);

#Add ORACLE_HOME to the standby file


	  

		


		



          





