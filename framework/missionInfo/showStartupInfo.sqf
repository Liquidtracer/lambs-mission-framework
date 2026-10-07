/*
	Startup mission information
	One local startup message per login, including JIP. No respawn hook or persistent UI.
*/

if (!hasInterface) exitWith {};

waitUntil {uiSleep 0.2; missionNamespace getVariable ["lmf_player_introComplete", false]};
if (lmf_playerGear && {lmf_personalArsenal}) then {
	waitUntil {uiSleep 0.2; scriptDone lmf_player_arsenalInit};
};
waitUntil {uiSleep 0.2; scriptDone lmf_player_menuInit};
// Reveal the world only when the menus are ready and the startup message can open.
cutText ["", "BLACK IN", 5, true];
if (!alive player) exitWith {};

private _entries = [];
private _addEntry = {
	params ["_title", "_body", "_path"];
	_entries pushBack format [
		"<t font='PuristaBold' color='%1'>%2</t><br/><t font='PuristaMedium' size='0.8'>%3</t><br/><t font='PuristaMedium' color='%4' size='0.8'>%5</t>",
		LMF_MAIN_COLOR, _title, _body, LMF_LINK_COLOR, _path
	];
};

if (lmf_warmup_isActive && {lmf_playerGear} && {lmf_personalArsenal}) then {
	["Personal Arsenal", "Customize your personal equipment.",
		" Self-Interact » Equipment » Personal Arsenal"] call _addEntry;

	if (count (missionNamespace getVariable ["lmf_player_availableOptics", []]) > 0) then {
		["Available Optics", "Choose an optic for your primary weapon.",
			" Self-Interact » Equipment » Available Optics"] call _addEntry;
	};
};

if (lmf_bft && {count (lmf_bftInfantry + lmf_bftGroundVehicles + lmf_bftAirVehicles) > 0}) then {
	["Blue Force Tracker", "Group leaders select their group's callsign and icon.",
		" Self-Interact » Blue Force Tracker"] call _addEntry;
};

if (lmf_supplyDropLimit > 0 && {lmf_remainingSuppDrops > 0}) then {
	private _body = if (lmf_supplyDropVehicles && {lmf_vic1 != "" || lmf_vic2 != "" || lmf_vic3 != "" || lmf_vic4 != ""}) then {
		"Request supplies or vehicles. Requires a map and long-range radio."
	} else {
		"Request supplies. Requires a map and long-range radio."
	};
	["Supply Drop", _body,
		" Self-Interact » Supply Drop"] call _addEntry;
};

if (lmf_warmup_isActive && {lmf_forwardDeploy}) then {
	["Forward Deploy", "Group leaders register their group for deployment before warmup ends.",
		" Self-Interact » Register Forward Deploy"] call _addEntry;
};

if (player getVariable ["lmf_jipAvailable", false]) then {
	["JIP Teleport", "Teleport to friendlies once. Available for five minutes, until you leave the 200 m spawn area or die.",
		" Self-Interact » JIP Teleport"] call _addEntry;
};

if (_entries isEqualTo []) exitWith {};

private _text = format [
	"<t align='left' font='PuristaBold' size='1.4'>LMF Systems</t><br/><t align='left' font='PuristaMedium' size='0.8'>These systems are available through ACE self-interact.<br/>Some are limited to warmup or group leaders.</t><br/><br/>%2",
	LMF_MAIN_COLOR, _entries joinString "<br/><br/>"
];

[parseText _text, "LAMBS Mission Framework", "OK", false] call BIS_fnc_guiMessage;
