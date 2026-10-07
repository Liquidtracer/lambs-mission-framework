/*
	Vehicle service
	Rearms, repairs and refuels the vehicle.
	Author: nkenny. Source: Xeno. Contributors: Diwako, Drgn V4karian.

	Arguments:
		0: Vehicle <OBJECT>
		1: Service step delay in seconds <NUMBER> (default: 4)

	Example:
		[heli_1, 4] spawn lmf_vehicleService_fnc_serviceVehicle;

	Trigger setup:
		1. Create a trigger large enough to fit the vehicle.
		2. Set activation to Anybody, Present and Repeatable.
		3. Condition: ("Air" countType thislist > 0) && {((getpos (thislist select 0)) select 2 < 1)}
		4. On activation: [(thislist select 0)] spawn lmf_vehicleService_fnc_serviceVehicle;
		Replace "Air" with another vehicle type to service ground vehicles, for example.
*/

if (time <= 30) then {
	waitUntil {sleep 0.25; time > 30};
};
params [["_object", objNull, [objNull]], ["_sleep", 4, [1]]];
if (!local _object || {!alive _object}) exitWith {};

private _type = typeOf _object;
private _typeName = getText (configFile >> "CfgVehicles" >> typeOf _object >> "displayName");
if (_object isKindOf "ParachuteBase") exitWith {};

// Stop the engine and temporarily remove fuel during servicing.
_object setFuel 0;
_object engineOn false;

// Reload weapons
_object setVehicleAmmo 1;
_object vehicleChat format ["Servicing %1... Please stand by...", _typeName];
private _magazines = getArray (configFile >> "CfgVehicles" >> _type >> "magazines");

if (count _magazines > 0) then {
	private _removed = [];
	{
		private _index = _removed pushBackUnique _x;
		if (_index > -1) then {
			_object removeMagazines _x;
		};
	} forEach _magazines;
	{
		if !(alive _object) exitWith {};
		_object vehicleChat format ["Reloading %1", _x];
		sleep _sleep;
		_object addMagazine _x;
	} forEach _magazines;
};
if !(alive _object) exitWith {};

// Reload turrets
private _count = count (configFile >> "CfgVehicles" >> _type >> "Turrets");
if (_count > 0) then {
	for "_i" from 0 to (_count - 1) do {
		scopeName "xx_reload2_xx";
		private _config = (configFile >> "CfgVehicles" >> _type >> "Turrets") select _i;
		private _magazines = getArray (_config >> "magazines");
		private _removed = [];
		{
			private _index = _removed pushBackUnique _x;
			if (_index > -1) then {
				_object removeMagazines _x;
			};
		} forEach _magazines;
		{
			if !(alive _object) then {breakOut "xx_reload2_xx"};
			_object vehicleChat format ["Reloading %1", _x];
			sleep (_sleep * 2);
			_object addMagazine _x;
		} forEach _magazines;

		// Check if main turret has other turrets
		private _countOther = count (_config >> "Turrets");
		if (_countOther > 0) then {
			for "_i" from 0 to (_countOther - 1) do {
				private _config2 = (_config >> "Turrets") select _i;
				private _magazines = getArray (_config2 >> "magazines");
				private _removed = [];
				{
					private _index = _removed pushBackUnique _x;
					if (_index > -1) then {
						_object removeMagazines _x;
					};
				} forEach _magazines;
				{
					if !(alive _object) then {breakOut "xx_reload2_xx"};
					_object vehicleChat format ["Reloading %1", _x];
					sleep (_sleep * 2);
					_object addMagazine _x;
				} forEach _magazines;
			};
		};
	};
};
_object setVehicleAmmo 1;

// Repair
sleep _sleep;
if !(alive _object) exitWith {};
_object vehicleChat "Repairing...";
_object setDamage 0;

// Restore fuel after servicing.
sleep _sleep;
if !(alive _object) exitWith {};
_object vehicleChat "Refueling...";
sleep _sleep;
if !(alive _object) exitWith {};
_object vehicleChat format ["%1 is ready...", _typeName];
_object setFuel 1;
