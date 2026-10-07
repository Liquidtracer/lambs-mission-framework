/*
	Select teleport target
	Returns the highest-ranking eligible friendly player, or objNull.
	Called on the JIP player's client. Players still near the JIP start position are not destinations; their presence must not block other players farther away.

	Arguments:
		0: JIP player <OBJECT> (default: player)

	Example:
		[player] call lmf_jipTeleport_fnc_selectTeleportTarget;
*/

params [["_unit", player, [objNull]]];
if (isNull _unit || {!alive _unit}) exitWith {objNull};

private _startPos = _unit getVariable ["lmf_jipStartPos", getPosATL _unit];
private _side = side group _unit;
private _target = objNull;
private _highestRank = -1;

{
	if (
		_x isNotEqualTo _unit
		&& {alive _x}
		&& {isPlayer _x}
		&& {!(_x isKindOf "VirtualMan_F")}
		&& {!(_x isKindOf "HeadlessClient_F")}
		&& {(_side getFriend (side group _x)) >= 0.6}
		&& {_x distance2D _startPos >= 200}
	) then {
		private _vehicle = vehicle _x;
		// An occupied aircraft/boat is fine when there is a seat. Without a seat,
		// only allow a ground destination beside a slow/stationary target on land.
		private _reachable = [_x] call lmf_jipTeleport_fnc_hasEmptySeat;
		if (!_reachable) then {
			_reachable = alive _vehicle
				&& {abs speed _vehicle <= 19}
				&& {(getPosATL _vehicle select 2) <= 5}
				&& {!surfaceIsWater (getPosATL _vehicle)};
			if (_reachable) then {
				private _position = (getPosATL _vehicle) findEmptyPosition [3, 20, typeOf _unit];
				_reachable = !(_position isEqualTo []) && {!surfaceIsWater _position};
			};
		};

		if (_reachable && {rankID _x > _highestRank}) then {
			_highestRank = rankID _x;
			_target = _x;
		};
	};
} forEach allPlayers;

_target
