/*
	Curator event registration
	Registers curator ping feedback; included by XEH_postInit.sqf.
*/

["ModuleCurator_F", "initPost", {
	params ["_module"];
	_module addEventHandler ["CuratorPinged", {
		params ["_curator", "_unit"];
		private _zeus = getAssignedCuratorUnit _curator;
		if (isNull _zeus) then {
			unassignCurator _curator;
			deleteVehicle _curator;
		} else {
			if (_zeus == player) then {
				systemChat format ["%1 just pinged", name _unit];
				format ["Ping received by %1!", name player] remoteExec ["systemChat", _unit];
			};
		};
	}];
}, false, [], true] call CBA_fnc_addClassEventHandler;

