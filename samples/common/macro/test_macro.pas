uses crt;

var
	lineStat: byte;
	statLineBegin: byte;

{$DEFINE isBeginTag(nTag) := ((tag=nTag) and (prevTag<>nTag))}
{$DEFINE isEndTag(nTag) := ((tag<>nTag) and (prevTag=nTag))}
{$DEFINE isTag(nTag) := (tag=nTag)}

{$DEFINE isHeader(nTag) := ((nTag>=tagH1) and (nTag<=tagH4))}
{$DEFINE isLink(nTag) := ((nTag>=tagLink) and (nTag<=tagImageDescription))}
{$DEFINE isList(nTag) := ((nTag>=tagList) and (nTag<=tagListOrdered))}
{$DEFINE isBlock(nTag) := ((nTag>=tagBlock) and (nTag<=tagCode))}

{$DEFINE isHeader := ((tag>=tagH1) and (tag<=tagH4))}
{$DEFINE isLink := ((tag>=tagLink) and (tag<=tagImageDescription))}
{$DEFINE isList := ((tag>=tagList) and (tag<=tagListOrdered))}
{$DEFINE isBlock := ((tag>=tagBlock) and (tag<=tagCode))}

{$DEFINE isStyle(nStyle) := (style and nStyle<>0)}

{$DEFINE isWordBegin := (lineStat and statWordBegin<>0)}
{$DEFINE isLineBegin := (lineStat and statLineBegin<>0) }
{$DEFINE isLineEnd := (lineStat and statEndOfLine<>0)}



begin


if isLineBegin then ;


end.