/*
	Add configured weapons to a crate
	Adds one randomly assembled Player weapon configuration without clearing cargo.
	Server only; client calls return false without forwarding. Repeated calls add more.

	Arguments:
		0: Existing cargo container <OBJECT>
		1: Exact uppercase WEAPONS registry key <STRING>
		2: Weapon count <NUMBER> (positive integer; default 1)
		3: Total spare magazine count <NUMBER> (non-negative integer; default 0)
	Returns: Valid addition performed <BOOL>; not a capacity or carrying guarantee.
	Uses AMMO only: one full primary magazine per weapon, no tracers or GL ammunition.
	Use a different classname from automatic LMF Supply Crates, whose initializer clears cargo.

	Example:
		[marksmanCrate, "DMR", 1, 8] call lmf_supplyCrates_fnc_addWeaponToCrate;
*/

if (!isServer) exitWith {
	diag_log "LMF supplyCrates addWeaponToCrate: server-only call rejected.";
	false
};
if (isNil "_this" || {!(_this isEqualType [])} || {count _this < 2} || {count _this > 4} || {_this findIf {isNil {_x}} >= 0}) exitWith {
	diag_log "LMF supplyCrates addWeaponToCrate: expected [container, weaponKey, weaponCount?, spareCount?].";
	false
};
params ["_container", "_weaponKey", ["_weaponCount", 1], ["_spareCount", 0]];
if (!(_container isEqualType objNull) || {!(_weaponKey isEqualType "")} || {!(_weaponCount isEqualType 0)} || {!(_spareCount isEqualType 0)}) exitWith {
	diag_log "LMF supplyCrates addWeaponToCrate: invalid argument types.";
	false
};
if (isNull _container || {_container isKindOf "Man"} || {getNumber (configOf _container >> "maximumLoad") <= 0}) exitWith {
	diag_log "LMF supplyCrates addWeaponToCrate: expected a non-null cargo container with positive maximumLoad.";
	false
};
if (!finite _weaponCount || {!finite _spareCount} || {_weaponCount <= 0} || {_spareCount < 0} || {_weaponCount != floor _weaponCount} || {_spareCount != floor _spareCount}) exitWith {
	diag_log "LMF supplyCrates addWeaponToCrate: counts must be finite integers; weapons > 0, spares >= 0.";
	false
};

private _config = call lmf_equipment_fnc_getPlayerConfig;
private _weapons = _config get "WEAPONS";
if !(_weaponKey in _weapons) exitWith {
	diag_log format ["LMF supplyCrates addWeaponToCrate: unknown weapon key '%1'.", _weaponKey];
	false
};
private _category = _weapons get _weaponKey;
private _classes = _category getOrDefault ["CLASSES", []];
private _ammo = _category getOrDefault ["AMMO", []];
if (!(_classes isEqualType []) || {!(_ammo isEqualType [])} || {_classes isEqualTo []} || {_ammo isEqualTo []}) exitWith {
	diag_log format ["LMF supplyCrates addWeaponToCrate: %1 requires non-empty CLASSES and AMMO arrays.", _weaponKey];
	false
};
// Validate required pools before sampling. Blank options remain intentional no-add outcomes.
if (_classes findIf {isNil {_x} || {!(_x isEqualType "")} || {_x != "" && {!isClass (configFile >> "CfgWeapons" >> _x)}}} >= 0 || {
	_ammo findIf {isNil {_x} || {!(_x isEqualType "")} || {_x != "" && {!isClass (configFile >> "CfgMagazines" >> _x) || {getNumber (configFile >> "CfgMagazines" >> _x >> "count") <= 0}}}} >= 0
}) exitWith {
	diag_log format ["LMF supplyCrates addWeaponToCrate: %1 has invalid weapon or magazine entries.", _weaponKey];
	false
};
private _weapon = selectRandom _classes;
if (_weapon isEqualTo "") exitWith {
	diag_log format ["LMF supplyCrates addWeaponToCrate: %1 selected an empty weapon option.", _weaponKey];
	false
};
private _compatibleAmmo = (compatibleMagazines [_weapon, "this"]) apply {toLower _x};
private _ammoPool = _ammo select {_x isEqualTo "" || {toLower _x in _compatibleAmmo}};
if (_ammoPool isEqualTo []) exitWith {
	diag_log format ["LMF supplyCrates addWeaponToCrate: %1 has no compatible primary AMMO for %2.", _weaponKey, _weapon];
	false
};
private _magazine = selectRandom _ammoPool;
if (_magazine isEqualTo "") exitWith {
	diag_log format ["LMF supplyCrates addWeaponToCrate: %1 selected an empty AMMO option.", _weaponKey];
	false
};

private _slots = ["MuzzleSlot", "PointerSlot", "CowsSlot", "UnderBarrelSlot"];
private _compatibleAttachments = _slots apply {(compatibleItems [_weapon, _x]) apply {toLower _x}};
private _attachments = ["", "", "", ""];
{
	private _poolKey = _x;
	private _pool = _category getOrDefault [_poolKey, []];
	if !(_pool isEqualType []) then {
		diag_log format ["LMF supplyCrates addWeaponToCrate: %1 %2 is not an array; omitted.", _weaponKey, _poolKey];
	} else {
		if (_pool isNotEqualTo []) then {
			private _item = selectRandom _pool;
			if (isNil "_item" || {!(_item isEqualType "")}) then {
				diag_log format ["LMF supplyCrates addWeaponToCrate: %1 %2 selected an invalid attachment; omitted.", _weaponKey, _poolKey];
			} else {
				if (_item isNotEqualTo "") then {
					private _slot = _compatibleAttachments findIf {toLower _item in _x};
					if (!isClass (configFile >> "CfgWeapons" >> _item) || {_slot < 0}) then {
						diag_log format ["LMF supplyCrates addWeaponToCrate: %1 attachment %2 is invalid or incompatible with %3; omitted.", _weaponKey, _item, _weapon];
					} else {
						// Later pools replace earlier selections if both resolve to the same slot.
						_attachments set [_slot, _item];
					};
				};
			};
		};
	};
} forEach ["OPTICS", "ATTACHMENTS_1", "ATTACHMENTS_2", "BIPODS"];

private _weaponConfiguration = [
	_weapon, _attachments select 0, _attachments select 1, _attachments select 2,
	[_magazine, getNumber (configFile >> "CfgMagazines" >> _magazine >> "count")], [], _attachments select 3
];
_container addWeaponWithAttachmentsCargoGlobal [_weaponConfiguration, _weaponCount];
if (_spareCount > 0) then {_container addMagazineCargoGlobal [_magazine, _spareCount]};
true
