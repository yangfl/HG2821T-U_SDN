#!/bin/sh

if [ ! -f /usr/local/fh/log_switch/log_cycle_enable ]
then
    echo "Do not enable logbak function"
    exit
fi

if [ ! -f /usr/local/fh/logbak/$1 ]
then
    echo "/usr/local/fh/logbak/$1 do not exist, exit"
exit
fi

log_num=`ls /usr/local/fh/logbak | grep $1 | wc -l`
echo "The same type file num is "$log_num

file_name=$1"-"${log_num}

echo "rename file: "$file_name

mv /usr/local/fh/logbak/$1  /usr/local/fh/logbak/${file_name}
 
dir_size=`du -k /usr/local/fh/logbak | cut -f 1`
echo "directory logbak's size is" ${dir_size}

max_dir_size=$((5 * 1024))
if [ ${dir_size} -lt ${max_dir_size} ]
then
    echo "logbak's size is Not great enough. do nothing"
    exit
fi

if [ ! -d /usr/local/fh/logbak_history ]
then
    mkdir /usr/local/fh/logbak_history
fi

cd /usr/local/fh/logbak_history

gz_num=`ls /usr/local/fh/logbak_history | grep logbak.tar.gz- | wc -l`
echo "tar.gz num is "${gz_num}

max_gz_num=10
min=1
if [ ${gz_num} -gt ${max_gz_num} ]
then
    echo "ERROR Ocurr"
    rm /usr/local/fh/logbak_history/logbak.tar.gz*
    #exit
elif [ ${gz_num} -eq ${max_gz_num} ]
then
    echo "rm the first tar.gz, then rename tar.gz, create tar.gz"
    rm /usr/local/fh/logbak_history/logbak.tar.gz-1

    while [ $min -lt ${max_gz_num} ]
    do
        old_gz_file_name=logbak.tar.gz-$((min+1))
	new_gz_file_name=logbak.tar.gz-${min}
        mv /usr/local/fh/logbak_history/${old_gz_file_name} /usr/local/fh/logbak_history/${new_gz_file_name}
	min=`expr $min + 1`
    done	
	
    max_gz_file_name="logbak.tar.gz-"${max_gz_num}	
    tar -zcf ${max_gz_file_name} ../logbak/
elif [ ${gz_num} -lt ${max_gz_num} ]
then
    echo "create tar.gz"
    new_file_name="logbak.tar.gz-"$((gz_num+1))
    tar -zcf ${new_file_name} ../logbak/
fi

rm /usr/local/fh/logbak/*
