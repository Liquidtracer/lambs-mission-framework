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

private _config = call lmf_equipment_fnc_getPlayerConfig;
private _role = (_config get "ROLE_BY_CLASS") getOrDefault [toLower (typeOf _unit), ""];

if (_role isEqualTo "PLATOON_LEADER") exitWith {_unit call lmf_equipment_fnc_applyPlatoonLeader};
if (_role isEqualTo "PLATOON_SERGEANT") exitWith {_unit call lmf_equipment_fnc_applyPlatoonSergeant};
if (_role isEqualTo "MEDIC") exitWith {_unit call lmf_equipment_fnc_applyMedic};
if (_role isEqualTo "RTO") exitWith {_unit call lmf_equipment_fnc_applyRadioOperator};
if (_role isEqualTo "JTAC") exitWith {_unit call lmf_equipment_fnc_applyJtac};
if (_role isEqualTo "SQUAD_LEADER") exitWith {_unit call lmf_equipment_fnc_applySquadLeader};
if (_role isEqualTo "TEAM_LEADER") exitWith {_unit call lmf_equipment_fnc_applyTeamLeader};
if (_role isEqualTo "AUTORIFLEMAN") exitWith {_unit call lmf_equipment_fnc_applyAutorifleman};
if (_role isEqualTo "ANTI_TANK_GUNNER") exitWith {_unit call lmf_equipment_fnc_applyAntiTankGunner};
if (_role isEqualTo "ANTI_TANK_ASSISTANT") exitWith {_unit call lmf_equipment_fnc_applyAntiTankAssistant};
if (_role isEqualTo "GRENADIER") exitWith {_unit call lmf_equipment_fnc_applyGrenadier};
if (_role isEqualTo "RIFLEMAN") exitWith {_unit call lmf_equipment_fnc_applyRifleman};
if (_role isEqualTo "MACHINE_GUNNER") exitWith {_unit call lmf_equipment_fnc_applyMachineGunner};
if (_role isEqualTo "MACHINE_GUNNER_ASSISTANT") exitWith {_unit call lmf_equipment_fnc_applyMachineGunnerAssistant};
if (_role isEqualTo "VEHICLE_PLATOON_LEADER") exitWith {_unit call lmf_equipment_fnc_applyVehiclePlatoonLeader};
if (_role isEqualTo "VEHICLE_COMMANDER") exitWith {_unit call lmf_equipment_fnc_applyVehicleCommander};
if (_role isEqualTo "VEHICLE_CREW") exitWith {_unit call lmf_equipment_fnc_applyVehicleCrew};
if (_role isEqualTo "HELICOPTER_PILOT") exitWith {_unit call lmf_equipment_fnc_applyHelicopterPilot};
if (_role isEqualTo "HELICOPTER_CREW") exitWith {_unit call lmf_equipment_fnc_applyHelicopterCrew};
if (_role isEqualTo "PILOT") exitWith {_unit call lmf_equipment_fnc_applyPilot};