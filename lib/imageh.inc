type

  {PIC Koala Microillustrator}
  TPicHeader = packed record
    id			: Cardinal;
    headln		: Word;
    revision,
    typcprs,
    antic		: Byte;
    scrwidth,
    scrheight		: Word;
    colors		: Array [0..4] of Byte;
    picln,
    unused		: Word;
  end;

  {Windows Bitmap header}
  TBmpHeader = packed record
    bfType		: Word;
    bfSize,
    bfReserved,
    bfOffBits,		// The offset, i.e. starting address, of the byte where the bitmap image data (pixel array) can be found.
    biSize,
    biWidth,
    biHeight		: Cardinal;
    biPlanes,
    biBitCount		: Word;
    biCompression,
    biSizeImage,
    biXPelsPerMeter,
    biYPelsPerMeter,
    biClrUsed		: Cardinal;
    biClrImportant,
    biClrRotation	: Byte;
    biReserved		: Word;
  end;

  {Z-Soft PCX header}
  PCXHeader = packed record
    Manufacturer,
    Version,
    Encoding,
    BitsPerPixel	: Byte;
    xMin,
    yMin,
    xMax,
    yMax		: SmallInt;
    Other		: Array [0..115] of Byte;
  end;

  {Compuserve GIF header}
  GIFHeader = packed record
    Signature		: String [6];
    ScreenWidth,
    ScreenHeight	: Word;
    Depth,
    Background,
    Zero		: Byte;
  end;

  {and GIF image descriptor}
  GIFDescriptor = packed record
    Separator		: Char;
    ImageLeft,
    ImageTop,
    ImageWidth,
    ImageHeight		: Word;
    Depth		: Byte;
  end;
