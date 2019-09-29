#!/bin/sh

# 寻找所有大于1G的文件
# str="1.5G 权力的游戏.Game.of.Thrones.S08E06.1080p-天天美剧字幕组.mp4"
# #arr=(${str//,/})
# arr=(${str})
# for s in ${arr[@]}
# do
#    echo $s
# done

# echo ${arr[0]} 
# echo ${arr[1]}
# exit 1

rootpath=/Users/liaochongliang/Desktop/find_MoreThen_1G.sh

#echo "begain $1"

# fileroot="/Users/liaochongliang/Library/Android/sdk"
fileroot=$1

cd $fileroot
filesublist=$(du -sh * |grep G\\s)
#echo "find > 1G  "

filesub=($filesublist)
len=${#filesub[@]}
#echo len=$len
# echo ${filesub[0]}
# echo ${filesub[1]}
# echo ${filesub[2]}
# echo ${filesub[3]}

index=0
while [ $index -ne $len ]
do
    #echo ${filesub[$index+1]}
    subpath=$1/${filesub[$index+1]}
    cd $subpath
    subpath=$(pwd)
    echo subpath=$subpath
    $rootpath  $subpath
    let index+=2
done

#echo "ende $1"