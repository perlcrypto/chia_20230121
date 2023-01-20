system("ps aux|grep 'ssh node'|grep jsp|awk '{print \$2}'|xargs kill");
system("ps aux|grep 'ssh node'");