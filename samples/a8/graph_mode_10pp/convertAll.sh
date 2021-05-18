for IMAGE in $(ls -1 *.png)
do
    echo \*\*\* CONVERTING $IMAGE
    NAME="${IMAGE%.*}"
    pythonw png2gr10.py $IMAGE $NAME.g10 40 0 
done

