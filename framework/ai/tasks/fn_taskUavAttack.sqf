/*
    UAV attack
    Tasks a UAV against a target.
    Author: Alex2k.

    Arguments:
        0: UAV <OBJECT>
        1: Target <OBJECT>

    Example:
        [uav_1, target_1] spawn lmf_ai_fnc_taskUavAttack;
*/

params ["_veh","_target"];
if (!alive _veh) exitWith {};

_grp = (group _veh);

// Target and move to enemy
_grp reveal [_target, 4];

_grp addEventHandler ["EnemyDetected", {
	params ["_group", "_newTarget"];
	if (!alive (vehicle (leader _group))) exitWith {_group removeEventHandler [_thisEvent, _thisEventHandler];};

	if (50 > random 100) then {
		(leader _group) doMove (_newTarget getPos [50, (leader _group) getDir _newTarget]);
	};
}];

while {alive _veh} do {
	_veh flyInHeight [10 + (random 100),true];
	waitUntil {sleep 5; (_veh targets [true, 25]) isNotEqualTo [] || !alive _veh};

	_veh flyInHeight [10 + (random 40),true];

	private _grenade = "GrenadeHand" createVehicle [0,0,random 9999];
	_grenade attachTo [_veh, [0, 0, -0.15]];
	detach _grenade;

	sleep 30;
};
