/*
	Apply spawner textures
	Applies asset-spawner laptop textures on the client.
*/

if !(isNil "supplySpawner") then {supplySpawner setObjectTexture [0, "framework\images\supplies.jpg"];};
if !(isNil "airSpawner") then {airSpawner setObjectTexture [0, "framework\images\airVehicles.jpg"];};
if !(isNil "groundSpawner") then {groundSpawner setObjectTexture [0, "framework\images\groundVehicles.jpg"];};
