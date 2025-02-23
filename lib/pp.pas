unit pp;
(*
* @type: unit
* @author: Krzysztof 'Swiety/Zelax' Swiecicki, Tomasz 'Tebe' Biela
* @name: 'Power Packer' decompression unit
*
* @version: 1.0
*
* @description:
* Power Packer decompressor
*
* <https://github.com/lab313ru/powerpacker_src>
*
* <https://github.com/retrocoder68/PowerPacker>
*
*)

{

unPP

}

interface

procedure unPP(src, dst: pointer); external 'pp\unpp';
(*
@description:
*)


implementation

	{$link pp\unpp.obx}

end.
