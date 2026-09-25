/*
    Request performance report
    Checks admin access and requests a performance report.

    Arguments:
        0: Requesting admin <OBJECT>

    Example:
        [player] call lmf_admin_fnc_requestPerformanceReport;
*/

params ["_unit"];

#include "checkAdminAccess.sqf"

// Call performance check globally
[_unit] remoteExec ["lmf_admin_fnc_reportPerformance",0];