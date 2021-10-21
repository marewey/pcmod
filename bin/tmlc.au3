Opt("WinTitleMatchMode", 2)

$hWnd = WinWaitActive("TLauncher 2.72") 
$pos = WinGetPos("TLauncher 2.72")
$x = 680
$y = 650

WinActivate($hWnd)
MouseClick("left", $pos[0] + $x, $pos[1] + $y,1,1)