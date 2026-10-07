/*
	Player proximity state
	Returns the player-proximity state used by the AI spawners.
	A nearby grounded player takes priority over a nearby airborne player.

	Arguments:
		0: Position to check <OBJECT or ARRAY>
		1: Detection range in meters <NUMBER> (default: 500)

	Example:
		[spawn_1, 500] call lmf_ai_fnc_getPlayerProximityState;

	Returns: Proximity state: "groundClose", "airClose" or "airDistance" <STRING>
*/

params ["_pos", ["_range", 500]];

private _targetsToCheck = switchableUnits + playableUnits - entities "HeadlessClient_F";
private _groundClose = false;
private _airClose = false;

{
	if (isPlayer _x) then {
		private _vehicle = vehicle _x;
		if (_vehicle distance _pos < _range) then {
			if (isTouchingGround _vehicle) then {
				_groundClose = true;
			} else {
				_airClose = true;
			};
		};
	};
	if (_groundClose) exitWith {};
} forEach _targetsToCheck;

if (_groundClose) exitWith {"groundClose"};
if (_airClose) exitWith {"airClose"};
"airDistance"
