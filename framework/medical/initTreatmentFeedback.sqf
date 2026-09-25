/*
    Treatment feedback
    Displays text when another player starts treating the local player.
*/

["lmf_medicalHelpMessage", {
	params ["_medic", "_patient"];
	if (!local _patient || {!alive _patient}) exitWith {};

	// Local cooldown on the patient's client. No state needs to be broadcast.
	private _nextMessage = _patient getVariable ["lmf_helpMsgNext", 0];
	if (CBA_missionTime < _nextMessage) exitWith {};
	_patient setVariable ["lmf_helpMsgNext", CBA_missionTime + 5];

	private _text = if (lifeState _patient == "INCAPACITATED") then {
		(format ["<t shadow='2' color='%1' size='1.25' align='center'>Someone is helping you</t>", LMF_TEXT_COLOR])
	} else {
		format [
			"<t shadow='2' color='%2' size='1.25' align='center'>%1 </t><t shadow='2' color='%3' size='1.25' align='center'>is helping you</t>",
			name _medic,
			LMF_MAIN_COLOR,
			LMF_TEXT_COLOR
		]
	};

	"lmf_medical_feedback_layer_1" cutText [_text, "PLAIN DOWN", 0.6, true, true];
}] call CBA_fnc_addEventHandler;

["ace_treatmentStarted", {
	params ["_medic", "_patient"];
	if (_medic isEqualTo _patient || {!isPlayer _patient} || {!alive _patient}) exitWith {};

	["lmf_medicalHelpMessage", [_medic, _patient], _patient] call CBA_fnc_targetEvent;
}] call CBA_fnc_addEventHandler;
