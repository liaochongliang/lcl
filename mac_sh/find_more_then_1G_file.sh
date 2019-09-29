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

rootpath_x0=$0
bFull=0
cd ~
if [ -f "${rootpath_x0}" ] ;then
    #echo ${rootpath_x0} is a fullpath file 
    let bFull=1
else
    #echo ${rootpath_x0} is not a fullpath file
    let bFull=0
fi

#返回正确的目录
cd - >/dev/null

# echo x0=$0
# echo xpwd=$(pwd)

rootpath=""
#echo $#
if [ $# != 2 ]; then
    rootpath=$(pwd)/$0
    #echo rootpath1=$rootpath
else
    rootpath=$0
    #echo rootpath2=$rootpath
fi

if [ $bFull -eq 1 ];then
    rootpath=$0   
fi

#echo "begain $1"

# fileroot="/Users/liaochongliang/Library/Android/sdk"
fileroot=$1

cd $fileroot
filesublist=$(du -sh * |grep G\\s)
#echo "find > 1G  "

filesub=($filesublist)
len=${#filesub[@]}
# echo len=$len
# echo ${filesub[0]}
# echo ${filesub[1]}
# echo ${filesub[2]}
# echo ${filesub[3]}

index=0
while [ $index -ne $len ]
do
    subpath=$1/${filesub[$index+1]}
    
    #echo subpath=$subpath
    #echo rootpath=$rootpath
    
    if [  -f "$subpath" ] ;then
        #echo ${subpath} is a file 
        echo "file=" $(du -sh $subpath)
        exit 0
    fi

    cd $subpath
    subpath=$(pwd)
    du -sh $subpath
    
    #echo excute=$rootpath $subpath 1
    $rootpath $subpath 1
    let index+=2
done

#echo "ende $1"