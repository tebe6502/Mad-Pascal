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
