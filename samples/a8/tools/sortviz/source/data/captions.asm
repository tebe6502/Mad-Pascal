CAPTION_LIST

    dta a(demo1)
    dta a(demo2)
    dta a(reads)
    dta a(writes)
    dta a(delay)
    dta a(fill_ascending)
    dta a(fill_descending)
    dta a(fill_pyramid)
    dta a(fill_interlaced)
    dta a(knuth_shuffle)
    dta a(fill_ascending_with_shuffle)
    dta a(insertion_sort)
    dta a(selection_sort)
    dta a(quick_sort)
    dta a(merge_sort)
    dta a(bubble_sort)
    dta a(coctail_sort)
    dta a(gnome_sort)
    dta a(circle_sort)
    dta a(comb_sort)
    dta a(pancake_sort)
    dta a(shell_sort)
    dta a(odd_even_sort)
    dta a(bitonic_sort)
    dta a(radix_sort)
    dta a(heap_sort)
    dta a(double_selection_sort)
    dta a(main_menu_caption)
    dta a(demo_method_caption)
    dta a(paused_caption)
    dta a(quit_caption)
    dta a(main_menu_keys)
    dta a(demo_method_keys)
    dta a(processing_keys)
    dta a(paused_keys)
    dta a(quit_keys)

CAPTIONS_LENGTH

    dta 6   ;Demo (
    dta 4   ;) - 
    dta 5   ;Reads
    dta 6   ;Writes
    dta 5   ;Delay
    dta 14  ;Fill ascending
    dta 15  ;Fill descending
    dta 12  ;Fill pyramid
    dta 15  ;Fill interlaced
    dta 13  ;Knuth shuffle
    dta 27  ;Fill ascending with shuffle
    dta 14  ;Insertion sort
    dta 14  ;Selection sort
    dta 10  ;Quick sort
    dta 10  ;Merge sort
    dta 11  ;Bubble sort
    dta 12  ;Coctail sort
    dta 10  ;Gnome sort
    dta 11  ;Circle sort
    dta 9   ;Comb sort
    dta 12  ;Pancake sort
    dta 10  ;Shell sort
    dta 13  ;Odd-Even sort
    dta 12  ;Bitonic sort
    dta 10  ;Radix sort
    dta 9   ;Heap sort
    dta 21  ;Double selection sort
    dta 7   ;SortViz
    dta 29  ;Choose shuffle metod for demo
    dta 6   ;Paused
    dta 5   ;Quit?
    dta 41  ;  Esc Exit  TAB Change image  Return Demo
    dta 12  ;  Esc Cancel
    dta 33  ;  Space Pause  - Faster  + Slower
    dta 25  ;  Space Resume  Esc Abort
    dta 13  ;  Y Yes  N No
    
CAPTIONS

demo1                   dta d'Demo ('
demo2                   dta d') - '
reads                   dta d'Reads'
writes                  dta d'Writes'
delay                   dta d'Delay'
fill_ascending          dta d'Fill ascending'
fill_descending         dta d'Fill descending'
fill_pyramid            dta d'Fill pyramid'
fill_interlaced         dta d'Fill interlaced'
knuth_shuffle           dta d'Knuth shuffle'
fill_ascending_with_shuffle     dta d'Fill ascending with shuffle'
insertion_sort          dta d'Insertion sort'
selection_sort          dta d'Selection sort'
quick_sort              dta d'Quick sort'
merge_sort              dta d'Merge sort'
bubble_sort             dta d'Bubble sort'
coctail_sort            dta d'Coctail sort'
gnome_sort              dta d'Gnome sort'
circle_sort             dta d'Circle sort'
comb_sort               dta d'Comb sort'
pancake_sort            dta d'Pancake sort'
shell_sort              dta d'Shell sort'
odd_even_sort           dta d'Odd-Even sort'
bitonic_sort            dta d'Bitonic sort'
radix_sort              dta d'Radix sort'
heap_sort               dta d'Heap sort'
double_selection_sort   dta d'Double selection sort'
main_menu_caption       dta d'SortViz'
demo_method_caption     dta d'Choose shuffle metod for demo'
paused_caption          dta d'Paused'
quit_caption            dta d'Quit?'
main_menu_keys          dta d' ', $40, d'Esc'*, $41, d'Exit ', $40, d'TAB'*, $41, d'Change image ', $40, d'Return'*, $41, d'Demo'
demo_method_keys        dta d' ', $40, d'Esc'*, $41, d'Cancel'
processing_keys         dta d' ', $40, d'Space'*, $41, d'Pause ', $40, $C2, $41, d'Faster ', $40, $C3, $41, d'Slower'
paused_keys             dta d' ', $40, d'Space'*, $41, d'Resume ', $40, d'Esc'*, $41, d'Abort'
quit_keys               dta d' ', $40, d'Y'*, $41, d'Yes ', $40, d'N'*, $41, d'No'