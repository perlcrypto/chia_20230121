=b
//140.117.59.186/186_msdb /mnt/140.117.59.186/master/sdb cifs username=jsp,password=j0409lee,uid=1000,gid=1001,dir_mode=0777,file_mode=0777,noperm,rw 0 0
=cut

#!/usr/bin/perl

use strict;
use warnings;
my $user = "jsp";
my $passwd = "j0409lee";
my $uid = 1000;
my $gid = 1001;
my @disk = qw(
node01
node02
node03
node04
node05
node06
node07
sdb
);
my $ip = "140.117.59.186";
my $last = 186;
my $fstab = '/etc/fstab'; # path of smb.conf

for (@disk){
chomp;
`mkdir /mnt/$ip/$_`;
`echo "//$ip/$last\_$_ /mnt/$ip/$_ cifs username=$user,password=$passwd,uid=$uid,gid=$gid,dir_mode=0777,file_mode=0777,noperm,rw 0 0" >> $fstab`;
}
