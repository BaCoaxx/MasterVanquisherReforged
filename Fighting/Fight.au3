
Func Fight($x, $s = "")
	CurrentAction("Fighting Group #:" & $s)
	If GetPartyDead() Then Return

	Local $target, $distance, $useSkill, $targetHP, $tDeadlock = TimerInit()

	Do
		If GetPartyDead() Or $DeadOnTheRun Then ExitLoop
		If _Vanquisher_IsVanquishComplete() Then ExitLoop
		If GetNumberOfFoesInRangeOfAgent(-2, $x) = 0 Then ExitLoop
		If TimerDiff($tDeadlock) > 120000 Then ExitLoop

		$useSkill = -1
		$target = GetNearestEnemyToAgent(-2, $x)
		If $target = 0 Then ExitLoop

		$distance = GetDistance($target, -2)
		If _Vanquisher_AgentID($target) <> 0 And $distance < $x And _Vanquisher_AgentHP($target) > 0 Then
			ChangeTarget($target)
			Sleep(150)
			CallTarget($target)
			Sleep(150)
			Attack($target)
			Sleep(150)
		ElseIf _Vanquisher_AgentID($target) = 0 Or $distance >= $x Or _Vanquisher_AgentHP($target) <= 0 Then
			Sleep(250)
			ContinueLoop
		EndIf

		If _IsSkillUseEnabled() Then
			For $i = 0 To $totalskills
				$targetHP = _Vanquisher_AgentHP(GetCurrentTarget())
				If $targetHP <= 0 Then ExitLoop 2

				$distance = GetDistance($target, -2)
				If $distance >= $x Then ExitLoop 2
				If GetNumberOfFoesInRangeOfAgent(-2, $x) = 0 Then ExitLoop 2

				$energy = GetEnergy(-2)
				$recharge = DllStructGetData(GetSkillBar(), "Recharge" & ($i + 1))
				$adrenaline = DllStructGetData(GetSkillBar(), "AdrenalineA" & ($i + 1))

				If $recharge = 0 And $energy >= $intSkillEnergy[$i] And $adrenaline >= ($intSkillAdrenaline[$i] * 25 - 25) Then
					$useSkill = $i + 1
					PingSleep(100)
					UseSkill($useSkill, $target)
					Sleep($intSkillCastTime[$i] + 1000)
				EndIf
				If $i = $totalskills Then $i = 0
			Next
		Else
			CurrentAction("Waiting on Combat")
			PingSleep(3000)
		EndIf
	Until $DeadOnTheRun Or GetNumberOfFoesInRangeOfAgent(-2, $x) = 0 Or TimerDiff($tDeadlock) > 120000

	UpdateVanquish()
	CurrentAction("Combat ended after: " & StringFormat("%d", TimerDiff($tDeadlock) / 1000) & "s")

	If GetHealth(-2) < 2400 Then UseSkill(7, -2)
	PingSleep(3000)
	CurrentAction("Picking up items")
	PickUpLoot()
EndFunc   ;==>Fight

Func _IsSkillUseEnabled()
    Return GUICtrlRead($Gui_UseSkills) = $GUI_CHECKED
EndFunc
