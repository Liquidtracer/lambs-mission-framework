/*
	Apply rank insignia
	Applies insignia to unit based on units rank.
	Author: Alex2k.

	Arguments:
		0: Unit <OBJECT>

	Example:
		[player] call lmf_equipment_fnc_applyRankInsignia;
*/

params [["_unit", objNull]];

if !(hasInterface) exitWith {};
if !(local _unit) exitWith {};

private _rank = rank _unit;

private _insigniaMap = [
	["PRIVATE", "lambs_or2"],
	["CORPORAL", "lambs_or4"],
	["SERGEANT", "lambs_or5"],
	["LIEUTENANT", "lambs_of1"],
	["CAPTAIN", "lambs_of2"],
	["MAJOR", "lambs_of3"],
	["COLONEL", "lambs_of5"]
];

_unit setVariable ["BIS_fnc_setUnitInsignia_class", nil]; // Clears the cached insignia class before reapplying it.

private _filteredInsignias = _insigniaMap select {_x#0 == _rank};

private _insignia = (_filteredInsignias#0)#1;

[_unit, _insignia] call bis_fnc_setUnitInsignia;
