 #plot_directories:
use strict;
use warnings;
use Cwd;

my @temp = `find /mnt -type d -name "free"`;
chomp (@temp);
for (@temp){
    print "- $_\n";
}