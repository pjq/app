#!/bin/bash
#Copyright (c) 2006 bones7456 (bones7456@gmail.com)
#License: GPLv2
#非常感谢ubuntu社区和oneleaf老兄
#强烈建议安装axel（多线程下载工具）和mid3v2（包含在python-mutagen里，用于修改歌曲的id3信息）

#mp3的地址
SOURCE="http://list.mp3.baidu.com/list/newhits.html"
#SOURCE="http://list.mp3.baidu.com/topso/mp3topsong.html" 改成这个地址可以下载歌曲top500

#保存mp3的目录
SAVE="${HOME}/baidump3"

#下载重试次数
TRYCOUNT=2

#用axel下载时的线程数
AXELNUM=7

#临时目录
TMP="/tmp/baidump3-${USER}"

#是否需要暂停
PAUSE=0

if [ x`which axel` = x"" ];then
	PAUSE=1
	cat << EOF
	您的系统中没有安装axel多线程下载工具，这将导致只能使用wget进行单线程下载，将会影响下载速度。
	如果是ubuntu用户，可以直接使用 sudo apt-get install axel 进行安装，其他系统请访问axel主页：http://wilmer.gaast.net/main.php/axel.html 进行下载、安装。

	EOF
fi
if [ x`which mid3v2` = x"" ];then
	PAUSE=1
	cat << EOF
	您的系统中没有安装mid3v2工具，使用该工具可以修改mp3歌曲的标签信息(如歌手、歌名等)，并去掉可能包含于其中的广告信息。
	如果是ubuntu用户，可以直接使用 sudo apt-get install python-mutagen 进行安装，其他系统请访问其主页：http://www.sacredchao.net/quodlibet/wiki/Development/Mutagen 进行下载、安装。

	EOF
fi
if [ "$PAUSE" = 1 ];then
		echo "是否继续(y|n)？"
			read KEYVAR
				case "$KEYVAR" in
						"Y" | "y" )
							echo 略过。
								;;
									* )
										exit 0
											;;
												esac
											fi

#创建下载目录
if [ ! -d "${SAVE}" ];then
	    mkdir -p "${SAVE}"
    fi

#创建临时下载目录
if [ -d "${TMP}" ];then
		rm -rf "${TMP}"
	fi
	    mkdir -p "${TMP}"

	    echo "开始下载百度最新100首歌曲列表"
	    wget -O ${TMP}/mp3.html ${SOURCE}
	    echo "下载百度最新100首歌曲列表完成。"

#转换网页编码
iconv -f gbk -t utf8 ${TMP}/mp3.html |\

grep " href=\"http://mp3.baidu.com/m" |\

#将mp3list.txt所有开头的空格去掉
sed -e 's/ *//' |\

#将mp3list.txt所有开头的tab去掉
sed -e 's/\t*//' |\

#将mp3list.txt所有全角空格去掉
sed -e 's/　//g' |\

#将所有的回车符去掉
sed ':a;N;$!ba;s/\n/,/g' |\

#在td>,后面加上回车符，一行表示一个mp3文件。
sed -e 's/,<td/\n<td/g' |\
sed -e 's/td>,/td>\n/g' |\

#删除<td width="30%"> <td> </td> <td...FFFFFF"> <p> </p>
sed -e 's/<td width="30%">//g' |\
sed -e 's/<td>//g' |\
sed -e 's/<\/td>//g' |\
sed -e 's/<p>//g' |\
sed -e 's/<\/p>//g' |\
sed -e 's/<td.*"border">//g' |\

#删除</a>..."_blank">
sed -e 's/<\/A>\/<A.*_blank>/、/g' |\
sed -e 's/<\/A>/<\/a>/g' |\
sed -e 's/<\/a>.*_blank>/-/g' |\
#sed -e 's/<\/a>.*_blank">/-/g' |\
#删除)
sed -e 's/<\/a>)/<\/a>/g' |\
#删除文件名末尾的tab
sed -e 's/\t<\/a>/<\/a>/g' |\
#删除&amp;
sed -e 's/\&amp\;/\//g' >${TMP}/mp3list.txt

#得到：<a href="http://mp3.baidu.com/m?tn=baidump3&ct=134217728&lm=-1&li=2&word=Baby%20Baby%20tell%20me%20%CD%F5%D0%C4%C1%E8" target="_blank">Baby ,Baby tell me-王心凌</a>

#取得行号，循环
line=$(awk 'END{print NR}' ${TMP}/mp3list.txt)
i=1;
while((i<=line));do
	   downed=0;
	    mpline=`awk 'NR=='"$i"'' ${TMP}/mp3list.txt`
	    url=`echo $mpline | sed -e 's/<a href="//g' | sed 's/\ target.*//g' | sed 's/"//g' | cat`
	    name=`echo $mpline | sed -e 's/.*_blank">//g' | sed -e 's/.*_blank>//g' | sed -e 's/<\/b>//g' |sed -e 's/<b>//g' |\
	   sed -e 's/<\/a>//g' | sed -e 's/\//-/g' | sed -e 's/:/-/g'  | sed -e 's/"/'\''/g'  | cat`
	   title=`echo $name | sed -e 's/-.*//g'`
	   echo $url
done
