/*
	Mission briefing
	Builds the player briefing from cfg_Briefing.sqf.
	Author: nkenny. Contributors: Drgn V4karian, Alex2k.
*/

#include "..\..\settings\cfg_Briefing.sqf"

// Prepare enemy briefing text.
private _enemyText = format ["<font face='PuristaBold' color='%2'>%1</font><br/>", _brfEnemyFaction, LMF_ERROR_COLOR];
private _enemyLines = [];
{
	_x params [["_title", ""], ["_content", ""]];
	if (_title != "" && _content != "") then {
		_enemyLines pushBack format ["<font color='%3' face='PuristaBold'>•</font> %1: %2", _title, _content, LMF_ERROR_COLOR];
	};
} forEach _brfEnemy;
_enemyText = _enemyText + (_enemyLines joinString "<br/>");

// Prepare friendly briefing text.
private _friendText = format ["<font face='PuristaBold' color='%2'>%1</font><br/>", _brfFriendFaction, LMF_HIGHLIGHT_FRIENDLY_COLOR];
private _friendLines = _brfFriend apply {format ["<font color='%2' face='PuristaBold'>•</font> %1", _x, LMF_HIGHLIGHT_FRIENDLY_COLOR]};
_friendText = _friendText + (_friendLines joinString "<br/>");

// Prepare execution briefing text.
private _execText = "";
if (_brfExecIntent != "") then {_execText = _execText + format ["<font face='PuristaBold'>Commander's Intent</font><br/>%1<br/><br/>", _brfExecIntent];};

if (count _brfExecConop > 0) then {
	_execText = _execText + "<font face='PuristaBold'>Concept of Operations</font><br/>";
	private _conopLines = _brfExecConop apply {format ["<font face='PuristaBold'>•</font> %1", _x]};
	_execText = _execText + (_conopLines joinString "<br/>");
};

if (count _brfExecCoord > 0) then {
	if (_execText != "") then {_execText = _execText + "<br/><br/>";};
	_execText = _execText + "<font face='PuristaBold'>Coordinating Instructions</font><br/>";
	private _coordLines = _brfExecCoord apply {format ["<font face='PuristaBold'>•</font> %1", _x]};
	_execText = _execText + (_coordLines joinString "<br/>");
};

// Prepare logistics briefing text.
private _adminText = "";
if (count _brfAdministration > 0) then {
	private _adminLines = _brfAdministration apply {format ["<font face='PuristaBold'>•</font> %1", _x]};
	_adminText = _adminLines joinString "<br/>";
};

// Delete existing subjects
[{!isNil "cba_help_DiaryRecordAddons"}, {
	player removeDiarySubject "cba_help_docs";
	player removeDiarySubject "Units";
	player removeDiarySubject "Diary";
	player removeDiarySubject "Statistics";
}, []] call CBA_fnc_waitUntilAndExecute;

// Create the LMF briefing.
player createDiarySubject ["lmf_diary", "Mission", "A3\3den\data\cfgwaypoints\sentry_ca.paa"];
#include "..\admin\createAdminDiary.sqf"

// Thanks
private _thanksText = format ["<font face='PuristaBold' size='16' color='%1'>Thanks To</font><br/><font color='%2'>A big thank you to everyone who has lent a hand, shared an idea or helped figure things out along the way. From building LMF to making and testing missions, every bit of help is appreciated.</font>", LMF_MAIN_COLOR, LMF_TEXT_COLOR];
{
	_x params ["_name", ["_reason", ""]];
	_thanksText = _thanksText + format ["<br/><br/><font face='PuristaBold' color='%2'>%1</font>", _name, LMF_LINK_COLOR];
	if (_reason != "") then {
		_thanksText = _thanksText + format ["<font color='%2'> - %1</font>", _reason, LMF_TEXT_COLOR];
	};
} forEach _thanks;
player createDiaryRecord ["lmf_diary", ["Thanks", _thanksText, "\A3\ui_f\data\igui\cfg\simpletasks\types\help_ca.paa"], taskNull, "", false];

// Group roster
lmf_briefing_fnc_refreshRoster = {
	player setDiaryRecordText [["lmf_diary", lmf_toeBriefing], ["TO&E", [] call lmf_briefing_fnc_buildRosterText, "\A3\3den\data\displays\display3den\panelright\modegroups_ca.paa"]];
};
[{time > 5}, {
	lmf_toeBriefing = player createDiaryRecord ["lmf_diary", ["Briefing", [] call lmf_briefing_fnc_buildRosterText, "\A3\3den\data\displays\display3den\panelright\modegroups_ca.paa"], taskNull, "", false];

	// Map EH
	addMissionEventHandler ["Map", {
		params ["_mapIsOpened", "_mapIsForced"];
		if (_mapIsOpened) then {player setDiaryRecordText [["lmf_diary", lmf_toeBriefing], ["TO&E", [] call lmf_briefing_fnc_buildRosterText, "\A3\3den\data\displays\display3den\panelright\modegroups_ca.paa"]];};
	}];
}, []] call CBA_fnc_waitUntilAndExecute;

// Technical
private _respawnLabel = "Disabled";
private _respawnDescription = "Automatic respawn is disabled.";
private _respawnColor = LMF_TEXT_COLOR_DARK;
switch (lmf_respawnType) do {
	case "WAVE": {
		_respawnLabel = format ["Wave (%1)", [lmf_respawnTime, "MM:SS"] call BIS_fnc_secondsToString];
		_respawnDescription = "Mission-time waves (MM:SS), with a minimum delay of 10 seconds after death.";
		_respawnColor = LMF_TEXT_COLOR;
	};
	case "TICKETS": {
		_respawnLabel = format ["Tickets (%1x / %2)", lmf_respawnTickets, [lmf_respawnTime, "MM:SS"] call BIS_fnc_secondsToString];
		_respawnDescription = "Per-player session allowance, consumed on death; mission-time waves (MM:SS) with a minimum delay of 10 seconds.";
		_respawnColor = LMF_TEXT_COLOR;
	};
};
private _technicalRows = [
	["Map Access", ["Everyone", "Leaders Only", "Disabled"] select lmf_playerMaps, "Who is issued a map.", [LMF_TEXT_COLOR, LMF_TEXT_COLOR_DARK] select (lmf_playerMaps == 2)],
	["Map Mode", ["Standard", "Oldschool"] select lmf_oldSchoolMap, "Oldschool hides new markers received from others.", LMF_TEXT_COLOR],
	["Blue Force Tracker", ["Disabled", "Enabled"] select lmf_bft, "Shows tracked friendly positions on the map.", [LMF_TEXT_COLOR_DARK, LMF_TEXT_COLOR] select lmf_bft],
	["Personal Radio", ["Disabled", "Everyone"] select lmf_personalRadio, "Short-range radios for everyone.", [LMF_TEXT_COLOR_DARK, LMF_TEXT_COLOR] select lmf_personalRadio],
	["Respawn", _respawnLabel, _respawnDescription, _respawnColor]
];
private _technicalText = format ["<font face='PuristaBold' size='16' color='%1'>Technical Info</font><br/><font color='%2'>Mission settings shown during Safe Start are explained below.</font><br/>", LMF_MAIN_COLOR, LMF_TEXT_COLOR];
{
	_x params ["_label", "_value", "_explanation", "_valueColor"];
	_technicalText = _technicalText + format ["<br/><font face='PuristaBold' color='%4'>%1: </font><font color='%5'> [%2] </font><font color='%6'>- %3</font>", _label, _value, _explanation, LMF_MAIN_COLOR, _valueColor, LMF_TEXT_COLOR_DARK];
} forEach _technicalRows;
player createDiaryRecord ["lmf_diary", ["Technical", _technicalText, "\A3\missions_f_exp\data\img\classes\support_ca.paa"], taskNull, "", false];

// Briefing
player createDiaryRecord ["lmf_diary", [format ["OPORD"], format ["
<font color='%10' size='10'><marker name='mrk_clearMap'>[Clear Coordinates]</marker></font><font color='%11' size='10'>  |  Made by %7 with LMF %8</font>
<br/><font face='PuristaBold' color='%9' size='16'>Situation</font><br/>
<font >%1</font>
<br/><br/><font face='PuristaBold' color='%12' >Enemy ></font> %2
<br/><br/><font face='PuristaBold' color='%13' >Friendly ></font> %3
<br/><br/><font face='PuristaBold' size='16' color='%9'>Mission</font><br/>
<font >%4</font>
<br/><br/><font face='PuristaBold' size='16' color='%9'>Execution</font><br/>
%5
<br/><br/><font face='PuristaBold' size='16' color='%9'>Administration</font><br/>
%6
", _brfSituation, _enemyText, _friendText, _brfMission, _execText, _adminText, lmf_author, LMF_VERSION, LMF_MAIN_COLOR, LMF_LINK_COLOR, LMF_TEXT_COLOR_DARK, LMF_ERROR_COLOR, LMF_HIGHLIGHT_FRIENDLY_COLOR], "\A3\ui_f\data\igui\cfg\simpletasks\types\documents_ca.paa"], taskNull, "", false];
