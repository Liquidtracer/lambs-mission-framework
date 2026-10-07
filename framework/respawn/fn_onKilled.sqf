/*
	Player death handling
	Handles player death, respawn timing and spectator startup.

	Arguments:
		0: Affected unit <OBJECT>

	Example:
		[player] spawn lmf_respawn_fnc_onKilled;
*/

params ["_unit"];
if (isNull _unit || {alive player} || {_unit isNotEqualTo player}) exitWith {};

// Black out
cutText ["", "BLACK OUT", 0.001, true];

// Calculate the respawn time.
if (lmf_respawnType isEqualType "") then {

	if (lmf_respawnType == "WAVE") then {
		setPlayerRespawnTime (lmf_respawnTime - ((floor CBA_missionTime) % lmf_respawnTime));
	};

	if (lmf_respawnType == "OFF") then {
		setPlayerRespawnTime 1000000;
	};

	if (lmf_respawnType == "TICKETS") then {
		if (lmf_respawnTickets == 0) exitWith {
			setPlayerRespawnTime 1000000;
			["Respawn", "No respawn tickets remaining.", "\A3\modules_f\data\portraitrespawn_ca.paa", 2.85, 12, "", 1.1, true] call lmf_notifications_fnc_showAceMessage;
		};

		setPlayerRespawnTime (lmf_respawnTime - ((floor CBA_missionTime) % lmf_respawnTime));
		lmf_respawnTickets = lmf_respawnTickets - 1;
	};

	if (lmf_respawnType != "WAVE" && lmf_respawnType != "OFF" && lmf_respawnType != "TICKETS") then {
		setPlayerRespawnTime 1000000;
	};
};

if (lmf_respawnType isEqualType 0) then {
	setPlayerRespawnTime lmf_respawnType;
};

if (playerRespawnTime < 10) then {
	setPlayerRespawnTime 10;
};

// Death feed
lmf_msgPool = [
	" is dead as a doornail",
	" became a frag for the other team",
	" sleeps with the fishes",
	" came, saw, died",
	"'s healthbar reached zero",
	" kicked the bucket",
	" is pushing up daisies",
	" has become living-challenged",
	" is definitely done dancing",
	" flatlined",
	" has become worm food",
	" is taking a dirt nap",
	" bit the dust",
	" went belly up",
	" is dead as a dodo",
	" was killed in action",
	" shuffled off this mortal coil",
	" is six feet under",
	"'s earthly career ended",
	" kicked the oxygen habit",
	" has gone the way of all flesh",
	" was annihilated",
	" crossed the river Styx",
	" was fragged",
	" ceased to be",
	" met an untimely end",
	" walked the plank",
	" went to the happy hunting grounds",
	", available now with 100% less life",
	" forgot to drink a health-potion",
	" returns home on their shield",
	" gets to meet the eternal shepherd",
	" has been sheared for the last time",
	" joins the great flock",
	" decided to spectate the rest of the match",
	" achieved maximum non-existence",
	" has been successfully decommissioned",
	" made the ultimate tactical retreat",
	" has been voted off the island",
	" has earned their place in Valhalla"
];

private _oldEntityKilledEh = missionNamespace getVariable ["lmf_entityKilledEh", -1];
if (_oldEntityKilledEh >= 0) then {
	removeMissionEventHandler ["EntityKilled", _oldEntityKilledEh];
};

lmf_entityKilledEh = addMissionEventHandler ["EntityKilled", {
	params ["_unit", "_killer", "_instigator", "_useEffects"];
	if (_unit isEqualTo player || {!isPlayer [_unit]}) exitWith {};

	if (!alive player) then {
		private _txt = parseText format [
			"<t font='PuristaBold' size='0.5' shadow='2' color='%3'>%1<t color='%4'>%2",
			name _unit,
			selectRandom lmf_msgPool,
			LMF_MAIN_COLOR,
			LMF_TEXT_COLOR
		];

		[_txt, 0, 0.75, 10, 0, 1, random 999999] spawn BIS_fnc_dynamicText;
	};
}];

sleep 9;

// A short respawn override can finish before this scheduled function wakes up.
if (alive player || {_unit isNotEqualTo player}) exitWith {};

// ACE spectator interface
[true] call ace_spectator_fnc_setSpectator;
[[0, 1, 2], []] call ace_spectator_fnc_updateCameraModes;
// [[2,3],[0,1]] call ace_spectator_fnc_updateVisionModes;
[0, objNull] call ace_spectator_fnc_setCameraAttributes;

// Spectator settings
0 enableChannel false;
1 enableChannel false;
2 enableChannel false;
3 enableChannel false;
4 enableChannel false;
5 enableChannel false;

// Fade in
cutText ["", "BLACK IN", 4, true];
