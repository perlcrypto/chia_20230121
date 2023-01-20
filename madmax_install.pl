=b
The script help you install madmax for chia_plotter.
https://github.com/madMAx43v3r/chia-plotter

You need to install the latest version for cmake.

Example shell script for madmax installation 
https://gist.github.com/jollyjollyjolly/d8904efda4d5997a2f0e9caf31cff1c3
=cut
use warnings;
use strict;
use Cwd; #Find Current Path
#
`yum install epel-release -y`;
`yum install  gmp-devel libsodium libsodium-static cmake3 -y`;
`dnf -y group install "Development Tools"`;

my $wgetORgit = "no";# set no to update files from github
my $installPath = "/opt";
my $current_path = getcwd();# get the current path dir
my $URL = "https://github.com/madMAx43v3r/chia-plotter.git";#url to download

if($wgetORgit eq "yes"){
	system("rm -rf $installPath/chia-plotter");
	chdir("$installPath");
	#system("git clone $URL");
	system("git clone $URL");
	die "git clone madmax failed!!!\n" if($?);
	system("chmod -R 755 $installPath/chia-plotter");
	chdir("$current_path");
}
chdir("$installPath/chia-plotter");
`git submodule update --init`;
system("./make_devel.sh");
die "make_devel.sh failed!\n" if ($?);
print "madmax installation done!\n";

#The following should be done for nodes
#system("$cmd 'yum install cmake3 gmp-devel libsodium libsodium-static  -y'");
#system("$cmd 'dnf -y group install \"Development Tools\"'");