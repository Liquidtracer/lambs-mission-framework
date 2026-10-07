/*
	Apply role from class
	Selects and applies a player loadout by unit classname.

	Arguments:
		0: Unit <OBJECT>

	Example:
		[player] call lmf_equipment_fnc_applyRoleFromClass;
*/

if !(hasInterface) exitWith {};
params [["_unit", objNull]];
if !(local _unit) exitWith {};

#include "..\..\settings\cfg_Player.sqf"

private _role = toLower (typeOf _unit);

if (_role isEqualTo (toLower(_platoonLeader select 0))) exitWith {_unit call lmf_equipment_fnc_applyPlatoonLeader};
if (_role isEqualTo (toLower(_platoonSgt select 0))) exitWith {_unit call lmf_equipment_fnc_applyPlatoonSergeant};
if (_role isEqualTo (toLower(_medic select 0))) exitWith {_unit call lmf_equipment_fnc_applyMedic};
if (_role isEqualTo (toLower(_rto select 0))) exitWith {_unit call lmf_equipment_fnc_applyRadioOperator};
if (_role isEqualTo (toLower(_jtac select 0))) exitWith {_unit call lmf_equipment_fnc_applyJtac};
if (_role isEqualTo (toLower(_squadLeader select 0))) exitWith {_unit call lmf_equipment_fnc_applySquadLeader};
if (_role isEqualTo (toLower(_teamLeader select 0))) exitWith {_unit call lmf_equipment_fnc_applyTeamLeader};
if (_role isEqualTo (toLower(_autorifleman select 0))) exitWith {_unit call lmf_equipment_fnc_applyAutorifleman};
if (_role isEqualTo (toLower(_antiTankGunner select 0))) exitWith {_unit call lmf_equipment_fnc_applyAntiTankGunner};
if (_role isEqualTo (toLower(_antiTankAssistant select 0))) exitWith {_unit call lmf_equipment_fnc_applyAntiTankAssistant};
if (_role isEqualTo (toLower(_grenadier select 0))) exitWith {_unit call lmf_equipment_fnc_applyGrenadier};
if (_role isEqualTo (toLower(_rifleman select 0))) exitWith {_unit call lmf_equipment_fnc_applyRifleman};
if (_role isEqualTo (toLower(_machineGunner select 0))) exitWith {_unit call lmf_equipment_fnc_applyMachineGunner};
if (_role isEqualTo (toLower(_machineGunnerAssistant select 0))) exitWith {_unit call lmf_equipment_fnc_applyMachineGunnerAssistant};
if (_role isEqualTo (toLower(_crewLeader select 0))) exitWith {_unit call lmf_equipment_fnc_applyVehiclePlatoonLeader};
if (_role isEqualTo (toLower(_crewSgt select 0))) exitWith {_unit call lmf_equipment_fnc_applyVehicleCommander};
if (_role isEqualTo (toLower(_crew select 0))) exitWith {_unit call lmf_equipment_fnc_applyVehicleCrew};
if (_role isEqualTo (toLower(_heloPilot select 0))) exitWith {_unit call lmf_equipment_fnc_applyHelicopterPilot};
if (_role isEqualTo (toLower(_heloCrew select 0))) exitWith {_unit call lmf_equipment_fnc_applyHelicopterCrew};
if (_role isEqualTo (toLower(_pilot select 0))) exitWith {_unit call lmf_equipment_fnc_applyPilot};