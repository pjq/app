#!/bin/sh
wget -O baidutop100 http://list.mp3.baidu.com/list/newhits.html
 iconv -c  -f gb2312 -t utf8 baidutop100 >baidutop100utf8

singer=`grep "</A>/<A" baidutop100utf8 -m 1|awk -F"target=_blank>" '{print $2}' |cut -d "<" -f1`
musicname=`grep "<a href=\"http://mp3.baidu.com/m?tn=baidump3" baidutop100utf8 -m 1|awk -F "target=_blank>" '{print $2}'|cut -d "<" -f1
`
grep "<a href=\"http://mp3.baidu.com/m?tn=baidump3" baidutop100utf8 -m 1|awk -F "target=_blank>" '{print $1}'|awk -F" href=\"" '{print $2}' >mp3list.txt
