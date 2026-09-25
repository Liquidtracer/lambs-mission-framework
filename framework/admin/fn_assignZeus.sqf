/*
    Zeus assignment
    Assigns Zeus to the requesting admin.

    Arguments:
        0: Requesting admin <OBJECT>

    Example:
        [player] remoteExec ["lmf_admin_fnc_assignZeus", 2];
*/

params ["_unit"];

#include "checkAdminAccess.sqf"

// Create and assign Zeus if the unit does not already have one.
if (isNull (getAssignedCuratorLogic _unit)) exitWith {
	private _grp = createGroup [sideLogic, true];
	private _curator = _grp createUnit ["ModuleCurator_F",[0,0,0],[],0,"NONE"];
	_curator setVariable ["Addons",3,true];

	// _curator addCuratorEditableObjects [(allMissionObjects "Man"), false];
	// _curator addCuratorEditableObjects [(allMissionObjects "Air"), true];
	// _curator addCuratorEditableObjects [(allMissionObjects "Car"), true];
	// _curator addCuratorEditableObjects [(allMissionObjects "Ammo"), false];
	_curator setVariable ["birdType",""];
	_curator setvariable ["owner","objnull"];
	_curator setVariable ["showNotification",false];
	_curator setvariable ["vehicleinit","_this setvariable ['Addons',3,true]; _this setvariable ['owner','objnull'];"];
	[_curator, [-1, -2, 2]] call bis_fnc_setCuratorVisionModes;

	_unit assignCurator _curator;
};