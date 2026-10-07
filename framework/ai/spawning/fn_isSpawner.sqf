/*
	AI spawning authority
	Returns whether this machine is responsible for AI spawning.

	Example:
		[] call lmf_ai_fnc_isSpawner;
*/

_isSpawner = false;
// HC spawning is intentionally disabled; retained for possible future use.
/*
private _headless = (count entities "HeadlessClient_F") > 0;

if (_headless && {isMultiplayer}) then {
	if (typeOf player == "HeadlessClient_F") then {
		_isSpawner = true;
	};
} else {
	if (isServer) then {
		_isSpawner = true;
	};
};
*/

// Use the server for AI spawning.
if (isServer) then {
	_isSpawner = true;
};

_isSpawner