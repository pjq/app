#########################################################################
# Author: PengJianqing@sina.com
# Created Time: 2008年04月05日 星期六 16时37分33秒
# File Name: getmp3.sh
# Description: 
#########################################################################
#!/bin/bash
#!/bin/bash
#检测一些必要的工具 和路径
if [ -d ~/Music ];then
	echo "下载的音乐将会保存到 ~/Music 文件夹下"
else
	echo "~/Music 文件夹不存在 脚本将会自动创建"
	mkdir ~/Music
fi
if [ -s /usr/bin/axel ];then
	echo "检测到你已经安装了axel 将会成为你默认的下载工具"
else
	echo "你还没有安装axel 多线程下载工具，将会自动选择单线程工具wget下载。如果你的系统是ubuntu你可以执行：sudo apt-get install axel 下载并安装axel."
fi
if [ -s /usr/bin/mid3v2 ];then
	echo "检测到mid3v2会把你音乐的tag都删除掉,预防出现乱码"
else
	echo "你还没有安装mid3v2，这个工具 可以去掉音乐里面的tag（乱码的根源），如果你的系统是ubuntu你可以执行：sudo apt-get install python-mutagen下载并安装."
fi
if [ -e file ];then
	rm file
fi
if [ -e file_1 ];then
	rm file_1
fi
if [ -e size ];then
	rm size
fi
if [ -e size_1 ];then
	rm size_1
fi
#核心部分(提取连接 和把中文转换成url编码)
#把中文转换成16进制数字和字母不变
a=`echo "$1" | iconv -c -f utf-8 -t gb2312 | LANG=C sed 's/./&\n/g' | sed -n '$!l' |
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

wget "http://mp3.baidu.com/m?f=ms&tn=baidump3&ct=134217728&lf=&rn=&word="$a"&lm=-1" -O file #下载网页的源代码
iconv -c -f gb2312 -t utf8 file |grep -m 20 "M</td>"|awk -F">" '{print $2}'|awk -F"<" '{print $1} ' >size #找到下载音乐文件的对应后缀
iconv -c -f gb2312 -t utf8 file |grep -m 20 "<td class=d><a href="|awk -F"," '{print $2}'|awk -F"&" '{print $1}'>>size # 提取出20个有效的下载连接里的要转换成url编码的连接符
iconv -c -f gb2312 -t utf8 file |grep -m 20 "[wm][mp][a3]</td>"|awk -F">" '{print $2}'|awk -F"<" '{print $1}' >>size #找到下载文件的大小

awk '{a[NR]=$0}END{for(i=1;i<=NR/3;i++)printf "(%d)\t%s\t%s\t%s\n",i,a[i],a[i+NR/3],a[i+40]}' size >size_1 #
cat size_1

read -p "请选择你要下载第几首:" c
f=`cat size_1 | sed -n "${c}p" | awk '{print $NF}'` #提取你要下载的取文件后缀
b=`iconv -c -f gb2312 -t utf8 file |grep -m $c "<td class=d><a href=" | sed -n "${c}p" |awk -F"," '{print $2}'|awk -F"&" '{print $1}' ` #提取你要下载文件的第 2连接（有了这个这个连接就能找到下载源文件)
#把连接里的中文转换成url
c=`echo "$b" | iconv -c -f utf-8 -t gb2312 | LANG=C sed 's/./&\n/g' | sed -n '$!l' |
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
url_1=`iconv -c -f gb2312 -t utf8 file |grep -m 1 "<td class=d><a href="|awk -F"\"" '{print $2}'|awk -F"," 'BEGIN{OFS=","}{$2="'$c'&word=mp3"}NF'` #找到下载第1连接的源文件

wget "$url_1" -O file_1 #下载第1连接的源文件
iconv -c -f gb2312 -t utf8 file_1 |grep "<a href" -m 1|cut -d "=" -f2|cut -d ">" -f1 >url_2
#下载部分

h=`cat url_2`
if [ -s /usr/bin/axel ];then
	axel -n 10 -o ~/Music/"$1.$f" "$h" #在这里你可以改变你的下载路径
else
	wget -t 5 -c -i url_2 -O ~/Music/"$1.$f" #下载音乐
fi
if [ -s /usr/bin/mid3v2 ];then
	mid3v2 -D ~/Music/"$1.$f"
fi
rm file file_1 url_2 size size_1

