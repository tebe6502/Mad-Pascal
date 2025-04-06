{$ASSERTIONS ON}

// TODO: Should be ON but there some parts in the parser that stilly relay on array access with invalid indexes.
{$RANGECHECKS OFF}

//{$DEFINE WHILEDO}

//{$DEFINE USEOPTFILE}

{$DEFINE OPTIMIZECODE}

// The Delphi form is not accepted by PAS2JS
{$IFNDEF PAS2JS}
  {$I+}
{$ELSE}
  {$IOCHECKS ON}
{$ENDIF}

// Special cases for PAS2JS
{$IFDEF PAS2JS}
{$DEFINE SIMULATED_FILE_IO}
{$DEFINE SIMULATED_COMMAND_LINE}
{$ELSE}
{$DEFINE UPCASE_STRING}
{$ENDIF}
