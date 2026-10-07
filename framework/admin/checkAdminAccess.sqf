/*
	Admin access check
	Checks server admin or fixed UID access for _unit in the caller's scope.
	Included by admin functions after preInit defines lmf_admin_uids.
*/

private _admin = false;

// Disallow use before mission load
if (isMultiplayer && {getClientStateNumber < 10}) exitWith {systemChat "Admin tools are only available in-game."};

if (isServer) then {
	// The local SP player / hosted-server player does not need an admin login.
	_admin = hasInterface && {!isNull _unit} && {_unit isEqualTo player};
	if (!_admin) then {
		_admin = (getPlayerUID _unit) in lmf_admin_uids || {admin owner _unit > 0};
	};
} else {
	_admin = hasInterface && {_unit isEqualTo player} && {
		(getPlayerUID _unit) in lmf_admin_uids || {call BIS_fnc_admin > 0}
	};
};

if !(_admin) exitWith {"LMF or server admin access required." remoteExec ["systemChat", _unit]};
