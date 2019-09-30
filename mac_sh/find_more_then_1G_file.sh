#!/bin/sh 
# 寻找所有大于1G的文件
# uese age   ./find_more_then_1G_file.sh ~/Library 

# str="1.5G 权力的游戏.Game.of.Thrones.S08E06.1080p-天天美剧字幕组.mp4"
# #afilesubrr=(${str//,/})
# filesub=(${str})
# for s in ${filesub[@]}
# do
#    echo $s
# done

# len=${#filesub[@]}
# echo len=$len

# echo ${filesub[0]} 
# echo ${filesub[1]}


# user='mark:x:0:0:this is a test user:/var/mark:nologin'
# i=1
# while((1==1))
# do
#         split=`echo $user|cut -d ":" -f$i`
#         if [ "$split" != "" ]
#         then
#                 ((i++))
#                 echo $i
#                 echo $split
#         else
#                 break
#         fi
# done




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
fileroot="$1"

cd "$fileroot" > /dev/null
#echo fileroot=$fileroot

#filesublist=$(du -sh * |grep G\\s)
du -sh *  | grep "G\\s.*" -o | grep "[^G].*" -o > sum.txt
# echo的会变成一行
# echo $(du -sh *  | grep "G\\s.*" -o | grep "[^G].*" -o)
#echo "find > 1G  "

# cat sum.txt

while read subpath
do
    #echo fileroot=$fileroot
    #echo subpath=$subpath
    #echo rootpath=$rootpath

    if [  -f "$subpath" ] ;then
        # echo ${subpath} is a file 
        echo "file=" $(du -sh "$subpath")
    fi

    if [ -d "$subpath" ] ;then
        echo "is a dir ""$subpath"
        cd "$subpath" >/dev/null
        subpath=$(pwd)
        du -sh "$subpath"
        cd - >/dev/null
    
        #echo excute=$rootpath $subpath 1
        $rootpath "${subpath}" 1
    fi

done < sum.txt

exit 1

#echo "ende $1"

#https://blog.csdn.net/u010003835/article/details/80750003
