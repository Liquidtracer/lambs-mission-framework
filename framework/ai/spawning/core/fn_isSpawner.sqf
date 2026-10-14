/*
	AI spawning authority
	Returns whether this machine is responsible for AI spawning.

	Example:
		[] call lmf_ai_fnc_isSpawner;
*/

_isSpawner = false;
// Use the server for AI spawning; HC spawning is intentionally disabled.
if (isServer) then {
	_isSpawner = true;
};

_isSpawner