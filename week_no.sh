#!/bin/bash
source ~/.bash_profile

##定义参数
day_no=`date -d"-1 day" +%Y%m%d`
if [ $# -eq 1 ];then
 day_no=$1
elif [ $# -eq 0 ];then
 echo "O.K"
else
 echo "参数错误:请输入0到1个参数"
 exit 1
fi
year_no=${day_no:0:4}
day_no_30_d=`date -d"${day_no} -30 days" +%Y%m%d`
day_nos=`date -d"${day_no}" +%s`
first_days=`date -d"${year_no}0101" +%s`
week_nos=$[(${day_nos}-${first_days})/60/60/24/7+1]
if [ ${week_nos} -le 9 ];then
 week_no=${year_no}'0'${week_nos}
else
 week_no=${year_no}${week_nos}
fi

##打印参数
echo "day_no: "${day_no}
echo "year_no: "${year_no}
echo "day_no before 30 days: "${day_no_30_d}
echo "week_no: "${week_no}
