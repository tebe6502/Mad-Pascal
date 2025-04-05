type
  TMonthNameArray = array [1..12] of String;

type
  TWeekNameArray = array [1..7] of String;


type
  TFormatSettings = record

    CurrencyFormat: Byte; // Currency format string
    NegCurrFormat: Byte; // Negative currency format string
    ThousandSeparator: Char; // Thousands separator character
    DecimalSeparator: Char; // Decimal separator character
    CurrencyDecimals: Byte; // Currency decimals
    DateSeparator: Char; // Date separator character
    TimeSeparator: Char; // Time separator character
    ListSeparator: Char; // List separator character
    CurrencyString: String; // Currency string
    ShortDateFormat: String; // Short date format string
    LongDateFormat: String; // Long Date Format string
    TimeAMString: String; // AM time indicator string
    TimePMString: String; // PM time indicator string
    ShortTimeFormat: String; // Short time format string
    LongTimeFormat: String; // Long time format string
    ShortMonthNames: TMonthNameArray; // Array with short month names
    LongMonthNames: TMonthNameArray; // Array with long month names
    ShortDayNames: TWeekNameArray; // Array with short day names
    LongDayNames: TWeekNameArray; // Long day names
    TwoDigitYearCenturyWindow: Word; // Value for 2 digit year century window
  end;

// https://www.freepascal.org/docs-html/rtl/sysutils/defaultformatsettings.html
var
  DefaultFormatSettings: TFormatSettings = (CurrencyFormat: 1; NegCurrFormat: 5; ThousandSeparator: ',';
  DecimalSeparator: '.'; CurrencyDecimals: 2; DateSeparator: '-'; TimeSeparator: ':';
  ListSeparator: ','; CurrencyString: '$'; ShortDateFormat: 'd/m/y'; LongDateFormat: 'dd" "mmmm" "yyyy';
  TimeAMString: 'AM'; TimePMString: 'PM'; ShortTimeFormat: 'hh:nn'; LongTimeFormat: 'hh:nn:ss';
  ShortMonthNames: ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
  LongMonthNames: ('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December'); ShortDayNames: ('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat');
  LongDayNames: ('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday');
  TwoDigitYearCenturyWindow: 50);


// https://www.freepascal.org/docs-html/rtl/sysutils/ansilowercase.html
function AnsiLowerCase(const s: String): String;


// https://www.freepascal.org/docs-html/rtl/sysutils/ansiuppercase.html
function AnsiUpperCase(const s: String): String;

// https://www.freepascal.org/docs-html/rtl/system/compareword.html
function CompareWord(const buf1; const buf2; len: SizeInt): SizeInt;

// https://www.freepascal.org/docs-html/rtl/sysutils/gettickcount64.html
function GetTickCount64: QWord;

