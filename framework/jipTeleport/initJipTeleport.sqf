/*
	JIP teleport
	One successful teleport within five minutes of JIP offer initialization.
	Leaving the 200 m start area, death or changing unit permanently ends the offer.
	All player movement and ACE actions run on the owning player's client.
*/

if (!hasInterface) exitWith {};
private _unit = player;
if (isNull _unit || {!local _unit}) exitWith {};
if (_unit getVariable ["lmf_jipInitialized", false]) exitWith {};
_unit setVariable ["lmf_jipInitialized", true];
_unit setVariable ["lmf_jipStartPos", getPosATL _unit];
_unit setVariable ["lmf_jipAvailable", true];
private _deadline = CBA_missionTime + 300;

private _condition = {
	params ["_target", "_player", "_params"];
	_player isEqualTo (_params select 0)
		&& {missionNamespace getVariable ["lmf_player_introComplete", false]}
		&& {_player isEqualTo player}
		&& {local _player}
		&& {alive _player}
		&& {_player getVariable ["lmf_jipAvailable", false]}
		&& {CBA_missionTime < (_params select 1)}
		&& {_player distance2D (_player getVariable ["lmf_jipStartPos", [0, 0, 0]]) < 200}
};

private _statement = {
	params ["_actionTarget", "_unit", "_params"];
	if (_unit isNotEqualTo (_params select 0) || {_unit isNotEqualTo player} || {!local _unit} || {!alive _unit}) exitWith {};
	if !(_unit getVariable ["lmf_jipAvailable", false]) exitWith {};
	if (CBA_missionTime >= (_params select 1)) exitWith {};
	if (_unit distance2D (_unit getVariable ["lmf_jipStartPos", [0, 0, 0]]) >= 200) exitWith {};

	private _target = [_unit] call lmf_jipTeleport_fnc_selectTeleportTarget;
	if (isNull _target || {!alive _target}) exitWith {
		["JIP TELEPORT", format ["<t color='%1'>No suitable friendly player away from spawn.</t><br/>Try again shortly.", LMF_ERROR_COLOR],
			"\a3\Ui_f\data\GUI\Cfg\CommunicationMenu\transport_ca.paa", 3.8, 12, "addItemFailed", 1.1] call lmf_notifications_fnc_showAceMessage;
	};

	private _vehicle = vehicle _target;
	private _useSeat = [_target] call lmf_jipTeleport_fnc_hasEmptySeat;
	private _destination = [];
	if (!_useSeat) then {
		if (
			alive _vehicle
			&& {abs speed _vehicle <= 19}
			&& {(getPosATL _vehicle select 2) <= 5}
			&& {!surfaceIsWater (getPosATL _vehicle)}
		) then {
			_destination = (getPosATL _vehicle) findEmptyPosition [3, 20, typeOf _unit];
			if !(_destination isEqualTo []) then {
				if (surfaceIsWater _destination) then {_destination = []};
			};
		};
	};
	if (!_useSeat && {_destination isEqualTo []}) exitWith {
		["JIP TELEPORT", format ["<t color='%1'>No free seat or suitable ground position.</t><br/>Try again shortly.", LMF_ERROR_COLOR],
			"\a3\Ui_f\data\GUI\Cfg\CommunicationMenu\transport_ca.paa", 3.8, 12, "addItemFailed", 1.1] call lmf_notifications_fnc_showAceMessage;
	};

	// Do not suspend between validation and movement.
	// Restore the unit's previous damage setting instead of overriding warmup.
	private _damageAllowed = isDamageAllowed _unit;
	private _origin = getPosATL _unit;
	private _originVehicle = objectParent _unit;
	_unit allowDamage false;
	if (!isNull _originVehicle) then {moveOut _unit};

	private _moved = false;
	if (_useSeat) then {
		_moved = _unit moveInAny _vehicle;
		_moved = _moved && {vehicle _unit isEqualTo _vehicle};
	} else {
		_unit setPosATL _destination;
		_moved = isNull objectParent _unit && {_unit distance2D _destination < 5};
	};

	if (!_moved) then {
		// A seat may have become occupied. Keep the action and restore the origin.
		private _restored = false;
		if (!isNull _originVehicle && {alive _originVehicle}) then {
			_restored = _unit moveInAny _originVehicle;
		};
		if (!_restored) then {_unit setPosATL _origin};
		["JIP TELEPORT", format ["<t color='%1'>Unable to move you.</t><br/>The action is still available; try again.", LMF_ERROR_COLOR],
			"\a3\Ui_f\data\GUI\Cfg\CommunicationMenu\transport_ca.paa", 3.8, 12, "addItemFailed", 1.1] call lmf_notifications_fnc_showAceMessage;
	} else {
		_unit setVariable ["lmf_jipAvailable", false];
	};
	_unit allowDamage _damageAllowed;
};

private _action = [
	"lmf_jipTeleport_teleport", "JIP Teleport",
	["\a3\Ui_f\data\GUI\Cfg\CommunicationMenu\transport_ca.paa", LMF_MAIN_COLOR],
	_statement, _condition, {}, [_unit, _deadline]
] call ace_interact_menu_fnc_createAction;
// Preserve the original unit and deadline while registration waits for its menu slot.
lmf_jipTeleport_menuAction = _action;
lmf_jipTeleport_fnc_registerMenu = {
	["CAManBase", 1, ["ACE_SelfActions"], lmf_jipTeleport_menuAction, true] call ace_interact_menu_fnc_addActionToClass;
};

// End this short-lived offer even while the ACE menu is closed (e.g. Zeus moved the unit).
// Expired offers stay hidden; never grant an offer to a later respawn unit.
[{
	params ["_unit", "_deadline"];
	CBA_missionTime >= _deadline
		|| {!alive _unit}
		|| {_unit isNotEqualTo player}
		|| {!local _unit}
		|| {!(_unit getVariable ["lmf_jipAvailable", false])}
		|| {_unit distance2D (_unit getVariable ["lmf_jipStartPos", [0, 0, 0]]) >= 200}
}, {
	params ["_unit"];
	if !(_unit getVariable ["lmf_jipAvailable", false]) exitWith {};
	_unit setVariable ["lmf_jipAvailable", false];
}, [_unit, _deadline]] call CBA_fnc_waitUntilAndExecute;

// Delay the reminder until the player moves; the action condition gates access on the intro.
waitUntil {sleep 1; speed _unit > 1 || {!alive _unit} || {_unit isNotEqualTo player} || {!(_unit getVariable ["lmf_jipAvailable", false])}};
if (_unit isNotEqualTo player || {!alive _unit} || {!(_unit getVariable ["lmf_jipAvailable", false])}) exitWith {};
systemChat "JIP Teleport is available in ACE Self-Interaction for five minutes, until you leave spawn or die.";
