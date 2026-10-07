/*
	Build roster text
	Builds formatted text describing player group composition.
	Author: nkenny. Contributors: G4rrus, Alex2k.

	Example:
		[] call lmf_briefing_fnc_buildRosterText;
*/

private _grp2 = grpNull;
private _brfPlatoon = "";
private _allUniqueGroups = [];

{

	_allUniqueGroups pushBackUnique [(groupId (group _x)), (group _x)];
} forEach ((playableUnits + switchableUnits - entities "HeadlessClient_F") select {side _x == side player});
_allUniqueGroups sort true;

{

	private _grp = _x select 1;
	private _id = groupId _grp;

	if (_grp != _grp2) then {
		if (_grp == (group player)) then {
			_brfPlatoon = _brfPlatoon + "<br/><font face='PuristaBold' color='" + LMF_HIGHLIGHT_FRIENDLY_COLOR + "' size='14'>" + _id + "<br/></font>";
		} else {
			_brfPlatoon = _brfPlatoon + "<br/><font face='PuristaBold' color='" + LMF_MAIN_COLOR + "' size='14'>" + _id + "<br/></font>";
		};
	};

	// Soldier roster entry
	{
		private _role = _x getVariable ["lmf_currentRole", ""];
		if (_role isEqualTo "") then {_role = roleDescription _x};
		if (_role isEqualTo "") then {_role = getText (configOf _x >> "displayName")};
		if (_x == player) then {
			_brfPlatoon = _brfPlatoon + "<font color='" + LMF_HIGHLIGHT_FRIENDLY_COLOR + "'>" + name _x + "<font color='" + LMF_TEXT_COLOR_DARK + "'> - " + _role + "</font color></font><br/>";
		} else {
			_brfPlatoon = _brfPlatoon + "<font>" + name _x + "<font color='" + LMF_TEXT_COLOR_DARK + "'> - " + _role + "</font><br/>";
		};
	} forEach (units _grp);

	_grp2 = _grp;
} forEach _allUniqueGroups;

_brfPlatoon = _brfPlatoon select [0, count _brfPlatoon - 5];

private _text = format ["
<font color='%3' size='11'><execute expression='[player] call lmf_briefing_fnc_refreshRoster'>[REFRESH PAGE]</execute></font><br/>
<font face='PuristaBold' color='%2' size='16'>TABLE OF ORGANIZATION AND EQUIPMENT</font><br/>
Overview of player call signs and roles.<br/>
%1
", _brfPlatoon, LMF_MAIN_COLOR, LMF_LINK_COLOR];

_text
