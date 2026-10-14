/*
	Wait for spawned soldier initialization
	Internal scheduled owner operation. Waits for LMF's CBA InitPost route and gear attempt.
	A completed gear attempt can retain the original loadout after the existing switch timeout.
	Does not promise completion of unrelated mods' asynchronous initialization.
*/

params ["_group"];
waitUntil {
	sleep 0.01;
	isNull _group || {!local _group} || {
		units _group findIf {
			alive _x && {local _x} && {
				!(_x getVariable ["lmf_ai_initComplete", false])
				|| {!scriptDone (_x getVariable ["lmf_ai_gearScript", scriptNull])}
			}
		} == -1
	}
};
