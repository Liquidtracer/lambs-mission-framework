/*
	Death feedback
	Registers local death feedback; included in the client section of XEH_postInit.sqf.
*/

["ace_killed", {
	params ["_unit", "_causeOfDeath", "_killer", "_instigator"];
	if (_unit isNotEqualTo player) exitWith {};

	private _killerName = name _killer;
	private _weaponName = [configFile >> "CfgWeapons" >> currentWeapon _killer] call BIS_fnc_displayName;

	[{titleText [format ["<t color='%4'>Killer: </t><t color='%5'>%1(%2)</t><br/><t color='%4'>Cause: </t><t color='%5'>%3</t>", _this select 0, _this select 1, _this select 2, LMF_MAIN_COLOR, LMF_TEXT_COLOR], "PLAIN", 1, true, true];}, [_killerName, _weaponName, _causeOfDeath], 4] call CBA_fnc_waitAndExecute;
}] call CBA_fnc_addEventHandler;

