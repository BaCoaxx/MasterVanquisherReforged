#include "GUI_Zones.au3"
#include <WinAPI.au3>
#include <WinAPITheme.au3>
#include <WinAPIConstants.au3>

Global $strName = ""
Global $NumberRun = 0
Global $boolrun = False
Global $coords[2]
Global $Title, $sGW
Global $Bool_Donate = False, $Bool_Bu = False, $Bool_Stones = False
Global $Bool_OpenChests = False, $Bool_Conset = False

; Blue dashboard palette (AutoIt uses 0xRRGGBB colors)
Global Const $GUI_CLR_BG = 0x0B0F14       ; Version 5.0a near-black navy background
Global Const $GUI_CLR_PANEL = 0x121A24    ; card / panel navy
Global Const $GUI_CLR_INPUT = 0x0D1B2A    ; input and log surface
Global Const $GUI_CLR_BORDER = 0x163A63   ; subtle blue border
Global Const $GUI_CLR_ACCENT = 0x2F8CFF   ; clean blue accent
Global Const $GUI_CLR_ACTIVE = 0x1F5FAF   ; selected navigation button
Global Const $GUI_CLR_HEADER = 0x163A63   ; card header strip
Global Const $GUI_CLR_TEXT = 0xF1F7FF     ; clean white text
Global Const $GUI_CLR_MUTED = 0xA8B3C2    ; muted blue labels

Global $lvRoutes
Global $lblStatusValue, $lblStatusChar, $lblStatusCampaign, $lblStatusZone, $lblStatusQueue, $lblStatusTitle
Global $edtRoutePreview, $edtSessionLog

Opt("GUIOnEventMode", 1)

$Master_Vanquisher = GUICreate("Master Vanquisher Reforged", 1120, 760, -1, -1)
GUISetBkColor($GUI_CLR_BG)

; --- Header ---
Global $lblHeader = GUICtrlCreateLabel("MASTER VANQUISHER REFORGED", 28, 18, 600, 34)
GUICtrlSetFont(-1, 20, 800, 0, "Segoe UI")
GUICtrlSetColor(-1, $GUI_CLR_ACCENT)
Global $lblSubtitle = GUICtrlCreateLabel("Legendary Vanquisher Title Assistance", 30, 56, 420, 18)
GUICtrlSetFont(-1, 10, 400, 2, "Segoe UI")
GUICtrlSetColor(-1, 0x7DBEFF)
Global $lblTagline = GUICtrlCreateLabel("by Incognito-ghroot", 30, 76, 260, 18)
GUICtrlSetColor(-1, $GUI_CLR_MUTED)
Global $lblVersion = GUICtrlCreateLabel("Version 5.0a", 300, 76, 120, 18)
GUICtrlSetColor(-1, 0x6E7D91)
Global $lblStatusBadge = GUICtrlCreateLabel("IDLE", 500, 76, 82, 20, $SS_CENTER)
GUICtrlSetFont(-1, 9, 700, 0, "Segoe UI")
GUICtrlSetBkColor(-1, $GUI_CLR_HEADER)
GUICtrlSetColor(-1, $GUI_CLR_TEXT)

; --- Control bar ---
GUICtrlCreateLabel("Character", 28, 122, 70, 18)
GUICtrlSetColor(-1, $GUI_CLR_MUTED)
Global Const $txtName = GUICtrlCreateCombo($g_s_MainCharName, 105, 118, 190, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
If $doLoadLoggedChars Then GUICtrlSetData($txtName, Scanner_GetLoggedCharNames())
Global $btnRefreshChars = GUICtrlCreateButton("Refresh", 310, 118, 76, 25)
GUICtrlSetTip(-1, "Refresh Guild Wars client list")
GUICtrlSetOnEvent(-1, "RefreshCharNames")
Global $btnAttach = GUICtrlCreateButton("Attach", 394, 118, 70, 25)
GUICtrlSetTip(-1, "Connect to the selected Guild Wars character")
GUICtrlSetOnEvent(-1, "AttachToGuildWars")
Global $chkOnTop = GUICtrlCreateCheckbox("On Top", 484, 122, 75, 18)
GUICtrlSetOnEvent(-1, "gui_eventHandler")
Global $chkDebug = GUICtrlCreateCheckbox("Debug", 570, 122, 65, 18)
GUICtrlSetState(-1, $GUI_CHECKED)
Global $btnSaveQueue = GUICtrlCreateButton("Save Queue", 650, 118, 90, 25)
GUICtrlSetState(-1, $GUI_DISABLE)
Global $btnLoadQueue = GUICtrlCreateButton("Load Queue", 750, 118, 90, 25)
GUICtrlSetState(-1, $GUI_DISABLE)
Global $Start = GUICtrlCreateButton("Start Vanquishing", 870, 118, 145, 26)
GUICtrlSetOnEvent(-1, "gui_eventHandler")
Global $btnPause = GUICtrlCreateButton("Pause", 1025, 118, 70, 24)
GUICtrlSetState(-1, $GUI_DISABLE)
Global $btnStop = GUICtrlCreateButton("Stop", 1025, 146, 70, 24)
GUICtrlSetState(-1, $GUI_DISABLE)
Global $btnStartQueue = GUICtrlCreateButton("Start Queue", 1060, 116, 48, 48)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetState($btnStartQueue, $GUI_HIDE)

; --- Status bar ---
GUICtrlCreateLabel("Status:", 28, 166, 42, 16)
GUICtrlSetColor(-1, $GUI_CLR_MUTED)
$lblStatusValue = GUICtrlCreateLabel("WAITING FOR ATTACH", 86, 166, 160, 16)
GUICtrlSetColor(-1, $GUI_CLR_ACCENT)
GUICtrlCreateLabel("Character:", 265, 166, 62, 16)
GUICtrlSetColor(-1, $GUI_CLR_MUTED)
$lblStatusChar = GUICtrlCreateLabel("None", 335, 166, 125, 16)
GUICtrlSetColor(-1, $GUI_CLR_TEXT)
GUICtrlCreateLabel("Campaign:", 470, 166, 62, 16)
GUICtrlSetColor(-1, $GUI_CLR_MUTED)
$lblStatusCampaign = GUICtrlCreateLabel("None", 540, 166, 88, 16)
GUICtrlSetColor(-1, $GUI_CLR_TEXT)
GUICtrlCreateLabel("Current Zone:", 640, 166, 82, 16)
GUICtrlSetColor(-1, $GUI_CLR_MUTED)
$lblStatusZone = GUICtrlCreateLabel("None", 730, 166, 110, 16)
GUICtrlSetColor(-1, $GUI_CLR_TEXT)
GUICtrlCreateLabel("Queue:", 850, 166, 40, 16)
GUICtrlSetColor(-1, $GUI_CLR_MUTED)
$lblStatusQueue = GUICtrlCreateLabel("0 zones", 898, 166, 65, 16)
GUICtrlSetColor(-1, $GUI_CLR_TEXT)
GUICtrlCreateLabel("Title:", 990, 166, 32, 16)
GUICtrlSetColor(-1, $GUI_CLR_MUTED)
$lblStatusTitle = GUICtrlCreateLabel("0%", 1030, 166, 45, 16)
GUICtrlSetColor(-1, $GUI_CLR_ACCENT)

; --- Custom navigation buttons (replaces native tabs for consistent Windows styling) ---
Global $btnPageMain = GUICtrlCreateButton("Main", 610, 28, 86, 32)
GUICtrlSetOnEvent(-1, "_Vanquisher_TabClick")
Global $btnPageStats = GUICtrlCreateButton("Stats", 702, 28, 86, 32)
GUICtrlSetOnEvent(-1, "_Vanquisher_TabClick")
Global $btnPageAreas = GUICtrlCreateButton("Areas", 794, 28, 86, 32)
GUICtrlSetOnEvent(-1, "_Vanquisher_TabClick")
Global $btnPageLogs = GUICtrlCreateButton("Log", 886, 28, 86, 32)
GUICtrlSetOnEvent(-1, "_Vanquisher_TabClick")

; === Main page ===

Global $GENERAL = GUICtrlCreateGroup("", 24, 196, 260, 164)
Global $hdrGeneral = _Vanquisher_CreateCardHeader("GENERAL CONFIGURATOR", 24, 196, 260)
Global $Gui_Legio = GUICtrlCreateCheckbox("Use Stones", 40, 228, 200, 18)
Global $Gui_Bu = GUICtrlCreateCheckbox("Use BU", 40, 252, 200, 18)
Global $Gui_Conset = GUICtrlCreateCheckbox("Use Conset", 40, 276, 200, 18)
Global $Gui_OpenChests = GUICtrlCreateCheckbox("Open Chests", 40, 300, 200, 18)
Global $Gui_Donate = GUICtrlCreateCheckbox("Donate Faction", 40, 324, 200, 18)
GUICtrlSetTip($Gui_Donate, "Donate Luxon/Kurzick faction to your guild. Only used on Echovald Forest and Jade Sea maps.")

Global $grpSession = GUICtrlCreateGroup("", 306, 196, 250, 118)
Global $hdrSession = _Vanquisher_CreateCardHeader("SESSION STATS", 306, 196, 250)
Global $lblRuntime = GUICtrlCreateLabel("Runtime: 00:00:00", 326, 228, 210, 16)
Global $lblZonesDone = GUICtrlCreateLabel("Zones Completed: 0", 326, 252, 210, 16)
Global $lblDeaths = GUICtrlCreateLabel("Deaths: 0", 326, 276, 210, 16)
Global $lblFails = GUICtrlCreateLabel("Fails: 0", 326, 300, 210, 16)

Global $grpCharInfo = GUICtrlCreateGroup("", 306, 330, 250, 126)
Global $hdrCharInfo = _Vanquisher_CreateCardHeader("CHARACTER INFO", 306, 330, 250)
Global $lblCharName = GUICtrlCreateLabel("Name: None", 326, 362, 210, 16)
Global $lblCharProf = GUICtrlCreateLabel("Profession: Unknown", 326, 386, 210, 16)
Global $lblCharLevel = GUICtrlCreateLabel("Level: --", 326, 410, 210, 16)
Global $lblCharTitle = GUICtrlCreateLabel("Title Progress: 0%", 326, 434, 210, 16)

Global $grpRoute = GUICtrlCreateGroup("", 580, 196, 514, 234)
Global $hdrRoute = _Vanquisher_CreateCardHeader("CURRENT ROUTE", 580, 196, 514)
Global $edtRoutePreview = GUICtrlCreateEdit("", 594, 228, 486, 186, BitOR($ES_READONLY, $ES_MULTILINE, $WS_VSCROLL))
GUICtrlSetData(-1, "Select zones on the Routes tab." & @CRLF & "Route display is scrollable.")

Global $grpRecent = GUICtrlCreateGroup("", 580, 442, 514, 104)
Global $hdrRecent = _Vanquisher_CreateCardHeader("RECENT ACTIVITY", 580, 442, 514)
Global $lblRecentDone = GUICtrlCreateLabel("Completed: None", 598, 474, 480, 16)
Global $lblRecentSkip = GUICtrlCreateLabel("Skipped: None", 598, 498, 480, 16)
Global $lblRecentFail = GUICtrlCreateLabel("Last Fail: None", 598, 522, 480, 16)

Global $grpVanquish = GUICtrlCreateGroup("", 24, 376, 260, 104)
Global $hdrVanquish = _Vanquisher_CreateCardHeader("CURRENT ZONE", 24, 376, 260)
Global $lblKilled = GUICtrlCreateLabel("Killed", 44, 408, 90, 16)
Global $lblMissing = GUICtrlCreateLabel("Missing", 44, 432, 90, 16)
Global $lblTotalMobs = GUICtrlCreateLabel("Total Mobs", 44, 456, 90, 16)
Global $Tot_Killed = GUICtrlCreateLabel("0", 220, 408, 48, 16, $SS_RIGHT)
Global $Tot_Missing = GUICtrlCreateLabel("0", 220, 432, 48, 16, $SS_RIGHT)
Global $Tot_Total = GUICtrlCreateLabel("0", 220, 456, 48, 16, $SS_RIGHT)

; === Session tab ===
; GUICtrlCreateTabItem("Session") ; native tab removed
Global $grpSessionDetail = GUICtrlCreateGroup("", 24, 210, 520, 160)
Global $hdrSessionDetail = _Vanquisher_CreateCardHeader("SESSION OVERVIEW", 24, 210, 520)
Global $lblSessionRuntime = GUICtrlCreateLabel("Runtime: 00:00:00", 44, 242, 300, 18)
Global $lblSessionZones = GUICtrlCreateLabel("Zones Completed: 0", 44, 270, 300, 18)
Global $lblSessionDeaths = GUICtrlCreateLabel("Deaths: 0", 44, 298, 300, 18)
Global $lblSessionFails = GUICtrlCreateLabel("Fails: 0", 44, 326, 300, 18)
Global $RUN = GUICtrlCreateGroup("", 570, 210, 250, 160)
Global $hdrRuns = _Vanquisher_CreateCardHeader("RUNS", 570, 210, 250)
Global $lblTotalRuns = GUICtrlCreateLabel("Total Runs", 590, 242, 90, 17)
Global $gui_status_runs = GUICtrlCreateLabel("0", 760, 242, 40, 17, $SS_RIGHT)

; === Routes tab ===
; GUICtrlCreateTabItem("Routes") ; native tab removed
Global $grpRoutes = GUICtrlCreateGroup("", 24, 210, 1070, 370)
Global $hdrRoutes = _Vanquisher_CreateCardHeader("ZONE CHECKLIST", 24, 210, 1070)
$lvRoutes = GUICtrlCreateListView("Section|Zone", 36, 240, 1042, 298, BitOR($LVS_REPORT, $WS_VSCROLL, $WS_HSCROLL, $WS_BORDER))
_GUICtrlListView_SetExtendedListViewStyle($lvRoutes, BitOR($LVS_EX_CHECKBOXES, $LVS_EX_FULLROWSELECT, $LVS_EX_GRIDLINES))
_Vanquisher_PopulateRouteList()
Global $btnSelectAscalon = GUICtrlCreateButton("Select Ascalon", 36, 548, 130, 24)
GUICtrlSetTip(-1, "Check all nine Prophecies Ascalon zones for a full-section run")
GUICtrlSetOnEvent(-1, "_Vanquisher_OnSelectAscalon")
Global $btnClearZones = GUICtrlCreateButton("Clear Selection", 176, 548, 120, 24)
GUICtrlSetTip(-1, "Uncheck all zones")
GUICtrlSetOnEvent(-1, "_Vanquisher_OnClearZoneSelection")

; === Logs tab ===
; GUICtrlCreateTabItem("Logs") ; native tab removed
Global $grpLogsTab = GUICtrlCreateGroup("", 24, 210, 1070, 370)
Global $hdrLogsTab = _Vanquisher_CreateCardHeader("EVENT LOG", 24, 210, 1070)
$edtSessionLog = GUICtrlCreateEdit("", 36, 240, 1042, 320, BitOR($ES_READONLY, $ES_MULTILINE, $WS_VSCROLL, $ES_AUTOVSCROLL))
GUICtrlSetData(-1, "Session log entries also appear in the Live Log panel below.")

; GUICtrlCreateTabItem("") ; native tab removed

; --- Live log (always visible) ---
Global $grpLiveLog = GUICtrlCreateGroup("", 24, 608, 1070, 132)
Global $hdrLiveLog = _Vanquisher_CreateCardHeader("LIVE LOG", 24, 608, 1070)
Global $StatusLabel = GUICtrlCreateEdit("", 38, 638, 1040, 80, BitOR($ES_READONLY, $ES_MULTILINE, $WS_VSCROLL, $ES_AUTOVSCROLL))

Global $g_aPageMain[] = [$GENERAL, $hdrGeneral, $Gui_Legio, $Gui_Bu, $Gui_Conset, $Gui_OpenChests, $Gui_Donate, $grpSession, $hdrSession, $lblRuntime, $lblZonesDone, $lblDeaths, $lblFails, $grpCharInfo, $hdrCharInfo, $lblCharName, $lblCharProf, $lblCharLevel, $lblCharTitle, $grpRoute, $hdrRoute, $edtRoutePreview, $grpRecent, $hdrRecent, $lblRecentDone, $lblRecentSkip, $lblRecentFail, $grpVanquish, $hdrVanquish, $lblKilled, $lblMissing, $lblTotalMobs, $Tot_Killed, $Tot_Missing, $Tot_Total]
Global $g_aPageStats[] = [$grpSessionDetail, $hdrSessionDetail, $lblSessionRuntime, $lblSessionZones, $lblSessionDeaths, $lblSessionFails, $RUN, $hdrRuns, $lblTotalRuns, $gui_status_runs]
Global $g_aPageAreas[] = [$grpRoutes, $hdrRoutes, $lvRoutes, $btnSelectAscalon, $btnClearZones]
Global $g_aPageLogs[] = [$grpLogsTab, $hdrLogsTab, $edtSessionLog]
Global $g_sActivePage = "Main"

_Vanquisher_ApplyBlueTheme()
_Vanquisher_InitZones()

GUISetOnEvent($GUI_EVENT_CLOSE, "gui_eventHandler")
GUIRegisterMsg($WM_NOTIFY, "_GUI_WM_NOTIFY")

GUICtrlSetState($Gui_Donate, $GUI_ENABLE)
GUICtrlSetState($chkOnTop, $GUI_CHECKED)
WinSetOnTop($Master_Vanquisher, "", $HWND_TOPMOST)
_Vanquisher_UpdateDonateCheckbox()
_Vanquisher_UpdateStatusBar()
_Vanquisher_ShowPage("Main")

GUISetState(@SW_SHOW)
If $doLoadLoggedChars Then
	Local $l_s_StartupNames = Scanner_GetLoggedCharNames()
	If $l_s_StartupNames <> "" Then
		_Vanquisher_SetCharacterCombo($l_s_StartupNames, $g_s_MainCharName)
		CurrentAction("Characters: " & StringReplace($l_s_StartupNames, "|", ", "))
		_Vanquisher_SetConnectionStatus("READY")
	ElseIf ProcessExists("gw.exe") Then
		CurrentAction("Guild Wars detected — click Refresh to load characters.")
	Else
		CurrentAction("Start Guild Wars, log in, then click Refresh.")
	EndIf
Else
	_Vanquisher_SetCharacterCombo("", $g_s_MainCharName)
EndIf
CurrentAction("Dashboard initialized.")
CurrentAction("Ready.")

#Region Theme and route helpers

Func _Vanquisher_StripCtrlTheme($hWnd)
	If Not IsHWnd($hWnd) Then Return
	DllCall("uxtheme.dll", "int", "SetWindowTheme", "hwnd", $hWnd, "wstr", "", "wstr", "")
EndFunc

Func _Vanquisher_StripCtrlThemeById($iCtrlID)
	If $iCtrlID = 0 Then Return
	Local $hWnd = GUICtrlGetHandle($iCtrlID)
	If $hWnd Then _Vanquisher_StripCtrlTheme($hWnd)
EndFunc

Func _Vanquisher_StyleLabel($a_i_Ctrl, $a_bMuted = False, $a_bPanelBg = False)
	_Vanquisher_StripCtrlThemeById($a_i_Ctrl)
	GUICtrlSetBkColor($a_i_Ctrl, $a_bPanelBg ? $GUI_CLR_PANEL : $GUI_CLR_BG)
	GUICtrlSetColor($a_i_Ctrl, $a_bMuted ? $GUI_CLR_MUTED : $GUI_CLR_TEXT)
EndFunc

Func _Vanquisher_StyleAccentLabel($a_i_Ctrl, $a_bPanelBg = False)
	_Vanquisher_StripCtrlThemeById($a_i_Ctrl)
	GUICtrlSetBkColor($a_i_Ctrl, $a_bPanelBg ? $GUI_CLR_PANEL : $GUI_CLR_BG)
	GUICtrlSetColor($a_i_Ctrl, $GUI_CLR_ACCENT)
EndFunc

Func _Vanquisher_StyleGroup($a_i_Ctrl)
	_Vanquisher_StripCtrlThemeById($a_i_Ctrl)
	GUICtrlSetBkColor($a_i_Ctrl, $GUI_CLR_PANEL)
	GUICtrlSetColor($a_i_Ctrl, $GUI_CLR_ACCENT)
EndFunc


Func _Vanquisher_CreateCardHeader($sText, $iX, $iY, $iW)
	Local $iCtrl = GUICtrlCreateLabel("  " & $sText, $iX + 10, $iY + 8, $iW - 20, 20)
	GUICtrlSetFont($iCtrl, 9, 700, 0, "Segoe UI")
	GUICtrlSetBkColor($iCtrl, $GUI_CLR_HEADER)
	GUICtrlSetColor($iCtrl, $GUI_CLR_TEXT)
	Return $iCtrl
EndFunc

Func _Vanquisher_StyleCardHeader($a_i_Ctrl)
	_Vanquisher_StripCtrlThemeById($a_i_Ctrl)
	GUICtrlSetBkColor($a_i_Ctrl, $GUI_CLR_HEADER)
	GUICtrlSetColor($a_i_Ctrl, $GUI_CLR_TEXT)
	GUICtrlSetFont($a_i_Ctrl, 9, 700, 0, "Segoe UI")
EndFunc

Func _Vanquisher_StyleInput($a_i_Ctrl)
	_Vanquisher_StripCtrlThemeById($a_i_Ctrl)
	GUICtrlSetBkColor($a_i_Ctrl, $GUI_CLR_INPUT)
	GUICtrlSetColor($a_i_Ctrl, $GUI_CLR_TEXT)
	GUICtrlSetFont($a_i_Ctrl, 9, 400, 0, "Segoe UI")
EndFunc

Func _Vanquisher_StyleButton($a_i_Ctrl)
	_Vanquisher_StripCtrlThemeById($a_i_Ctrl)
	GUICtrlSetBkColor($a_i_Ctrl, $GUI_CLR_INPUT)
	GUICtrlSetColor($a_i_Ctrl, $GUI_CLR_TEXT)
EndFunc

Func _Vanquisher_RGBToBGR($iRGB)
	Return BitOR(BitShift(BitAND($iRGB, 0x0000FF), -16), BitAND($iRGB, 0x00FF00), BitShift(BitAND($iRGB, 0xFF0000), 16))
EndFunc

Func _Vanquisher_StyleListView($iCtrlID)
	_Vanquisher_StripCtrlThemeById($iCtrlID)
	Local $hWnd = GUICtrlGetHandle($iCtrlID)
	If Not $hWnd Then Return
	GUICtrlSetBkColor($iCtrlID, $GUI_CLR_INPUT)
	GUICtrlSetColor($iCtrlID, $GUI_CLR_TEXT)
	; ListView UDF color messages use COLORREF (BGR), unlike normal GUICtrl colors.
	_GUICtrlListView_SetBkColor($hWnd, _Vanquisher_RGBToBGR($GUI_CLR_INPUT))
	_GUICtrlListView_SetTextBkColor($hWnd, _Vanquisher_RGBToBGR($GUI_CLR_INPUT))
	_GUICtrlListView_SetTextColor($hWnd, _Vanquisher_RGBToBGR($GUI_CLR_TEXT))
	_GUICtrlListView_SetOutlineColor($hWnd, _Vanquisher_RGBToBGR($GUI_CLR_BORDER))
	Local $hHeader = _GUICtrlListView_GetHeader($hWnd)
	If $hHeader Then _Vanquisher_StripCtrlTheme($hHeader)
EndFunc

Func _Vanquisher_ApplyBlueTheme()
	GUISetBkColor($GUI_CLR_BG, $Master_Vanquisher)

	; Paint every legacy/static control first so Windows does not leave
	; white default label rectangles behind the dashboard. Known inputs, groups,
	; buttons, and panels are styled again below.
	For $iCtrl = 1 To 1200
		GUICtrlSetBkColor($iCtrl, $GUI_CLR_BG)
		GUICtrlSetColor($iCtrl, $GUI_CLR_TEXT)
	Next

	Local $aAccent[] = [$lblHeader, $lblSubtitle, $lblStatusValue, $lblStatusTitle]
	For $i = 0 To UBound($aAccent) - 1
		_Vanquisher_StyleAccentLabel($aAccent[$i])
	Next
	_Vanquisher_StyleLabel($lblTagline, True)
	_Vanquisher_StyleLabel($lblVersion, True)
	_Vanquisher_StyleCardHeader($lblStatusBadge)

	Local $aLabels[] = [$lblStatusChar, $lblStatusCampaign, $lblStatusZone, $lblStatusQueue, _
		$lblRuntime, $lblZonesDone, $lblDeaths, $lblFails, $lblCharName, $lblCharProf, $lblCharLevel, $lblCharTitle, _
		$lblRecentDone, $lblRecentSkip, $lblRecentFail, $lblKilled, $lblMissing, $lblTotalMobs, $lblTotalRuns, $Tot_Killed, $Tot_Missing, $Tot_Total, _
		$lblSessionRuntime, $lblSessionZones, $lblSessionDeaths, $lblSessionFails, $gui_status_runs]
	For $i = 0 To UBound($aLabels) - 1
		_Vanquisher_StyleLabel($aLabels[$i], False, True)
		GUICtrlSetFont($aLabels[$i], 9, 400, 0, "Segoe UI")
	Next

	Local $aGroups[] = [$GENERAL, $grpSession, $grpCharInfo, $grpRoute, $grpRecent, $grpVanquish, _
		$grpSessionDetail, $RUN, $grpRoutes, $grpLogsTab, $grpLiveLog]
	For $i = 0 To UBound($aGroups) - 1
		_Vanquisher_StyleGroup($aGroups[$i])
	Next

	Local $aCardHeaders[] = [$hdrGeneral, $hdrSession, $hdrCharInfo, $hdrRoute, $hdrRecent, $hdrVanquish, $hdrSessionDetail, $hdrRuns, $hdrRoutes, $hdrLogsTab, $hdrLiveLog, $lblStatusBadge]
	For $i = 0 To UBound($aCardHeaders) - 1
		_Vanquisher_StyleCardHeader($aCardHeaders[$i])
	Next

	Local $aInputs[] = [$txtName, $edtRoutePreview, $StatusLabel, $edtSessionLog]
	For $i = 0 To UBound($aInputs) - 1
		_Vanquisher_StyleInput($aInputs[$i])
	Next

	Local $aButtons[] = [$btnRefreshChars, $btnAttach, $Start, $btnSaveQueue, $btnLoadQueue, $btnPause, $btnStop, _
		$btnPageMain, $btnPageStats, $btnPageAreas, $btnPageLogs, $chkOnTop, $chkDebug, $Gui_Legio, $Gui_Bu, $Gui_Conset, $Gui_OpenChests, $Gui_Donate]
	For $i = 0 To UBound($aButtons) - 1
		_Vanquisher_StyleButton($aButtons[$i])
	Next

	_Vanquisher_StyleListView($lvRoutes)
	_Vanquisher_ShowPage("Main")
EndFunc

Func _Vanquisher_SetCtrlArrayState(ByRef $aCtrls, $iState)
	For $i = 0 To UBound($aCtrls) - 1
		If $aCtrls[$i] <> 0 Then GUICtrlSetState($aCtrls[$i], $iState)
	Next
EndFunc

Func _Vanquisher_ShowPage($sPage)
	_Vanquisher_SetCtrlArrayState($g_aPageMain, $GUI_HIDE)
	_Vanquisher_SetCtrlArrayState($g_aPageStats, $GUI_HIDE)
	_Vanquisher_SetCtrlArrayState($g_aPageAreas, $GUI_HIDE)
	_Vanquisher_SetCtrlArrayState($g_aPageLogs, $GUI_HIDE)

	Switch $sPage
		Case "Stats"
			_Vanquisher_SetCtrlArrayState($g_aPageStats, $GUI_SHOW)
		Case "Areas"
			_Vanquisher_SetCtrlArrayState($g_aPageAreas, $GUI_SHOW)
		Case "Logs"
			_Vanquisher_SetCtrlArrayState($g_aPageLogs, $GUI_SHOW)
		Case Else
			_Vanquisher_SetCtrlArrayState($g_aPageMain, $GUI_SHOW)
			$sPage = "Main"
	EndSwitch
	$g_sActivePage = $sPage
	GUICtrlSetBkColor($btnPageMain, ($sPage = "Main") ? $GUI_CLR_ACTIVE : $GUI_CLR_INPUT)
	GUICtrlSetBkColor($btnPageStats, ($sPage = "Stats") ? $GUI_CLR_ACTIVE : $GUI_CLR_INPUT)
	GUICtrlSetBkColor($btnPageAreas, ($sPage = "Areas") ? $GUI_CLR_ACTIVE : $GUI_CLR_INPUT)
	GUICtrlSetBkColor($btnPageLogs, ($sPage = "Logs") ? $GUI_CLR_ACTIVE : $GUI_CLR_INPUT)
	GUICtrlSetColor($btnPageMain, $GUI_CLR_TEXT)
	GUICtrlSetColor($btnPageStats, $GUI_CLR_TEXT)
	GUICtrlSetColor($btnPageAreas, $GUI_CLR_TEXT)
	GUICtrlSetColor($btnPageLogs, $GUI_CLR_TEXT)
EndFunc

Func _Vanquisher_TabClick()
	Switch @GUI_CtrlId
		Case $btnPageMain
			_Vanquisher_ShowPage("Main")
		Case $btnPageStats
			_Vanquisher_ShowPage("Stats")
		Case $btnPageAreas
			_Vanquisher_ShowPage("Areas")
		Case $btnPageLogs
			_Vanquisher_ShowPage("Logs")
	EndSwitch
EndFunc

Func _Vanquisher_PopulateRouteList()
	_Vanquisher_InitZones()
	_GUICtrlListView_BeginUpdate($lvRoutes)
	_GUICtrlListView_DeleteAllItems($lvRoutes)
	For $i = 0 To $g_i_VanquisherZoneCount - 1
		Local $iItem = _GUICtrlListView_AddItem($lvRoutes, _Vanquisher_ZoneSectionLabel($i), -1, $i + 1000)
		_GUICtrlListView_SetItem($lvRoutes, _Vanquisher_ZoneDisplay($i), $iItem, 1)
	Next
	_GUICtrlListView_SetColumnWidth($lvRoutes, 0, 120)
	_GUICtrlListView_SetColumnWidth($lvRoutes, 1, 780)
	_GUICtrlListView_EndUpdate($lvRoutes)
	_Vanquisher_StyleListView($lvRoutes)
EndFunc

Func _Vanquisher_ListViewZoneIndex($a_i_Item)
	Return _GUICtrlListView_GetItemParam($lvRoutes, $a_i_Item) - 1000
EndFunc

Func _Vanquisher_GetCheckedZoneIndexes()
	Local $aResult[0]
	Local $iCount = _GUICtrlListView_GetItemCount($lvRoutes)
	For $i = 0 To $iCount - 1
		If _GUICtrlListView_GetItemState($lvRoutes, $i, $LVIS_STATEIMAGEMASK) = 8192 Then
			_ArrayAdd($aResult, _Vanquisher_ListViewZoneIndex($i))
		EndIf
	Next
	Return $aResult
EndFunc

Func _Vanquisher_GetFirstCheckedZoneTitle()
	Local $aChecked = _Vanquisher_GetCheckedZoneIndexes()
	If UBound($aChecked) = 0 Then Return ""
	Return _Vanquisher_ZoneTitle($aChecked[0])
EndFunc

Func _Vanquisher_GetCheckedZoneCount()
	Return UBound(_Vanquisher_GetCheckedZoneIndexes())
EndFunc

Func _Vanquisher_SetZoneChecked($a_i_ZoneIndex, $a_bChecked)
	Local $iCount = _GUICtrlListView_GetItemCount($lvRoutes)
	For $i = 0 To $iCount - 1
		If _Vanquisher_ListViewZoneIndex($i) = $a_i_ZoneIndex Then
			_GUICtrlListView_SetItemChecked(GUICtrlGetHandle($lvRoutes), $i, $a_bChecked)
			Return
		EndIf
	Next
EndFunc

Func _Vanquisher_ClearZoneSelection()
	Local $iCount = _GUICtrlListView_GetItemCount($lvRoutes)
	For $i = 0 To $iCount - 1
		_GUICtrlListView_SetItemChecked(GUICtrlGetHandle($lvRoutes), $i, False)
	Next
	_Vanquisher_UpdateDonateCheckbox()
	_Vanquisher_UpdateStatusBar()
EndFunc

Func _Vanquisher_SelectZonesByRegion($a_s_Region)
	_Vanquisher_ClearZoneSelection()
	For $i = 0 To $g_i_VanquisherZoneCount - 1
		If StringCompare(_Vanquisher_ZoneRegion($i), $a_s_Region, 0) = 0 Then
			_Vanquisher_SetZoneChecked($i, True)
		EndIf
	Next
	_Vanquisher_UpdateDonateCheckbox()
	_Vanquisher_UpdateStatusBar()
EndFunc

Func _Vanquisher_OnSelectAscalon()
	_Vanquisher_SelectZonesByRegion("Ascalon")
	CurrentAction("Selected all Ascalon zones (9). Click Start Vanquishing to run the full section.")
EndFunc

Func _Vanquisher_OnClearZoneSelection()
	_Vanquisher_ClearZoneSelection()
	CurrentAction("Zone selection cleared.")
EndFunc

Func _Vanquisher_OnBotStopped()
	AdlibUnRegister("ReduceMemory")
	AdlibUnRegister("UpdateVanquish")
	AdlibUnRegister("CheckDeath")
	AdlibUnRegister("status")
	_Vanquisher_SetRoutesEnabled(True)
	GUICtrlSetState($Gui_Donate, $GUI_ENABLE)
	GUICtrlSetState($Gui_Bu, $GUI_ENABLE)
	GUICtrlSetState($Gui_Conset, $GUI_ENABLE)
	GUICtrlSetState($Gui_Legio, $GUI_ENABLE)
	GUICtrlSetState($Start, $GUI_ENABLE)
	GUICtrlSetState($txtName, $GUI_ENABLE)
	If $Bot_Core_Initialized Then
		_Vanquisher_SetConnectionStatus("ATTACHED")
	Else
		_Vanquisher_SetConnectionStatus("READY")
	EndIf
	$g_b_Vanquisher_SessionStarted = False
	_Vanquisher_UpdateStatusBar()
EndFunc

Func _Vanquisher_IsFactionMapSelected()
	Local $aChecked = _Vanquisher_GetCheckedZoneIndexes()
	For $i = 0 To UBound($aChecked) - 1
		If _Vanquisher_ZoneIsFaction($aChecked[$i]) Then Return True
	Next
	Return False
EndFunc

Func _Vanquisher_UpdateDonateCheckbox()
	GUICtrlSetState($Gui_Donate, $GUI_ENABLE)
	If Not _Vanquisher_IsFactionMapSelected() Then
		GUICtrlSetState($Gui_Donate, $GUI_UNCHECKED)
	EndIf
EndFunc

Func _Vanquisher_UpdateStatusBar()
	Local $sChar = GUICtrlRead($txtName)
	If $sChar = "" Then $sChar = "None"
	GUICtrlSetData($lblStatusChar, $sChar)

	Local $iQueue = _Vanquisher_GetCheckedZoneCount()
	GUICtrlSetData($lblStatusQueue, $iQueue & " zone" & ($iQueue = 1 ? "" : "s"))

	Local $aChecked = _Vanquisher_GetCheckedZoneIndexes()
	If UBound($aChecked) > 0 Then
		Local $iIdx = $aChecked[0]
		If $boolrun And $g_i_VanquisherZoneQueueIndex >= 0 And $g_i_VanquisherZoneQueueIndex < UBound($g_a_VanquisherZoneQueue) Then
			$iIdx = $g_a_VanquisherZoneQueue[$g_i_VanquisherZoneQueueIndex]
		EndIf
		GUICtrlSetData($lblStatusCampaign, _Vanquisher_ZoneSectionLabel($iIdx))
		GUICtrlSetData($lblStatusZone, _Vanquisher_ZoneDisplay($iIdx))
	Else
		GUICtrlSetData($lblStatusCampaign, "None")
		GUICtrlSetData($lblStatusZone, "None")
	EndIf
	_Vanquisher_UpdateRoutePreview()
EndFunc

Func _Vanquisher_UpdateRoutePreview()
	Local $aChecked = _Vanquisher_GetCheckedZoneIndexes()
	If UBound($aChecked) = 0 Then
		GUICtrlSetData($edtRoutePreview, "Select zones on the Routes tab." & @CRLF & "Route display is scrollable.")
		Return
	EndIf
	Local $sRoute = ""
	For $i = 0 To UBound($aChecked) - 1
		If $i > 0 Then $sRoute &= @CRLF
		$sRoute &= "-> " & _Vanquisher_ZoneSectionLabel($aChecked[$i]) & ": " & _Vanquisher_ZoneDisplay($aChecked[$i])
	Next
	GUICtrlSetData($edtRoutePreview, $sRoute)
EndFunc

Func _Vanquisher_SetRoutesEnabled($a_bEnable)
	Local $iState = $a_bEnable ? $GUI_ENABLE : $GUI_DISABLE
	GUICtrlSetState($lvRoutes, $iState)
	GUICtrlSetState($btnSelectAscalon, $iState)
	GUICtrlSetState($btnClearZones, $iState)
EndFunc

Func _GUI_WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
	Local $tNMHDR = DllStructCreate("hwnd hWndFrom;uint_ptr IDFrom;int Code", $lParam)
	If DllStructGetData($tNMHDR, "hWndFrom") = GUICtrlGetHandle($lvRoutes) Then
		If DllStructGetData($tNMHDR, "Code") = $LVN_ITEMCHANGED Then
			_Vanquisher_UpdateDonateCheckbox()
			_Vanquisher_UpdateStatusBar()
		EndIf
	EndIf
	Return $GUI_RUNDEFMSG
EndFunc

#EndRegion

Func gui_eventHandler()
	Switch @GUI_CtrlId
		Case $chkOnTop
			If BitAND(GUICtrlRead($chkOnTop), $GUI_CHECKED) = $GUI_CHECKED Then
				WinSetOnTop($Master_Vanquisher, "", $HWND_TOPMOST)
			Else
				WinSetOnTop($Master_Vanquisher, "", $HWND_NOTOPMOST)
			EndIf

		Case $GUI_EVENT_CLOSE
			Exit

		Case $Start
			If Not _Vanquisher_InitZoneQueueFromSelection() Then
				MsgBox(48, "Master Vanquisher Reforged", "No zone selected. Check at least one zone on the Areas tab, or click Select Ascalon.")
				Return
			EndIf
			$Title = _Vanquisher_ZoneTitle($g_a_VanquisherZoneQueue[0])
			Local $iQueueCount = UBound($g_a_VanquisherZoneQueue)
			If $iQueueCount > 1 Then
				CurrentAction("Zone queue: " & $iQueueCount & " zones — starting with " & _Vanquisher_ZoneDisplay($g_a_VanquisherZoneQueue[0]))
			EndIf

			If GUICtrlRead($txtName) = "" Then
				MsgBox(48, "Master Vanquisher Reforged", "Please select your character.")
				Return
			EndIf

			If Not $Bot_Core_Initialized Then
				If Not InitializeBot() Then Return
				WinSetTitle($Master_Vanquisher, "", Player_GetCharName())
				GUICtrlSetState($btnRefreshChars, $GUI_DISABLE)
				GUICtrlSetState($btnAttach, $GUI_DISABLE)
			EndIf

			$Bool_Donate = False
			$Bool_OpenChests = False
			$Bool_Conset = False
			$Bool_Bu = False
			$Bool_Stones = False
			If BitAND(GUICtrlRead($Gui_Donate), $GUI_CHECKED) = $GUI_CHECKED Then $Bool_Donate = True
			If BitAND(GUICtrlRead($Gui_OpenChests), $GUI_CHECKED) = $GUI_CHECKED Then $Bool_OpenChests = True
			If BitAND(GUICtrlRead($Gui_Conset), $GUI_CHECKED) = $GUI_CHECKED Then $Bool_Conset = True
			If BitAND(GUICtrlRead($Gui_Bu), $GUI_CHECKED) = $GUI_CHECKED Then $Bool_Bu = True
			If BitAND(GUICtrlRead($Gui_Legio), $GUI_CHECKED) = $GUI_CHECKED Then $Bool_Stones = True

			_Vanquisher_SetRoutesEnabled(False)
			GUICtrlSetState($Gui_Donate, $GUI_DISABLE)
			GUICtrlSetState($Gui_Bu, $GUI_DISABLE)
			GUICtrlSetState($Gui_Conset, $GUI_DISABLE)
			GUICtrlSetState($Gui_Legio, $GUI_DISABLE)
			GUICtrlSetState($Start, $GUI_DISABLE)
			GUICtrlSetState($txtName, $GUI_DISABLE)

			_Vanquisher_SetConnectionStatus("RUNNING")
			GUICtrlSetData($lblCharName, "Name: " & Player_GetCharName())

			$NumberRun = 0
			$RunSuccess = 0
			$g_b_Vanquisher_SessionStarted = False
			$g_b_Vanquisher_QueueAdvanced = False
			$boolrun = True

			$sGW = "Guild Wars - " & Player_GetCharName()
			AdlibRegister("ReduceMemory", 20000)
			AdlibRegister("UpdateVanquish", 5000)
			AdlibRegister("CheckDeath", 1000)
	EndSwitch
EndFunc

Func _Vanquisher_SetCharacterCombo($a_s_Names, $a_s_Preferred = "")
	$a_s_Names = StringStripWS($a_s_Names, 3)
	GUICtrlSetData($txtName, $a_s_Names)

	Local $l_s_Select = StringStripWS($a_s_Preferred, 3)
	If $l_s_Select = "" Then $l_s_Select = _Vanquisher_LoadLastCharacter()
	If $l_s_Select <> "" And $a_s_Names <> "" Then
		Local $aParts = StringSplit($a_s_Names, "|")
		Local $l_b_Found = False
		For $i = 1 To $aParts[0]
			If StringCompare($aParts[$i], $l_s_Select, 0) = 0 Then
				$l_b_Found = True
				ExitLoop
			EndIf
		Next
		If Not $l_b_Found Then $l_s_Select = $aParts[1]
	ElseIf $a_s_Names <> "" Then
		Local $aParts = StringSplit($a_s_Names, "|")
		If $aParts[0] >= 1 Then $l_s_Select = $aParts[1]
	EndIf

	If $l_s_Select <> "" Then
		If Not ControlCommand($Master_Vanquisher, "", $txtName, "SelectString", $l_s_Select) Then
			ControlSetText($Master_Vanquisher, "", $txtName, $l_s_Select)
		EndIf
	EndIf

	_Vanquisher_UpdateStatusBar()
EndFunc

Func _Vanquisher_SetConnectionStatus($a_s_Status)
	GUICtrlSetData($lblStatusValue, $a_s_Status)
	Switch StringUpper($a_s_Status)
		Case "RUNNING"
			GUICtrlSetColor($lblStatusValue, $GUI_CLR_ACCENT)
		Case "ATTACHED", "READY"
			GUICtrlSetColor($lblStatusValue, $GUI_CLR_TEXT)
		Case Else
			GUICtrlSetColor($lblStatusValue, $GUI_CLR_MUTED)
	EndSwitch
EndFunc

Func InitializeBot()
	Local $l_s_CharName = GUICtrlRead($txtName)
	If $l_s_CharName = "" And $g_s_MainCharName <> "" Then $l_s_CharName = $g_s_MainCharName

	Local $l_i_Result = 0
	If $l_s_CharName = "" Then
		$l_i_Result = Core_Initialize(ProcessExists("gw.exe"), True)
		If $l_i_Result = 0 Then
			MsgBox(0, "Error", "Guild Wars is not running.")
			Return False
		EndIf
	ElseIf $ProcessID Then
		Local $l_i_Pid = Number($ProcessID, 2)
		$l_i_Result = Core_Initialize($l_i_Pid, True)
		If $l_i_Result = 0 Then
			MsgBox(0, "Error", "Could not find a Guild Wars process with ID '" & $l_i_Pid & "'.")
			Return False
		EndIf
	Else
		$l_i_Result = Core_Initialize($l_s_CharName, True)
		If $l_i_Result = 0 Then
			MsgBox(0, "Error", "Could not find a Guild Wars client with a character named '" & $l_s_CharName & "'.")
			Return False
		EndIf
	EndIf

	_Vanquisher_SyncLegacyHandles()
	If $l_s_CharName <> "" Then _Vanquisher_SaveLastCharacter($l_s_CharName)
	$Bot_Core_Initialized = True
	Return True
EndFunc

Func StartBot()
	If $g_s_MainCharName <> "" Then
		GUICtrlSetData($txtName, $g_s_MainCharName)
	EndIf
	Return InitializeBot()
EndFunc

Func AttachToGuildWars()
	Local $l_s_Char = GUICtrlRead($txtName)
	If $l_s_Char = "" Then
		MsgBox(48, "Master Vanquisher Reforged", "Select or type your character name first, then click Attach.")
		Return
	EndIf

	If InitializeBot() Then
		_Vanquisher_SetConnectionStatus("ATTACHED")
		GUICtrlSetData($lblCharName, "Name: " & Player_GetCharName())
		$sGW = "Guild Wars - " & Player_GetCharName()
		CurrentAction("Attached to " & Player_GetCharName() & ". Select zones on Routes, then click Start Vanquishing.")
		Return
	EndIf

	_Vanquisher_SetConnectionStatus("WAITING FOR ATTACH")
	Local $l_s_FoundNames = Scanner_GetLoggedCharNames()
	Local $l_s_Msg = "Could not attach to '" & $l_s_Char & "'."
	If $l_s_FoundNames <> "" Then
		$l_s_Msg &= @CRLF & @CRLF & "Characters found in Guild Wars:" & @CRLF & StringReplace($l_s_FoundNames, "|", @CRLF)
		$l_s_Msg &= @CRLF & @CRLF & "Select one of those names and click Attach again."
	Else
		$l_s_Msg &= @CRLF & @CRLF & "No character name could be read from memory." & @CRLF & "Log fully into a character in-game, click Refresh, then Attach."
	EndIf
	CurrentAction("Could not attach to '" & $l_s_Char & "'. See live log for details.")
	MsgBox(48, "Master Vanquisher Reforged", $l_s_Msg)
EndFunc

Func RefreshCharNames()
	GUICtrlSetData($txtName, "")
	Local $l_s_Names = Scanner_GetLoggedCharNames()

	If $l_s_Names <> "" Then
		_Vanquisher_SetCharacterCombo($l_s_Names)
		CurrentAction("Characters: " & StringReplace($l_s_Names, "|", ", "))
		If Not $Bot_Core_Initialized Then _Vanquisher_SetConnectionStatus("READY")
		Return
	EndIf

	If ProcessExists("gw.exe") Then
		_Vanquisher_SetCharacterCombo("")
		CurrentAction("Guild Wars is running but no character names were found. Log in fully, then click Refresh.")
	Else
		_Vanquisher_SetCharacterCombo("")
		CurrentAction("No Guild Wars client found. Start Guild Wars, log in, then click Refresh.")
	EndIf
EndFunc

Func UpdateVanquish()
	Local $l_i_Killed = GetFoesKilled()
	Local $l_i_Missing = GetFoesToKill()
	GUICtrlSetData($Tot_Killed, $l_i_Killed)
	If $l_i_Missing < 0 Then
		GUICtrlSetData($Tot_Missing, "?")
		GUICtrlSetData($Tot_Total, "?")
	ElseIf $l_i_Missing = 0 And GetAreaVanquished() Then
		GUICtrlSetData($Tot_Missing, "0")
		GUICtrlSetData($Tot_Total, $l_i_Killed)
	Else
		GUICtrlSetData($Tot_Missing, $l_i_Missing)
		GUICtrlSetData($Tot_Total, $l_i_Killed + $l_i_Missing)
	EndIf
EndFunc

Func ReduceMemory()
	$hWnd = WinGetHandle($sGW)
	If WinExists($hWnd) Then
		$pid = WinGetProcess($hWnd)
		$Pr_Handle = DllCall("kernel32.dll", "int", "OpenProcess", "int", 0x1F0FFF, "int", False, "int", $pid)
		DllCall("psapi.dll", "int", "EmptyWorkingSet", "long", $Pr_Handle[0])
		DllCall("kernel32.dll", "int", "CloseHandle", "int", $Pr_Handle[0])
	EndIf
EndFunc

Func _Vanquisher_SetHeaderStatus($sText)
	Local $sLower = StringLower($sText)
	Local $sBadge = "IDLE"
	If StringInStr($sLower, "fight") Or StringInStr($sLower, "combat") Then
		$sBadge = "COMBAT"
	ElseIf StringInStr($sLower, "load") Or StringInStr($sLower, "travel") Or StringInStr($sLower, "portal") Then
		$sBadge = "TRAVEL"
	ElseIf StringInStr($sLower, "vanquish") Or StringInStr($sLower, "route") Then
		$sBadge = "VANQUISH"
	ElseIf StringInStr($sLower, "ready") Or StringInStr($sLower, "waiting") Or StringInStr($sLower, "attach") Then
		$sBadge = "IDLE"
	EndIf
	GUICtrlSetData($lblStatusBadge, $sBadge)
EndFunc

Func CurrentAction($TEXT)
	_Vanquisher_SetHeaderStatus($TEXT)
	Local $TEXTLEN = StringLen($TEXT)
	Local $CONSOLELEN = _GUICtrlEdit_GetTextLen($StatusLabel)
	If $TEXTLEN + $CONSOLELEN > 30000 Then GUICtrlSetData($StatusLabel, StringRight(_GUICtrlEdit_GetText($StatusLabel), 30000 - $TEXTLEN - 1000))
	_GUICtrlEdit_AppendText($StatusLabel, @CRLF & "[" & @HOUR & ":" & @MIN & "] " & $TEXT)
	_GUICtrlEdit_Scroll($StatusLabel, 1)
	_GUICtrlEdit_AppendText($edtSessionLog, @CRLF & "[" & @HOUR & ":" & @MIN & "] " & $TEXT)
	_GUICtrlEdit_Scroll($edtSessionLog, 1)
EndFunc

Func WaitForLoad()
	CurrentAction("Loading zone")
	InitMapLoad()
	$deadlock = 0
	Sleep(100)
	Do
		Sleep(100)
		$deadlock += 100
		$load = GetMapLoading()
		$lMe = GetAgentByID(-2)
	Until $load = 2 And DllStructGetData($lMe, "X") = 0 And DllStructGetData($lMe, "Y") = 0 Or $deadlock > 1000

	$deadlock = 0
	Do
		Sleep(100)
		$deadlock += 100
		$deadlock += 100
		$load = GetMapLoading()
		$lMe = GetAgentByID(-2)
	Until $load <> 2 And DllStructGetData($lMe, "X") <> 0 And DllStructGetData($lMe, "Y") <> 0 Or $deadlock > 3000
	CurrentAction("Load complete")
	Sleep(1000)
EndFunc
