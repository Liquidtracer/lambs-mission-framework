/*
	Assign team color
	Assigns players to team colors.
	Author: Alex2k. Contributor: Drgn V4karian.
*/

waitUntil {sleep 1; time > 5};

private _unitStr = str player;
if ((_unitStr find "_RED") != -1) exitWith {
	player assignTeam "RED";
};

if ((_unitStr find "_BLUE") != -1) exitWith {
	player assignTeam "BLUE";
};

if ((_unitStr find "_GREEN") != -1) exitWith {
	player assignTeam "GREEN";
};

if ((_unitStr find "_YELLOW") != -1) exitWith {
	player assignTeam "YELLOW";
};

if ((_unitStr find "_WHITE") != -1) exitWith {
	player assignTeam "MAIN";
};