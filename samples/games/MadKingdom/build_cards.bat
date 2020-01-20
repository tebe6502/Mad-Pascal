python tools/extract_cards.py > assets/cards_pl.tmp
python tools/convert.py assets/cards_pl.tmp > assets/cards.asm
python tools/asm2rle.py assets/faces_src.asm > assets/faces_rle.tmp
type assets\faces_rle.tmp | grep -v org >> assets\cards.asm
del assets\*.tmp

