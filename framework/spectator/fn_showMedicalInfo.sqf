/*
	Spectator medical information
	Shows medical information for the current ACE spectator target.
	Checks spectator target at 20 Hz, polls medical state at 4 Hz and only redraws on state changes.
	Author: Alex2k.

	Arguments:
		0: Active ACE spectator display <DISPLAY>

	Example:
		[uiNamespace getVariable ["lmf_spectatorDisplay", displayNull]] spawn lmf_spectator_fnc_showMedicalInfo;
*/

disableSerialization;
params [["_display", displayNull]];
if (isNull _display) exitWith {};

private _info1 = _display ctrlCreate ["RscStructuredText", -2];
private _info2 = _display ctrlCreate ["RscStructuredText", -2];
private _lastState = [];
private _lastTarget = objNull;
private _lastTargetAlive = false;
private _nextMedicalPoll = 0;

_info1 ctrlShow false;
_info2 ctrlShow false;

while {
	!alive player
	&& {!isNull _display}
	&& {(uiNamespace getVariable ["lmf_spectatorDisplay", displayNull]) isEqualTo _display}
} do {
	private _target = ([] call ace_spectator_fnc_getCameraAttributes) param [1, objNull, [objNull]];
	if !(_target isKindOf "CAManBase") then {_target = objNull};
	private _targetAlive = !isNull _target && {alive _target};
	private _targetChanged = _target isNotEqualTo _lastTarget;
	private _aliveChanged = _targetAlive isNotEqualTo _lastTargetAlive;

	if (_targetChanged || {_aliveChanged} || {_targetAlive && {CBA_missionTime >= _nextMedicalPoll}}) then {
		_lastTarget = _target;
		_lastTargetAlive = _targetAlive;

		private _state = if (isNull _target) then {
			[objNull]
		} else {
			if (!_targetAlive) then {
				[_target, false]
			} else {
				_nextMedicalPoll = CBA_missionTime + 0.25;
				private _targetBleeding = [_target] call ace_medical_blood_fnc_isBleeding;
				private _targetStable = _target call ace_medical_fnc_isInStableCondition;
				private _bloodVolume = _target getVariable ["ace_medical_bloodVolume", 6];
				private _bloodTier = switch true do {
					case (_bloodVolume <= 3.6): {4};
					case (_bloodVolume <= 4.2): {3};
					case (_bloodVolume <= 5.1): {2};
					case (_bloodVolume < 6): {1};
					default {0};
				};

				[_target, true, _targetBleeding, _targetStable, _bloodTier]
			}
		};

		if (_state isNotEqualTo _lastState) then {
			private _stateTarget = _state select 0;

			if (isNull _stateTarget) then {
				_info1 ctrlShow false;
				_info2 ctrlShow false;
			} else {
				if !(_state select 1) then {
					_info1 ctrlSetPosition [0.2871, 1.128, 0.4261, 0.05];
					_info1 ctrlSetBackgroundColor [0, 0, 0, 0.75];
					_info1 ctrlSetStructuredText parseText "<t shadow='2' size='1.1' align='center' color='#ff0000'>Dead</t>";
					_info1 ctrlCommit 0;
					_info1 ctrlShow true;
					_info2 ctrlShow false;
				} else {
					_state params ["", "", "_targetBleeding", "_targetStable", "_bloodTier"];

					private _bloodData = [
						["", "#FFFFFF"],
						["some blood", "#fff04e"],
						["a lot of blood", "#ff9e1f"],
						["a large amount of blood", "#fe5d18"],
						["a fatal amount of blood", "#ff0000"]
					] select _bloodTier;
					_bloodData params ["_bloodText", "_bloodColor"];

					private _bleedingText = ["not bleeding", "bleeding"] select _targetBleeding;
					private _bleedingColor = ["#FFFFFF", "#ff0000"] select _targetBleeding;
					private _stableText = ["not stable", "in stable condition"] select _targetStable;
					private _stableColor = ["#ff0000", "#FFFFFF"] select _targetStable;
					private _blood = if (_bloodTier == 0) then {
						"<t shadow='2' size='0.9' align='left'>Has not lost any blood</t>"
					} else {
						format ["<t shadow='2' size='0.9' align='left' color='%2'>Has lost %1</t>", _bloodText, _bloodColor]
					};

					private _medicalText = format [
						"<t shadow='2' size='0.9' align='left' color='%2'>Is %1</t><br/><t shadow='2' size='0.9' align='left' color='%4'>Is %3</t><br/>%5",
						_bleedingText,
						_bleedingColor,
						_stableText,
						_stableColor,
						_blood
					];
					private _icon = format [
						"<br/><img image='\A3\ui_f\data\igui\cfg\actions\heal_ca.paa' size='1' align='center' color='%1'/>",
						_bloodColor
					];

					_info1 ctrlSetPosition [0.3931, 1.128, 0.32, 0.117];
					_info1 ctrlSetBackgroundColor [0, 0, 0, 0.75];
					_info1 ctrlSetStructuredText parseText _medicalText;
					_info2 ctrlSetPosition [0.2871, 1.128, 0.103, 0.117];
					_info2 ctrlSetBackgroundColor [1, 1, 1, 0.35];
					_info2 ctrlSetStructuredText parseText _icon;
					_info1 ctrlCommit 0;
					_info2 ctrlCommit 0;
					_info1 ctrlShow true;
					_info2 ctrlShow true;
				};
			};

			_lastState = _state;
		};
	};

	uiSleep 0.05;
};

if (!isNull _info1) then {ctrlDelete _info1};
if (!isNull _info2) then {ctrlDelete _info2};
