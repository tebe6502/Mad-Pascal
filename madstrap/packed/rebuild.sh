#!/bin/bash
MEMFILE=memory_pak.inc
RCFILE=resources_pak.rc
#PAKCMD="../utils/zx5.exe -f"
PAKCMD="../utils/apultra.exe"

#convert all images from images folder to pak_*.gfx files
for IFILE in $(ls -1 *.png)
do
    NAME="${IFILE%.*}"
    ONAME=pak_"${NAME}".gfx
    python ../utils/convert.py $IFILE $ONAME 01
done

#iterate on pak_*.* files and compress and append to memory_pak.inc and resources_pak.rc
SIZE=0
for IFILE in $(ls -1 pak_*.*)
do
    echo \*\*\* COMPRESSING $IFILE
    NAME="${IFILE%.*}"
    ONAME="${NAME:4}".pak
    CNAME=$(echo "${NAME:4}"_PAK | tr '[:lower:]' '[:upper:]')
    $PAKCMD $IFILE ${ONAME}
    echo "${CNAME} = PAK_DATA + ${SIZE} ;" >> _$MEMFILE
    echo "${CNAME} rcdata 'packed/${ONAME}'" >> _$RCFILE
    FSIZE=$(stat -c%s "$ONAME")
    ((SIZE+=${FSIZE}))
done
    echo "//SIZE = ${SIZE} ;" >> _$MEMFILE

rm $MEMFILE $RCFILE
mv _$MEMFILE $MEMFILE
mv _$RCFILE $RCFILE

echo MEMORY FILE:
cat $MEMFILE
echo RESOURCE FILE:
cat $RCFILE


