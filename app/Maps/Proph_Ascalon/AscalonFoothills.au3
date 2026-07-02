#include <Array.au3>
Global $vqrange = 1450
Global $ActionCounter = 1

Global $aAscalonFoothillsTransitPath[6][2] = [ _
	[5683, -16716], _
	[8917, -14510], _
	[10306, -13417], _
	[11000, -16000], _
	[11200, -16800], _
	[11345, -17157] _
]

Func GoOutAscalonFoothills()
	Local $l_i_Map = GetMapID()

	If $l_i_Map = $AscalonFoothills_Map Then Return

	If $l_i_Map = $AscalonFoothills_Transit Then
		If $g_i_Vanquisher_GoOutLastMapHandled = $l_i_Map Then Return
		_Vanquisher_ApplyTravelersValeConsumables()
		$g_b_Vanquisher_TransitOnly = True
		CurrentAction("Traveler's Vale -> AscalonFoothills")
		_Vanquisher_RunAggroPortalPath($aAscalonFoothillsTransitPath, $vqrange, "outpost ")
		If GetMapID() <> $l_i_Map Then $g_i_Vanquisher_GoOutLastMapHandled = $l_i_Map
		$g_b_Vanquisher_TransitOnly = False
		Return
	EndIf

EndFunc

Func VQAscalonFoothills()
	If GetMapID() <> $AscalonFoothills_Map And GetMapID() <> $AscalonFoothills_Transit Then
		_Vanquisher_ResetGoOutRouteProgress()
		CurrentAction("AscalonFoothills route waiting - on map " & GetMapID() & ", need " & $AscalonFoothills_Map & " via Traveler's Vale.")
		Return
	EndIf

	If GetMapID() = $AscalonFoothills_Transit Then
		_Vanquisher_ApplyDifficulty()
		GoOutAscalonFoothills()
		If GetMapID() <> $AscalonFoothills_Map Then
			CurrentAction("Routing - on map " & GetMapID() & ", need AscalonFoothills (" & $AscalonFoothills_Map & ").")
			Return
		EndIf
	EndIf

	If GetMapID() <> $AscalonFoothills_Map Then
		CurrentAction("AscalonFoothills route waiting - on map " & GetMapID() & ", need " & $AscalonFoothills_Map & ".")
		Return
	EndIf

	CurrentAction("Starting AscalonFoothills vanquish route.")

	Local $aWaypoints[14][4] = [ _
		[-5785, 1558, " ", $vqrange], _
		[-2684, 2006, " ", $vqrange], _
		[-5544, -1613, " ", $vqrange], _
		[-3428, -5729, " ", $vqrange], _
		[373, -3274, " ", $vqrange], _
		[-3156, -2098, " ", $vqrange], _
		[-1639, 751, " ", $vqrange], _
		[621, -735, " ", $vqrange], _
		[2040, 2078, " ", $vqrange], _
		[240, 5077, " ", $vqrange], _
		[4885, 5096, " ", $vqrange], _
		[5939, 1126, " ", $vqrange], _
		[3321, -3531, " ", $vqrange], _
		[7394, -6932, " ", $vqrange] ]

	MoveandAggroVQFullRoute($aWaypoints)
EndFunc
