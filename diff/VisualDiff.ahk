#Include <WebView2\WebView2>
#Requires AutoHotkey v2.0

main := Gui(, "v1 -> v2 Diff")
main.OnEvent("Close", (*) => ExitApp())
main.Show(Format("x{} y{} w{} h{}", 0, 0, A_ScreenWidth * 0.9, A_ScreenHeight * 0.9))
WinMaximize(main.Title)

if (A_Args.Length = 2) {
	v1File := FileRead(A_Args[1])
	v2File := FileRead(A_Args[2])
} else {
	v1File := "This is the AutoHotkey v1 side, the old code"
	v2File := "This is the AutoHotkey v2 side, the new code"
}

wvc := WebView2.CreateControllerAsync(main.Hwnd).await2()
wv := wvc.CoreWebView2
wv.add_NavigationCompleted(injectMergely)
wv.Navigate(A_ScriptDir "\lib\template.html")

Sleep(1000) ; TODO: Receive message when wv is loaded and then call
injectMergely()

#HotIf WinActive(main.Title)
^r:: {
	ToolTip "Working"
	wv.reload()
	Sleep(2000)
	injectMergely() ; If above does not load this can fix it
	ToolTip "Reloaded"
	Sleep(2000)
	ToolTip
}

sanitiseInput(str) {
	str := StrReplace(str, "'", "\'")
	str := StrReplace(str, "\", "\\")
	str := StrReplace(str, "`r`n", "\n")
	return str
}

injectMergely(*) {
	Sleep(100)
	;ToolTip "Sending Script"
	res := wv.ExecuteScriptAsync(
		"doc.lhs('" sanitiseInput(v1File) "');`r`n"
		"doc.rhs('" sanitiseInput(v2File) "');`r`n"
	)
	;MsgBox res.await()
}