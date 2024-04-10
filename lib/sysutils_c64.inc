
procedure Beep;
(*
@description: Sound the system bell
*)
begin


end;


procedure Click ; assembler;
(*
@description: Sound the system click
*)
asm

end;


function GetTickCount: cardinal; assembler;
(*
@description: Get tick count

@returns: 32bit tick count
*)
asm
	txa:pha

	jsr $FFDE
	sta Result
	stx Result+1
	sty Result+2

	lda #$00
	sta Result+3

	pla:tax
end;


function FindFirst(FileMask: PString; Attributes: Byte; var SearchResult: TSearchRec): byte;
(*
@description: Start a file search and return a findhandle

@param: FileMask: string[32]
@param: Attributes: Byte
@param: SearchResult: TSearchRec

@returns: =0 file matching the specified criteria is found
*)
begin

end;


function FindNext(var f: TSearchRec): byte; assembler;
(*
@description: Find the next entry in a findhandle

@param: var f: TSearchRec

@returns: =0 record matching the criteria, successful
*)
asm

end;


procedure FindClose(var f: TSearchRec); assembler;
(*
@description: Close a find handle

@param: var f: TSearchRec
*)
asm

end;


function RenameFile(var OldName,NewName: TString): Boolean; assembler;
(*
@description: Renames a file from OldName to NewName

@param: var OldName: string[32]
@param: var NewName: string[32]

@returns: TRUE - successful
@returns: FALSE - I/O error
*)
asm

end;


function DeleteFile(var FileName: TString): Boolean; assembler;
(*
@description: Delete a file from the filesystem

@param: var FileName: string[32]

@returns: TRUE - the file was successfully removed
@returns: FALSE - I/O error
*)
asm

end;


function FileExists(name: PString): Boolean;
(*
@description: Check whether a particular file exists in the filesystem

@param: name: string[32]

@returns: TRUE - file exists
@returns: FALSE - file not exists
*)
begin

end;


function Now: TDateTime;
(*
@description:
Read actual Date-Time (Sparta DOS X, R-Time 8, SIO Real-Time Clock)

@returns: TDateTime
*)
begin

end;

