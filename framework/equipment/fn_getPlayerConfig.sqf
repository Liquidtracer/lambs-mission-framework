/*
	Get Player equipment configuration
	Internal LMF helper; not a supported custom-script API.
	Returns the machine-local registry, loading it synchronously if absent.
	Works regardless of lmf_playerGear. Treat the returned registry as read-only.

	Arguments: None
	Returns: Existing Player equipment registry <HASHMAP>

	Example:
		private _config = call lmf_equipment_fnc_getPlayerConfig;
*/

if (isNil "lmf_player_config") then {
	call compile preprocessFileLineNumbers "framework\equipment\loadSettings.sqf";
};

lmf_player_config
