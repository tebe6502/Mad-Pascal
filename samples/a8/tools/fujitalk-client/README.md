# FujiTalk Client
---
FujiTalk is a chat client for 8-bit atari computers equipped with FujiNet interface.
It is similar to IRC clients, but much simplier.

## Keyboard

|Key|Function|
|--|--|
|START|Switches to the server tab.|
|SELECT|Switches to the next channel/private tab.|
|OPTION|Changes colour theme.|

## Commands

|Syntax|Description|
|--|--|
|/help|Shows basic help.|
|/server|Shows current server address.|
|/server address:port|Sets new server address.|
|/register nick password|Registers new user on the server and logs it in.|
|/login nick password|Logs in user on the server.|
|/logout|Logs you out from server.|
|/auth|Logs in user using token stored on FujiNet device (SD card).|
|/clist|Shows 10 most active channels on the server.|
|/who|Shows all currently logged in users.|
|/j channel or /join channel|Joins the selected channel. If the channel does not exist, it will be created|
|/j \@nick or /join \@nick|Start private conversation with selected user.|
|/l [channel] or /leave [channel]|Leaves the selected channel. If no channel is selected, it leaves current tab.|
|/list|Lists all users on current channel.|
|/priv|Shows your unread private messages.|
|/reload|Refreshes current tab (clears all console messages).|
|/conf sioaudio|Shows status of sioAudio setting (0=off / 1=on).|
|/conf sioaudio 1/0 |Sets sioAudio setting.|
|/conf console|Shows status of console messages option (0=only first tab / 1=all tabs).|
|/conf console 1/0|Sets console messages target (0=only first tab / 1=all tabs).|



