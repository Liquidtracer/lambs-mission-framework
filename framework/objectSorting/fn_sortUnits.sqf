/*
    Sort units
    Routes local units by side and player status.

    Arguments:
        0: Unit <OBJECT>

    Example:
        [soldier_1] call lmf_objectSorting_fnc_sortUnits;
*/

private _unit = _this select 0;

if !(local _unit) exitWith {};

if  !(isPlayer _unit) then {
	private _side = side group _unit;
	if (_side == civilian) exitWith {};
	if (_side != var_enemySide) exitWith {};
	[_unit] call lmf_ai_fnc_initUnit;
    group _unit deleteGroupWhenEmpty true;
}
else {
    if( _unit == player) then {};
};