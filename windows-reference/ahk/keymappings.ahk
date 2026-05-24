#NoEnv
#Warn
SetWorkingDir %A_ScriptDir%
SendMode Input
; If the script is not elevated, relaunch as administrator and kill current instance:
full_command_line := DllCall("GetCommandLine", "str")
if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
    try
    {
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" /restart
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
    }
    ExitApp
}

CapsLock::LCtrl
LCtrl::CapsLock
RCtrl::LWin
^[::SendInput {Esc}

!b::Send ^{Left}
!f::Send ^{Right}
!j::Send {Down}
!k::Send {Up}
!a::Send {Home}
!e::Send {End}


; Ctrl+Alt+Q :Search selection with google
^!q::
Clipboard := ""              ; clear clipboard
Send ^c                      ; copy selection
ClipWait, 1.0                ; wait up to 1.0s for clipboard
query := Clipboard
StringReplace, query, query, `r`n, %A_Space%, All
StringReplace, query, query, %A_Space%, +, All
Run, https://www.google.com/search?q=%query%
return

; Ctrl+Alt+T: translate selection with google translate
^!t::
Clipboard := ""
Send ^c
ClipWait, 1.0
text := Clipboard
StringReplace, text, text, `r`n, %A_Space%, All
StringReplace, text, text, %A_Space%, `%20, All
Run, https://translate.google.com/?sl=en&tl=zh-CN&text=%text%&op=translate
return

; Ctrl+Alt+P: copy active process name
^!p::
  WinGet, exeName, ProcessName, A
  WinGetTitle, windowTitle, A
  Clipboard := exeName
  ToolTip,  %exeName%`n %windowTitle%`n, A_ScreenWidth/2, A_ScreenHeight/2
  SetTimer, RemoveToolTip, 3000
return



RemoveToolTip:
  SetTimer, RemoveToolTip, Off
  ToolTip
return

; Alt+mouse for volume
Alt & WheelUp::Volume_Up
Alt & WheelDown::Volume_Down
Alt & MButton::Volume_Mute
MButton::Browser_Back

; quick launch app
#0::SwitchToApp("ahk_exe chrome.exe")
SwitchToApp(AppSelector) {
    TargetExe := StrReplace(AppSelector, "ahk_exe ", "")
    IfWinExist, ahk_exe %TargetExe%
        WinActivate
    else
        Run, %TargetExe%
}


; 当物理按住反引号键（vkC0）时，激活数字键映射
#If GetKeyState("vkC0", "P")
1::Send #1
2::Send #2
3::Send #3
4::Send #4
5::Send #5
6::Send #6
7::Send #7
8::Send #8
9::Send #9
0::Send #0
#If

; 确保单独按下并松开反引号键时，依然能正常打出 ` 字符
$vkC0::
KeyWait, vkC0
if (A_PriorKey = "vkC0") {
    SendRaw ``
}
return
