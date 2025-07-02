{

https://gitlab.com/bocianu/MadKingdom/tree/master

}

program VoxRegis;
uses cardgui, cardlib, graph;
{$r chars.rc}
{$r cards.rc}

var     key, titleKey : char;
        playersChoice : byte;

begin

    InitGui;
    repeat
        ShowTitleScreen;
	musicStart(MSX_TITLE);

        titleKey := ReadKeyOrFire;
        if titleKey <> 'q' then begin
	
            Randomize;
            InitKingdom;
            InitHand;
            NewTable($66);
            ShowGameScreen;
	    musicStart(MSX_INGAME);

            repeat
                ShowStats;
                ShowTable;
                PickCard(SelectCard);
                ShowCard;
                playersChoice := ReadUserChoice;
                ProcessCard(playersChoice);
                ShowResponse(playersChoice);
                IncTime;
                showIncome;
                key := ReadKeyOrFire;
                if (GetSeason = SEASON_SPRING) then begin // end of year
					checkEnding;
					if kingdom.kingAlive = true then begin
						ShowStats;
						NewTable($66);
						key := ShowEndOfYear;
					end else begin
						musicStart(MSX_INTERLUDE);
						key := showEnding(kingdom.ending);
					end;
                end;
            until (key = 'q') or (kingdom.kingAlive = false);

        end;
    until (titleKey = 'q');
    InitGraph(0);
    ReleaseGui;
end.

