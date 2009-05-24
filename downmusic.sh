#!/bin/sh
###Copyright (c) 2008  percy (pengjianqing@sina.com)
# Distributed under the terms of the GNU General Public License v3
#Ctreated date:2008年 04月 06日 星期日 00:15:05 CST
#参考了benqlk：http://forum.ubuntu.org.cn/viewtopic.php?t=95073

read -p "请输入要下载的歌曲名:" musicname         #输入下载歌曲序号

if [ -d ~/Music ];then
echo "下载的音乐将会保存到 ~/Music 文件夹下"
else
echo "~/Music 文件夹不存在 脚本将会自动创建"
mkdir ~/Music
fi 

#把中文转换成16进制数字和字母不变 
a=`echo "$musicname" | iconv -c -f utf-8 -t gb2312 | LANG=C sed 's/./&\n/g' | sed -n '$!l' |
while read str;do
str=${str%$}
if [ ${#str} -eq 3 ];then
printf "%%%X" "0${str}"
elif [ "X${str}" == "X" ];then
echo -n '%20'
else
echo -n $str
fi
done
echo`

wget "http://mp3.baidu.com/m?f=ms&tn=baidump3&ct=134217728&lf=&rn=&word="$a"&lm=-1" -O source_baidu              #获得搜索页面
iconv -c -f gb2312 -t utf8 source_baidu > source_utf8  

let m=25                     #提取出有效下载链接个数
grep -m $m "M</td>" source_utf8|cut -d "<" -f2|cut -d ">" -f2 > music_size                  #得到文件大小
#grep -m $m "M</td>" source_utf8 |cut -b5-10|sed 's/<//g' > music_size                    #得到文件大小
grep -m $m  "<td class=d><a href=" source_utf8|awk -F"&word" '{print $1}'|cut -d "," -f2|sed 's/ //g'> music_info                 #得到歌曲名信息
grep -m $m  "[wm][mp][a3]</td>" source_utf8|cut -d "<" -f2|cut -d ">" -f2  > music_type               #得到歌曲格式
grep -m $m  "http://mp3.baidu.com/singerlist/" source_utf8 |cut -d ">" -f3|cut -d "<" -f1 > singername                   #得到歌手名字
cat music_size>all
cat music_info>>all
cat music_type>>all
cat singername>>all
awk '{a[NR]=$0}END{for(i=1;i<=NR/4;i++)printf "(%d)\t%s\t%s\t%s\t%s\n",i,a[i],a[i+2*NR/4],a[i+3*NR/4],a[i+NR/4]}' all >sum      #将信息打印成整齐列表
cat sum
read -p "请选择你要下载第几首:" c         #输入下载歌曲序号
                
let line=`grep  -n "class=tdn>$c</td>" source_utf8|cut -d ":"  -f1`       #获得源文件中歌曲代号所在的行数
let line=$line+1         #获得歌曲链接所在的行数，从源文件中可以看到歌曲代号所在的下一行就是歌曲的链接
head -n $line source_utf8 |tail -n 1 >url1                 #取得真实链接存在的网页地址
cat url1 |awk -F"href=\"" '{print $2}'>url2                 #取得真实链接存在的网页地址
u=`cat url2`
wget -O true_source "$u"                                        #取得真实链接存在的网页
iconv -c  -f gb2312 -t utf8 true_source >true_source_utf8         #转换编码
url=`grep "：<a href=" true_source_utf8 |awk -F"\">" '{print $1}'|awk -F"=\"" '{print $2}'`       #获取真实链接
echo $url
t=`echo $url|awk -F"." '{print $NF}'`
name=`grep "($c)" sum|awk -F'\t' '{print $5}'`
singer=`grep "($c)" sum|awk -F'\t' '{print $4}'`
echo "$t"
wget  -t 5 -cS  "$url"   -O  ~/Music/"${singer}-${name}.$t"            #下载音乐 

#rm source_*  url*  true*  music_*  all  sum
