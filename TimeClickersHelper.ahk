/**
 * Time Clickers AHK Script - v1.3
 * Updated for TCv1.4.0
 * Based on original script by iChun @ https://gist.github.com/iChun/c636d4feb9c058573175
 * Repository hosted @ https://github.com/wickles/TimeClickersHelper
 */

#SingleInstance Force
#NoEnv
#Persistent

CoordMode, ToolTip, Client
CoordMode, Mouse, Client
CoordMode, Pixel, Client

global TotalSeconds := 0
global DoTimeWarp := false

global DoClick := false

global DoBuy := false
global BuyTimeOffset := 0
KeyIndex := 0 ; Keys to look through (asdfg)
DoSkills := false
global SkillCycle := 60 ; 60 seconds between skill attempts

global DoIdleMode := false
global IdleTime := 0
global IdleCycle := (120 * 60) ; 120 minutes per idle cycle

SetTimer, Tick, 1000
SetTimer, Click, 25
SetTimer, Buy, 200

UpdateToolTip()
{
	IfWinActive ahk_exe TimeClickers.exe
	{
		BuyString := "Buy Mode: " . DoBuy . " | Idle Mode: " . DoIdleMode
		if(DoIdleMode)
		{
			BuyString :=  BuyString . " | Progress: " . IdleTime . "/" . IdleCycle
		}
		ClickString := "Click Mode: " . DoClick
		ToolTip, %BuyString%, 0, 62, 1
		ToolTip, %ClickString%, 0, 81, 2
	}
	else
	{
		ToolTip,,,,1
		ToolTip,,,,2
	}
	return
}

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
			PixelGetColor, TimeWarp, 1183, 317, RGB
			if(PistolUpgrades != 0x54d116 || TimeWarp == 0xff7b00)
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

Tick:
TotalSeconds++
if(DoIdleMode)
{
	IdleTime++
}
UpdateToolTip()
return

Click:
IfWinActive ahk_exe TimeClickers.exe
{
	if(!DoTimeWarp && DoClick)
	{
		Click
	}
}
return

Buy:
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

#IfWinActive ahk_exe TimeClickers.exe
^z:: ; Toggle Buy
DoBuy := !DoBuy
if(DoBuy)
{
	BuyTimeOffset := Mod(TotalSeconds, SkillCycle)
}
else
{
	DoIdleMode := false
}
UpdateToolTip()
return

^x:: ; Toggle Idle Mode
DoIdleMode := !DoIdleMode
UpdateToolTip()
return

+z:: ; Toggle Clicker
DoClick := !DoClick
UpdateToolTip()
return

+^z:: ; Do Time Warp
TimeWarp()
return

i:: ; Toggle Idle Mode
PixelGetColor, RocketColor, 406, 668, RGB
if(RocketColor == 0xff7c00)
{
	Send, qq
}
else
{
	Send, q
}
Sleep, 100
PixelGetColor, CannonColor, 598, 668, RGB
if(CannonColor == 0xff7c00)
{
	Send, ww
}
else
{
	Send, w
}
Sleep, 100
PixelGetColor, PistolColor, 911, 668, RGB
if(PistolColor == 0xff7c00)
{
	Send, ee
}
else
{
	Send, e
}
return

z:: ;disable changing promo type
return

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

F8::
Reload
return
#IfWinActive

F6::
ExitApp
return