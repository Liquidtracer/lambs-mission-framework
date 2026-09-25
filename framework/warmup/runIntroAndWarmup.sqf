/*
    Player intro and warmup
    Runs the player intro and optional warmup.
    Author: nkenny. Contributors: Drgn V4karian, Alex2k.
*/

waitUntil {time > 0};

// Blackout, weapons and simulation
cutText ["", "BLACK FADED", 10, true];
{
	[player, _x, true] call ace_safemode_fnc_setWeaponSafety;
	sleep 1;
} forEach [primaryWeapon player, handgunWeapon player];
player action ["SwitchWeapon", player, player, -1];
sleep 1;
private _introUnit = player;
_introUnit enableSimulation false;

// Mission intro
sleep 2;
if (var_missionSubtitle isNotEqualTo "") then {
	[
		[
			[format ["%1", var_missionTitle],"align='center' shadow='2' size='1' font='PuristaBold'",LMF_MAIN_COLOR],
			["","<br/>"],
			[format ["%1", var_missionSubtitle],"align='center' shadow='2' size='0.5' font='PuristaBold'"]
		],safeZoneX+0.0,safeZoneY+0.8
	] spawn BIS_fnc_typeText2;
} else {
	[
		[
			[format ["%1", var_missionTitle],"align='center' shadow='2' size='1' font='PuristaBold'",LMF_MAIN_COLOR],
			["","<br/>"]
		],safeZoneX+0.0,safeZoneY+0.8
	] spawn BIS_fnc_typeText2;
};

sleep 7;
waitUntil {!isNil "lmf_warmup"};
// The narrative intro is complete. Prepare the menus while the screen is still black.
lmf_player_introComplete = true;

// Keep the intro unit still through Mission Info, independently of warmup safety and its panel.
[_introUnit] spawn {
    params ["_introUnit"];

    private _missionInfo = [] execVM "framework\missionInfo\showStartupInfo.sqf";
    waitUntil {uiSleep 0.1; scriptDone _missionInfo};
    _introUnit enableSimulation true;
};

// Exit if no warmup or warmup has already ended (JIP)
if !(lmf_warmup) exitWith {};

// Warmup
player setUnitTrait ["camouflageCoef",0];
[true] call lmf_admin_fnc_setPlayerSafety;

// Display control
// Uses the ACE display-text position stored in the player profile.
private _xPos = profilenamespace getVariable ["IGUI_GRID_ACE_displayText_X", ((safezoneX + safezoneW) - (10 *(((safezoneW / safezoneH) min 1.2) / 10)) - 2.9 *(((safezoneW / safezoneH) min 1.2) / 40))];
private _yPos = profilenamespace getVariable ["IGUI_GRID_ACE_displayText_Y", safeZoneY + 0.175 * safezoneH];
private _wPos =  (14 *(((safezoneW / safezoneH) min 1.2) / 40));
private _hPos = 4.8 * (2 *((((safezoneW / safezoneH) min 1.2) / 1.2) / 25));

// Ensure still in bounds for large width/height
_xPos = safezoneX max (_xPos min (safezoneX + safezoneW - _wPos));
_yPos = safeZoneY max (_yPos min (safeZoneY + safezoneH - _hPos));

private _ctrl = (findDisplay 46) ctrlCreate ["RscStructuredText", -2];
_ctrl ctrlSetPosition [_xPos,_yPos + 0.2,_wPos,_hPos - 0.1];
_ctrl ctrlSetBackgroundColor [0, 0, 0, 0.65];
_ctrl ctrlSetFade 1;
_ctrl ctrlCommit 0;

private _ctrl2 = (findDisplay 46) ctrlCreate ["RscStructuredText", -2];
_ctrl2 ctrlSetPosition [_xPos,_yPos + 0.2,_wPos,_hPos - 0.1];
_ctrl2 ctrlSetBackgroundColor [0, 0, 0, 0];
private _img = "<img size='8' shadow='0' align='center' image='framework\images\lambs.paa'/>";
_ctrl2 ctrlSetStructuredText parsetext (_img);
_ctrl2 ctrlSetFade 1;
_ctrl2 ctrlCommit 0;

uiSleep 0.25;

_ctrl ctrlSetFade 0;
_ctrl2 ctrlSetFade 0.95;

_ctrl ctrlCommit 3;
_ctrl2 ctrlCommit 3;

// Information fields
private _br = format ["<br/>"];
private _title = format ["<t shadow='2' font='PuristaBold' color='%1' size='1.2' align='left'>SAFE START</t>",LMF_MAIN_COLOR];

// Maps
private _maps = "";
private _mapOptions = [
	format ["<t shadow='2' color='%1' size='0.9'align='left'>Map Access:  </t> <t shadow='2' color='%2' size='0.9'align='right'>Everyone</t><br/>",LMF_MAIN_COLOR, LMF_TEXT_COLOR],
	format ["<t shadow='2' color='%1' size='0.9'align='left'>Map Access:  </t> <t shadow='2' color='%2' size='0.9'align='right'>Leaders Only</t><br/>",LMF_MAIN_COLOR, LMF_TEXT_COLOR],
	format ["<t shadow='2' color='%1' size='0.9'align='left'>Map Access:  </t> <t shadow='2' color='%2' size='0.9'align='right'>Disabled</t><br/>",LMF_MAIN_COLOR, LMF_TEXT_COLOR_DARK]
];
_maps = _mapOptions select var_playerMaps;

// Map mode
private _mapMode = format ["<t shadow='2' color='%1' size='0.9'align='left'>Map Mode:  </t> <t shadow='2' color='%3' size='0.9'align='right'>%2</t><br/>",LMF_MAIN_COLOR,["Standard", "Oldschool"] select var_oldSchoolMap, LMF_TEXT_COLOR];

// Blue force tracker
private _bft = "";
private _bftOptions = [
	format ["<t shadow='2' color='%1' size='0.9'align='left'>Blue Force Tracker:  </t> <t shadow='2' color='%2' size='0.9'align='right'>Disabled</t><br/>",LMF_MAIN_COLOR, LMF_TEXT_COLOR_DARK],
	format ["<t shadow='2' color='%1' size='0.9'align='left'>Blue Force Tracker:  </t> <t shadow='2' color='%2' size='0.9'align='right'>Enabled</t><br/>",LMF_MAIN_COLOR, LMF_TEXT_COLOR]
];
_bft = _bftOptions select var_bft;

// Personal radio
private _radios = "";
private _radiosOptions = [
	format ["<t shadow='2' color='%1' size='0.9'align='left'>Personal Radio:  </t> <t shadow='2' color='%2' size='0.9'align='right'>Disabled</t><br/>",LMF_MAIN_COLOR, LMF_TEXT_COLOR_DARK],
	format ["<t shadow='2' color='%1' size='0.9'align='left'>Personal Radio:  </t> <t shadow='2' color='%2' size='0.9'align='right'>Everyone</t><br/>",LMF_MAIN_COLOR, LMF_TEXT_COLOR]
];
_radios = _radiosOptions select var_personalRadio;

// Respawn type
private _respawn = "";
if (typename var_respawnType == "SCALAR") then {
	_respawn = format ["<t shadow='2' color='%1' size='0.9'align='left'>Respawn:  </t> <t shadow='2' color='%3' size='0.9'align='right'>Delay (%2s)</t><br/>",LMF_MAIN_COLOR,var_respawnType, LMF_TEXT_COLOR];
} else {
	if (var_respawnType == "OFF") then {
		_respawn = format ["<t shadow='2' color='%1' size='0.9'align='left'>Respawn:  </t> <t shadow='2' color='%2' size='0.9'align='right'>Disabled</t><br/>",LMF_MAIN_COLOR, LMF_TEXT_COLOR_DARK];
	};
	if (var_respawnType == "WAVE") then {
		private _respTime = format ["<t shadow='2' color='%2'>%1",[var_respawnTime, "MM"] call BIS_fnc_secondsToString, LMF_MAIN_COLOR];
		_respawn = format ["<t shadow='2' color='%1' size='0.9'align='left'>Respawn:  </t> <t shadow='2' color='%3' size='0.9'align='right'>Wave (%2m)</t><br/>",LMF_MAIN_COLOR,_respTime, LMF_TEXT_COLOR];
	};
	if (var_respawnType == "TICKETS") then {
		private _respTime = format ["<t shadow='2' color='%2'>%1",[var_respawnTime, "MM"] call BIS_fnc_secondsToString, LMF_MAIN_COLOR];
		_respawn = format ["<t shadow='2' color='%1' size='0.9'align='left'>Respawn:  </t> <t shadow='2' color='%3' size='0.9'align='right'>Tickets (%2x)</t><br/>",LMF_MAIN_COLOR,var_respawnTickets, LMF_TEXT_COLOR];
	};
	if (var_respawnType != "WAVE" && var_respawnType != "OFF" && var_respawnType != "TICKETS") then {
		_respawn = format ["<t shadow='2' color='%1' size='0.9'align='left'>Respawn: </t> <t shadow='2' color='%3' size='0.9'align='right'>%2</t><br/>",LMF_MAIN_COLOR,var_respawnType, LMF_TEXT_COLOR];
	};
};

// Static information
private _staticInfo = ( _br + _br + _maps + _mapMode + _bft + _radios + _respawn);

// Match the server's deadline parsing for the end-time label and warning colors.
private _hasDeadline = false;
private _deadline = 0;
if (var_maxWarmupTime != "") then {
    private _parts = var_maxWarmupTime splitString ":";
    if (count _parts == 2) then {
        _deadline = (parseNumber (_parts select 0)) * 60 + parseNumber (_parts select 1);
        _hasDeadline = true;
    };
};

// Information update loop
while {lmf_warmup} do {

    private _elapsedTime = CBA_missionTime;

    private _timeColor = if (_hasDeadline) then {
        private _remainingTime = _deadline - _elapsedTime;
        switch (true) do {
            case (_remainingTime <= 60):  { "#ee3030" };
            case (_remainingTime <= 180): { "#ff8800" };
            case (_remainingTime <= 300): { "#FFD700" };
            default { LMF_TEXT_COLOR };
        };
    } else {
        switch (true) do {
            case (_elapsedTime >= 1200): { "#ee3030" };
            case (_elapsedTime >= 900):  { "#ff8800" };
            case (_elapsedTime >= 600):  { "#FFD700" };
            default { LMF_TEXT_COLOR };
        };
    };

    private _timeFormatted = [_elapsedTime, "MM:SS"] call BIS_fnc_secondsToString;

    private _txt = format ["<t shadow='2' size='0.9' font='PuristaBold' color='%1' align='right'>%2</t>", _timeColor, _timeFormatted];
    if (_hasDeadline) then {
        _txt = format ["<t shadow='2' size='0.9' font='PuristaBold' color='%4' align='center'>[Ends at %1]</t><t shadow='2' size='0.9' font='PuristaBold' color='%2' align='right'>%3</t>", var_maxWarmupTime, _timeColor, _timeFormatted, LMF_LINK_COLOR];
    };

    _ctrl ctrlSetStructuredText parseText (_title + _txt + _staticInfo);
    uiSleep 1;
};

private _ctrl3 = (findDisplay 46) ctrlCreate ["RscStructuredText", -2];
_ctrl3 ctrlSetBackgroundColor [0, 0, 0, 0];
_ctrl3 ctrlCommit 0;

uiSleep 1;

_ctrl3 ctrlSetPosition [0.292,0.40,_wPos,_hPos];
_ctrl3 ctrlCommit 0;

for "_i" from 0 to 4 do {
	_ctrl3 ctrlSetStructuredText parsetext format ["<t shadow='2' font='PuristaBold' color='%2' size='3' align='center' >%1</t>",5 -_i, LMF_TEXT_COLOR];
	playSound "FD_Timer_F";
	uiSleep 1;
};

_ctrl ctrlSetFade 1;
_ctrl2 ctrlSetFade 1;
_ctrl3 ctrlSetFade 1;
_ctrl ctrlCommit 1;
_ctrl2 ctrlCommit 1;
_ctrl3 ctrlCommit 1;
uiSleep 1;
ctrlDelete _ctrl;
ctrlDelete _ctrl2;
ctrlDelete _ctrl3;

// Restore weapon use and configured camouflage.
[false] call lmf_admin_fnc_setPlayerSafety;
player setUnitTrait ["camouflageCoef",var_camoCoef];

uiSleep 3;

private _text = parseText format ["<t font='PuristaBold' size='1.4' color='%1' align='right'>%2</t><br/><t font='PuristaBold' size='1' color='%4' align='right'>%3</t>",LMF_MAIN_COLOR,var_missionTitle,var_missionSubtitle, LMF_TEXT_COLOR];
[_text, true, nil, 7, 0.7, 0] spawn BIS_fnc_textTiles;
