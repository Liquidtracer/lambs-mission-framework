/*
	Admin diary
	Creates the admin diary entries; included by createBriefing.sqf.
*/

player createDiarySubject ["lmf_adminTools", "Admin", "\A3\modules_f\data\portraitmodule_ca.paa"];

// Admin tools
player createDiaryRecord ["lmf_adminTools", ["Tools", format ["
<font face='PuristaBold' color='%1' size='16'>Tools</font><br/>
<font >These tools require LMF or server admin access.</font><br/><br/>
<font face='PuristaBold' >
• <execute expression='[player] call lmf_admin_fnc_endWarmup'>Start Mission</execute><br/><br/>
• <execute expression='[player] call lmf_admin_fnc_triggerRespawnWave'>Respawn Wave</execute><br/><br/>
• <execute expression='[player] remoteExec [""lmf_admin_fnc_assignZeus"",2]'>Zeus Access</execute><br/><br/>
• <execute expression='[player] remoteExec [""lmf_admin_fnc_requestPerformanceReport"",2]'>Performance Check</execute><br/><br/>
• <font color='%2'><execute expression='[player, true] call lmf_admin_fnc_endMission'>End Mission (Victory)</execute></font><br/><br/>
• <font color='%3'><execute expression='[player, false] call lmf_admin_fnc_endMission'>End Mission (Defeat)</execute></font>
</font>
", LMF_MAIN_COLOR, LMF_HIGHLIGHT_FRIENDLY_COLOR, LMF_ERROR_COLOR], "A3\missions_f_exp\data\img\classes\support_ca.paa"], taskNull, "", false];

// Admin chat commands
player createDiaryRecord ["lmf_adminTools", ["Chat Commands", format ["
<font face='PuristaBold' color='%1' size='16'>Chat Commands</font><br/>
<font >These commands require LMF or server admin access.</font><br/><br/>

<font face='PuristaBold' color='%1'>#start</font></font><font color='%2'> - Starts mission</font><br/>
<font face='PuristaBold' color='%1'>#victory</font></font><font color='%2'> - Ends mission in victory</font><br/>
<font face='PuristaBold' color='%1'>#defeat</font><font color='%2'> - Ends mission in defeat</font><br/>
<font face='PuristaBold' color='%1'>#respawn</font><font color='%2'> - Respawn the admin</font><br/>
<font face='PuristaBold' color='%1'>#respawnwave</font><font color='%2'> - Respawn all dead players</font><br/>
<font face='PuristaBold' color='%1'>#performance</font></font><font color='%2'> - Check performance</font><br/>
<font face='PuristaBold' color='%1'>#heal *target name*</font><font color='%2'> - Heal target player</font><br/>
<font face='PuristaBold' color='%1'>#goto *target name*</font><font color='%2'> - Teleports admin to target player</font><br/>
<font face='PuristaBold' color='%1'>#bring *target name*</font><font color='%2'> - Teleports target player to admin</font>

", LMF_MAIN_COLOR, LMF_TEXT_COLOR_DARK], "A3\3den\data\cfg3den\comment\texture_ca.paa"], taskNull, "", false];

