=b
The script help you install chia_blockchain.
https://thechiafarmer.com/2021/04/20/plotting-on-multiple-windows-computers/

On the second computer, you will need to install the 
Chia Client. Once installed, the Client will open.
 Just close this window, do not generate new keys 
 and do not recover keys from the mnemonic phrase. 
 then
 
 .\chia.exe plots create -k 32 -b 3389 -u 128 -r 2 -t E:\temp -d D:\plot -n 1 `
  -f <insert farmer key> -p <insert pool key>
  
   3389 is the perfect amount if you are using 2 threads. I have found that 4 threads requires a minimum of 3408;
    6 threads 3416; 8 threads 3424.
=cut

use warnings;
use strict;
use Cwd; #Find Current Path
#my $chia_exe = 'C:\Users\Shin-Pon\AppData\Local\chia-blockchain\app-1.0.5\resources\app.asar.unpacked\daemon\chia.exe';
#print "$chia_exe\n";
system("chia.exe keys show");
system("chia.exe keys show --show-mnemonic-seed");
