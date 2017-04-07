#!/bin/bash
j=0
k=0
for i in `ls`; do
	if [ -d $i ];then
		DIR[$j]="$i"
		j=$[$j+1]
	else
		FILE[$k]="$i"
		k=$[$k+1]
	fi
done
echo "The DIR has: ${DIR[*]}"
echo "The FILE has: ${FILE[@]}"
echo "The length is :${#FILE[2]}"
