// The unit is caled "CommonTypes" to prevent conflicts with the general system unit "Types".

unit CommonTypes;

interface

// Temporary type mapping for tests
// type Int64 = LongInt;
// type QWord = Int64;
// type Single = Double;

// TInteger is intended as the largest type of signed integer values that can represent numbers without gaps.
{$IFNDEF PAS2JS}
type
  TInteger = Int64;
{$ELSE}
type TInteger = Integer;
{$ENDIF}


implementation

end.
