#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
CapsLock::Send {ctrl down}c{ctrl up}

; Download: https://github.com/pmb6tz/windows-desktop-switcher
; Change the original implementation to use Left Alt + Num (e.g. <!1)
; It is important that it is only Left Alt so Right Alt can be used with I3

CapsLock::
CapsLock & q::
CapsLock & w::
CapsLock & e::
CapsLock & a::
CapsLock & s::
CapsLock & d::
CapsLock & f::
CapsLock & z::
CapsLock & x::
CapsLock & c::
CapsLock & v::
CapsLock & g::
CapsLock & r::
CapsLock & p::
CapsLock & n::
CapsLock & up::
CapsLock & down::
CapsLock & left::
CapsLock & right::
CapsLock & home::
CapsLock & end::
CapsLock & space::
CapsLock & backspace::
+CapsLock::	; Shift+CapsLock
!CapsLock::	; Alt+CapsLock
^CapsLock::		; Ctrl+CapsLock
#CapsLock::		; Win+CapsLock
^!CapsLock::	; Ctrl+Alt+CapsLock
^!#CapsLock::	; Ctrl+Alt+Win+CapsLock
return			; Do nothing, return
