/*
	Get player equipment configuration
	Internal accessor that loads the local registry when needed.
	Treat the returned registry pools as read-only.

	Returns: Player equipment registry <HASHMAP>
*/

if (isNil "lmf_player_config") then {
	call compile preprocessFileLineNumbers "framework\equipment\loadSettings.sqf";
};

lmf_player_config
