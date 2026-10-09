/*
	Framework preInit
	Loads settings, constants, fixed admin UIDs and BFT helpers during preInit.
*/

#include "..\settings\cfg_Mission.sqf"
#include "colors.hpp"

// Internal ordered definitions; mission makers configure only the five classname settings.
lmf_supplyCrates_definitions = [
	["LARGE", lmf_supLarge, "Large Supplies"],
	["SMALL", lmf_supSmall, "Small Supplies"],
	["EXPLOSIVES", lmf_supExplosives, "Explosives"],
	["MEDICAL", lmf_supMedical, "Medical"],
	["VEHICLE", lmf_supVehicle, "Vehicle Supplies (RRR)"]
];

// One server diagnostic per ambiguous classname, rather than one warning per object/JIP.
if (isServer) then {
	private _checkedClasses = [];
	{
		private _classname = _x select 1;
		if (_classname != "" && {!(_classname in _checkedClasses)}) then {
			_checkedClasses pushBack _classname;
			private _matches = lmf_supplyCrates_definitions select {(_x select 1) isEqualTo _classname};
			if (count _matches > 1) then {
				diag_log format ["[LMF] Supply classname %1 is shared by %2. Untagged crates keep their cargo; set lmf_supplyCrate_category in Eden. LMF menus pass the selected category explicitly.", _classname, _matches apply {_x select 0}];
			};
		};
	} forEach lmf_supplyCrates_definitions;
};

// Validate player respawn once per machine/session, before any consumers start.
private _respawnError = "";
if (isNil "lmf_respawnType" || {!(lmf_respawnType in ["OFF", "WAVE", "TICKETS"])}) then {
	_respawnError = "lmf_respawnType must be exactly OFF, WAVE or TICKETS";
} else {
	if (lmf_respawnType in ["WAVE", "TICKETS"]) then {
		if (isNil "lmf_respawnTime" || {!(lmf_respawnTime isEqualType 0)} || {!finite lmf_respawnTime} || {lmf_respawnTime <= 0}) then {
			_respawnError = "lmf_respawnTime must be a positive finite number for WAVE/TICKETS";
		};
	};
	if (lmf_respawnType isEqualTo "TICKETS") then {
		if (isNil "lmf_respawnTickets" || {!(lmf_respawnTickets isEqualType 0)} || {!finite lmf_respawnTickets} || {lmf_respawnTickets < 0} || {lmf_respawnTickets != floor lmf_respawnTickets}) then {
			_respawnError = "lmf_respawnTickets must be a non-negative finite integer for TICKETS";
		};
	};
};
if (_respawnError isNotEqualTo "") then {
	diag_log format ["[LMF] Invalid player respawn configuration: %1. Falling back to OFF. Check settings/cfg_Mission.sqf.", _respawnError];
	lmf_respawnType = "OFF";
};

LMF_VERSION = "2.0.0";

LMF_MAIN_COLOR = LMF_PALETTE_BLUE_HEX;
LMF_LINK_COLOR = LMF_PALETTE_ORANGE_HEX;
LMF_HIGHLIGHT_FRIENDLY_COLOR = LMF_PALETTE_GREEN_HEX;
LMF_TEXT_COLOR_DARK = LMF_PALETTE_GRAY_HEX;
LMF_ERROR_COLOR = LMF_PALETTE_RED_HEX;
LMF_TEXT_COLOR = LMF_PALETTE_WHITE_HEX;

LMF_STATUS_GOOD_COLOR = LMF_PALETTE_GREEN_HEX;
LMF_STATUS_WARNING_COLOR = LMF_PALETTE_ORANGE_HEX;
LMF_STATUS_CRITICAL_COLOR = LMF_PALETTE_RED_HEX;

LMF_LOGO = "framework\images\lambs.paa";

// These accounts can use LMF admin tools without a server admin login.
lmf_admin_uids = [
	"76561197968829665", // Alex2k
	"76561197962792796", // nkenny
	"76561197972498138"  // Liquid Tracer
];

// Load AI settings into the internal configuration registry.
call compile preprocessFileLineNumbers "framework\ai\loadSettings.sqf";

// Keep cfg_Player optional during normal startup with custom gear disabled.
if (lmf_playerGear) then {
	call compile preprocessFileLineNumbers "framework\equipment\loadSettings.sqf";
};

// Define BFT helpers and register request and feedback handlers.
call compile preprocessFileLineNumbers "framework\bft\initGroupState.sqf";
