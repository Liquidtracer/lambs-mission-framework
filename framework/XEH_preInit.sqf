/*
	Framework preInit
	Loads settings, constants, fixed admin UIDs and BFT helpers during preInit.
*/

#include "..\settings\cfg_Mission.sqf"
#include "colors.hpp"

LMF_VERSION = "2.0.0";

LMF_MAIN_COLOR = LMF_PALETTE_BLUE_HEX;
LMF_LINK_COLOR = LMF_PALETTE_ORANGE_HEX;
LMF_HIGHLIGHT_FRIENDLY_COLOR = LMF_PALETTE_GREEN_HEX;
LMF_TEXT_COLOR_DARK = LMF_PALETTE_GRAY_HEX;
LMF_ERROR_COLOR = LMF_PALETTE_RED_HEX;
LMF_TEXT_COLOR = LMF_PALETTE_WHITE_HEX;

LMF_LOGO = "framework\images\lambs.paa";

// These accounts can use LMF admin tools without a server admin login.
lmf_admin_uids = [
	"76561197968829665", // Alex2k
	"76561197962792796", // nkenny
	"76561197972498138"  // Liquid Tracer
];

// Load AI settings into the internal configuration registry.
call compile preprocessFileLineNumbers "framework\ai\loadSettings.sqf";

// Define BFT helpers and register request and feedback handlers.
call compile preprocessFileLineNumbers "framework\bft\initGroupState.sqf";
