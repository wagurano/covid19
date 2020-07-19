filename="${1:2:14}"
# filename="${1:0:14}"
date
t0=`date +%s`
t1=$t0
echo "extract $filename"
### stock $1,$3
# tar -xOzf $1 | awk -F, '{print $1","$4","$2}' | grep -v -E "code|{" | sort | uniq | ruby diff.rb > tmp/$filename.status.csv
tar -xOzf $1 | awk -F, '{print $1","$3",full"}' | grep -v -E "code|{" | sort | uniq | ruby diff.rb > tmp/$filename.stock.csv
# tar -xzf "$filename.tar.gz" -C /temp/files/stock/tmp/$filename
t2=`date +%s`
t3=`expr $t2 - $t1`
echo "$1:$t3 elapsed"
