=b
dnf install cifs-utils
mkdir -p /mnt/185_win/d
mount -t cifs -o username=Shin-Pon\040Ju //140.117.59.185/d /mnt/185_win/d
chmod -R 770 /mnt before mount
samba for other linux machines:
//140.117.59.186/jsp /mnt/140.117.59.186/jsp cifs username=jsp,password=j0409lee,uid=1000,gid=1001,dir_mode=0777,file_mode=0777,noperm,rw 0 0 
=cut

#!/usr/bin/perl

use strict;
use warnings;
use Expect;#Password for

#system ("dnf install cifs-utils");

#["IP",mount No,"d","e","f","i","k"]
my $uid = 1000;
my $gid = 1001;

my @machineInfo = (
["140.117.59.185",5,"d","e","f","i","k"],
["140.117.59.175",4,"d","e","f","j"]
);
my %user4machine = (
    "140.117.59.185" => ["Shin-Pon\\040Ju","mem4268Ju?#*"],
    "140.117.59.175" => ["SHIN-PON","MEM4268Ju?#*"],

);
my @keys = keys %user4machine;
print "\@keys: @keys\n";
#make mount points
for my $m (0..$#machineInfo){
    my $ip = $machineInfo[$m][0];
    #chomp $ip;
    #`sed -i '/$ip/d' /etc/fstab`;
    my $diskNo = $machineInfo[$m][1];
    my $username = $user4machine{$ip}->[0];
    my $passwd = $user4machine{$ip}->[1];
    #print "\$username:$username, \$passwd:$passwd\n";
    #die;
    for my $d (1..$diskNo){
        my $disk = $machineInfo[$m][$d+1];
        `mkdir -p /mnt/$ip/$disk`;
        `umount -l /mnt/$ip/$disk`;
        `echo "//$ip/$disk /mnt/$ip/$disk cifs username=$username,password=$passwd,uid=$uid,gid=$gid,dir_mode=0777,file_mode=0777,noperm,rw 0 0" >> /etc/fstab`;
    } 
system("ls /mnt/$ip/");
system("mount -a");

}