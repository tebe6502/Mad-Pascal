TEMPLZ4=tmp.tzl4
./smallz4-v1.3.1.exe ./$1 $TEMPLZ4
dd if=$TEMPLZ4 of=$2 bs=1 count=$(($(stat -c '%s' $TEMPLZ4) - 15)) skip=11
rm $TEMPLZ4
