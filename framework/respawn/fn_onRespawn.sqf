/*
	Player respawn
	Restores player equipment and presentation after respawn.

	Example:
		[] spawn lmf_respawn_fnc_onRespawn;
*/

// Black fade
cutText  ["", "BLACK FADED", 10, true];

private _entityKilledEh = missionNamespace getVariable ["lmf_entityKilledEh", -1];
if (_entityKilledEh >= 0) then {
	removeMissionEventHandler ["EntityKilled", _entityKilledEh];
	lmf_entityKilledEh = -1;
};

// Move out of ACE spectator
[false] call ace_spectator_fnc_setSpectator;

// Player gear
if (lmf_playerGear) then {
	if !(lmf_keepRole) then {
		[player] call lmf_equipment_fnc_applyRifleman;
	} else {
		[player] call lmf_equipment_fnc_applyRoleFromClass;
	};
} else {
	player setUnitLoadout [lmf_player_startLoadout, false];
};

// Channel setup
0 enableChannel false;
1 enableChannel true;
2 enableChannel false;
3 enableChannel true;
4 enableChannel false;
5 enableChannel false;

// Weapon safety
{
	if (_x isNotEqualTo "") then {
		[player, _x, true] call ace_safemode_fnc_setWeaponSafety;
	};
} forEach [primaryWeapon player, handgunWeapon player];
player action ["SwitchWeapon", player, player, -1];

// Fade in, set the channel back to group and restore camouflage
sleep 5;
setCurrentChannel 3;
player setUnitTrait ["camouflageCoef", lmf_camoCoef];
cutText  ["", "BLACK IN", 5, true];

if (lmf_respawnType isEqualType "" && {lmf_respawnType == "TICKETS"}) then {
	private _ticketColor = if (lmf_respawnTickets > 0) then {LMF_STATUS_GOOD_COLOR} else {LMF_STATUS_CRITICAL_COLOR};
	["Respawn", format ["Respawn tickets remaining:<br/><t color='%2'>%1</t>", lmf_respawnTickets, _ticketColor],
		"\A3\modules_f\data\portraitrespawn_ca.paa", 3, 12, "", 1.1] call lmf_notifications_fnc_showAceMessage;
};

