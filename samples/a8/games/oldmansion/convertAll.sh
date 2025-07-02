for IMAGE in $(ls -1 *.gif)
do
    echo \*\*\* CONVERTING $IMAGE
    NAME="${IMAGE%.*}"
    convert $IMAGE -colors 2 -negate $NAME.pbm
    tail -c +12 $NAME.pbm > $NAME.gr8
    rm $NAME.pbm
done

