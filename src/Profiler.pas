unit Profiler;

(* https://wiki.freepascal.org/LazProfiler *)
(* https://forum.lazarus.freepascal.org/index.php?topic=72466.msg567367#msg567367 *)

interface


type
  IProfiler = interface
    procedure BeginSection(const Name: String);
    procedure EndSection();

  end;

type
  TProfiler = class(TInterfacedObject, IProfiler)
  public
  type TLevel = Integer;
    constructor Create;
    procedure BeginSection(const Name: String);
    procedure EndSection;

  private
  type TEntry = record
      level: TLevel;
      Name: String;
      startTime: QWord;
      EndTime: QWord;
    end;

  var
    level: TLevel;
  type TEntryArray = array of TEntry;
  var
    EntryArray: TEntryArray;
  end;


  // Currently global, because COmpiler, Parser,... share it.
var
  Profiler: IProfiler;

implementation

uses Common, SysUtils;

constructor TProfiler.Create;
begin
  EntryArray := nil;

end;


procedure TProfiler.BeginSection(const Name: String);
var
  entry: TEntry;
begin
  Inc(level);
  entry.level := level;
  entry.Name := Name;
  entry.startTime := GetTickCount64();
  SetLength(EntryArray, level+1);
  EntryArray[level] := entry;
end;


procedure TProfiler.EndSection();
var
  seconds: Real;
  entryPtr: ^TEntry;
  message: String;
begin
  assert(Level > 0);
  entryPtr := Addr(EntryArray[level]);
  entryPtr^.endTime := GetTickCount64();
  seconds := (entryPtr^.EndTime - entryPtr^.StartTime + 500) / 1000;
  message:=Format('Profiler level %d section %s ended after %.2f seconds.', [entryPtr^.level, entryPtr^.Name, seconds]);
  LogTrace(message);
  writeln(message);

  Dec(level);
end;



end.
