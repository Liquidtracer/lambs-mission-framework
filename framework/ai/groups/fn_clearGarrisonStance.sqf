/*
	Clear garrison stance reactions
	Removes the local recurring fire handler and releases the unit from garrison stance control.
	Call on the server that installed the garrison handlers, before movement or surrender.

	Arguments:
		0: Unit <OBJECT>
*/

params ["_unit"];

private _firedEh = _unit getVariable ["lmf_ai_garrisonFiredEh", -1];
if (_firedEh >= 0) then {
	_unit removeEventHandler ["FiredNear", _firedEh];
};
_unit setVariable ["lmf_ai_garrisonFiredEh", nil];
_unit setVariable ["lmf_ai_garrisonGroup", nil];
_unit setVariable ["lmf_ai_garrisonNextStanceTime", nil];
