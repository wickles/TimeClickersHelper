/**
 * Time Clickers AHK Script - v1.4.3.0
 * Updated for TCv1.4.3
 * Based on original script by iChun @ https://gist.github.com/iChun/c636d4feb9c058573175
 * Repository hosted @ https://github.com/wickles/TimeClickersHelper
 */
 
;; This script assumes you are running at 1280x720 resolution. 
;; May work with taller but same horizontal resolution, but this is not well tested. 
;; Note time(r)s are measured in milliseconds. 

#SingleInstance Force
#NoEnv
#Persistent

CoordMode, ToolTip, Client
CoordMode, Mouse, Client
CoordMode, Pixel, Client

global TotalSeconds := 0
global DoTimeWarp := false

global DoClick := false
global allowClick := false

global DoBuy := false
global BuyTimeOffset := 0
global KeyIndex := 0 ; Keys to look through (asdfg)
global DoSkills := false
global SkillCycle := 60 ; seconds between skill attempts

global DoIdleMode := false
global IdleTime := 0
global IdleCycle := (120 * 60) ; 120 minutes per idle cycle

SetTimer, TC_Ticker, 1000
SetTimer, TC_Clicker, 25
SetTimer, TC_Buy, 333
SetTimer, TC_Tooltip, 100
SetControlDelay -1

TimeWarp()
{
	IfWinActive ahk_exe TimeClickers.exe
	{
		DoTimeWarp := true
		Click, 1220, 320 ; Click on Time Warp
		Sleep, 200 ; Wait for GUI
		Click, 536, 514 ; Click yes to Time Warp
		Sleep, 1000 ; Wait for respec GUI
		Click, 1140, 345 ; Click start new timeline
		Sleep, 5000 ; Wait for Time Warp Timeout
		Loop, 20 ; Buy Click Pistol upgrades
		{
			PixelGetColor, PistolUpgrades, 1181, 239, RGB
			PixelGetColor, TW_Color, 1183, 317, RGB
			if(PistolUpgrades != 0x54d116 || TW_Color == 0xff7b00)
			{
				Send, hc
				Sleep, 50
			}
			else
			{
				Break
			}
		}
		Send, a
		Sleep, 100
		Send, s
		Sleep, 100
		Send, d
		Sleep, 100
		Send, f
		Sleep, 100
		Send, g
		Sleep, 100
		Send, qwe ; Enable Idle mode.
		Sleep, 100
		Click, 638, 400 ; Click the middle of the screen
		IdleTime := 0
		BuyTimeOffset := Mod(TotalSeconds, SkillCycle)
		DoTimeWarp := false
	}
	return
}

TC_Ticker:
TotalSeconds++
if(DoIdleMode)
{
	IdleTime++
}
; UpdateToolTip()
return

TC_Clicker:
MouseGetPos, xPos, yPos, winID
WinGet, winProcName, ProcessName, winID
PixelGetColor, LeaderboardButtonCol, 1007, 31, RGB
allowClick := ((xPos > 330 && xPos < 960 && yPos > 80 && yPos < 650) && (winProcName == TimeClickers.exe) && (LeaderboardButtonCol == 0xB2002A))
IfWinActive ahk_exe TimeClickers.exe
{
	if (!DoTimeWarp && DoClick && allowClick)
	{
		Click
	}
}
return

TC_Buy:
IfWinActive ahk_exe TimeClickers.exe
{
	if(!DoTimeWarp && DoBuy)
	{
		if(KeyIndex == 0)
		{
			Send, a
		}
		else if(KeyIndex == 1)
		{
			Send, s
		}
		else if(KeyIndex == 2)
		{
			Send, d
		}
		else if(KeyIndex == 3)
		{
			Send, f
		}
		else if(KeyIndex == 4)
		{
			Send, g
		}
		KeyIndex++
		if(KeyIndex >= 5)
		{
			KeyIndex := 0
		}
		if(Mod(TotalSeconds, SkillCycle) - BuyTimeOffset == 0 && !DoSkills)
		{
			DoSkills := true
			Send, {space}
			Send, 7
			Send, 0
		}
		else
		{
			DoSkills := false
		}
		if(IdleTime >= IdleCycle)
		{
			TimeWarp()
		}
	}
}
return

TC_ToolTip:
IfWinActive ahk_exe TimeClickers.exe
{
	TooltipString := "Buy Mode   (F1): " . DoBuy . "  |  Idle Mode (F2): " . DoIdleMode
	if(DoIdleMode)
	{
		TooltipString :=  TooltipString . " | Progress: " . IdleTime . "/" . IdleCycle
	}
	TooltipString := TooltipString .  "`n" . "Click Mode (F4): " . DoClick . "  |  Active: " . (DoClick && allowClick)
	ToolTip, %TooltipString%, 0, 62, 1
	; ToolTip, %BuyString%, 0, 62, 1
	; ToolTip, %ClickString%, 0, 81, 2
	
	;Progress, zh0 fs12, Test test test
}
else
{
	ToolTip,,,,1
	ToolTip,,,,2
}
return

;; Make all hotkeys defined below context-sensitive (TC window must be active). 
#IfWinActive ahk_exe TimeClickers.exe

q:: ; toggle weapon but do not remove weapon
Send, q
Sleep, 50
PixelGetColor, IconColor, 388, 687, RGB
if(IconColor == 0xffffff)
{
	Send, q
}
return

w:: ; toggle weapon but do not remove weapon
Send, w
Sleep, 50
PixelGetColor, IconColor, 580, 687, RGB
if(IconColor == 0xffffff)
{
	Send, w
}
return

e:: ; toggle weapon but do not remove weapon
Send, e
Sleep, 50
PixelGetColor, IconColor, 892, 686, RGB
if(IconColor == 0xffffff)
{
	Send, e
}
return

F1:: ; Toggle Buy
DoBuy := !DoBuy
if(DoBuy)
{
	BuyTimeOffset := Mod(TotalSeconds, SkillCycle)
}
else
{
	DoIdleMode := false
}
;UpdateToolTip()
return

F2:: ; Toggle Idle Mode
DoIdleMode := !DoIdleMode
;UpdateToolTip()
return

F4:: ; Toggle Clicker
DoClick := !DoClick
;UpdateToolTip()
return

F9:: ; Do Time Warp
TimeWarp()
return

F5::
Reload
return
#IfWinActive

F8::
ExitApp
return
