/*
    Chat commands
    Adds CBA chat commands for players, fixed LMF admins and server admins.
    Author: cuel. Contributor: G4rrus.
*/

// Registration is local: fixed LMF admins bypass CBA's login requirement only on their own client.
private _adminAccess = ["admin", "all"] select ((getPlayerUID player) in lmf_admin_uids);

// Admin commands
["heal", {
	params [["_name", ""]];
	private _unit = _name call lmf_chat_fnc_findPlayerByName;
	if (isNull _unit) exitWith {systemChat "Could not find unit"};

	[_unit] call ace_medical_fnc_fullHeal;
	systemChat format ["Fully healed %1.", name _unit];
}, _adminAccess] call CBA_fnc_registerChatCommand;

["goto", {
	params [["_name", ""]];
	private _unit = _name call lmf_chat_fnc_findPlayerByName;
	if (isNull _unit) exitWith {systemChat "Could not find unit"};

	moveOut ACE_player;
	ACE_player setPos (_unit modelToWorld [0, -2, 0]);
	systemChat format ["Teleported to %1.", name _unit];
}, _adminAccess] call CBA_fnc_registerChatCommand;

["bring", {
	params [["_name", ""]];
	private _unit = _name call lmf_chat_fnc_findPlayerByName;
	if (isNull _unit) exitWith {systemChat "Could not find unit"};
	private _vehicle = objectParent ACE_player;
	if (!isNull _vehicle) exitWith {
		[_unit, ACE_player, _vehicle] remoteExecCall ["lmf_chat_fnc_bringIntoVehicle", _unit];
	};

	moveOut _unit;
	_unit setVelocity [0,0,0];
	_unit setPos (ACE_player modelToWorld [0, 1, 0]);
	systemChat format ["Teleported %1 to you.", name _unit];
}, _adminAccess] call CBA_fnc_registerChatCommand;

["start", {
	[ACE_player] call lmf_admin_fnc_endWarmup;
}, _adminAccess] call CBA_fnc_registerChatCommand;

["victory", {
	[ACE_player, true] call lmf_admin_fnc_endMission;
}, _adminAccess] call CBA_fnc_registerChatCommand;

["defeat", {
	[ACE_player, false] call lmf_admin_fnc_endMission;
}, _adminAccess] call CBA_fnc_registerChatCommand;

["respawn", {
	setPlayerRespawnTime 5;
}, _adminAccess] call CBA_fnc_registerChatCommand;

["respawnwave", {
	[ACE_player] call lmf_admin_fnc_triggerRespawnWave;
}, _adminAccess] call CBA_fnc_registerChatCommand;

["performance", {
	[ACE_player] remoteExec ["lmf_admin_fnc_requestPerformanceReport",2];
}, _adminAccess] call CBA_fnc_registerChatCommand;

// Client commands
["w", {
    params [["_str", ""]];
    private _split = (_str splitString " ");
    private _to = _split param [0, ""];
    _split deleteAt 0;
    private _msg = _split joinString " ";
    if (_to isEqualTo "" || _msg isEqualTo "") exitWith {systemChat "Invalid arguments"};

    private _receiver = [_to] call lmf_chat_fnc_findPlayerByName;
    if (isNull _receiver) exitWith {systemChat "Could not find receiver"};
    [_msg, "whisper", name _receiver] call lmf_chat_fnc_sendChatMessage;
}, "all",false] call CBA_fnc_registerChatCommand;

["zeus", {
    params [["_msg", ""]];
    _msg = [_msg] call CBA_fnc_trim;
    if (_msg isEqualTo "") exitWith {};
    [_msg, "zeus"] call lmf_chat_fnc_sendChatMessage;
}, "all",false] call CBA_fnc_registerChatCommand;
