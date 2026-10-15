/*
	Mission settings
	Defines mission-wide framework settings.
*/

// Mission metadata
lmf_missionTitle = "LAMBS Mission Framework";
lmf_missionSubtitle = "Development mission";
lmf_author = "Alex2k";
lmf_enemySide = EAST; // Enemy side: WEST, EAST or INDEPENDENT.

// Warmup
lmf_warmup = true; // Starts the mission with warmup.
lmf_maxWarmupTime = ""; // Mission-time warmup deadline as "MM:SS"; "" disables the deadline.

// Respawn
lmf_respawnType = "OFF"; // Exactly "OFF", "WAVE" or "TICKETS".
lmf_respawnTime = 900; // Positive mission-time wave interval in seconds for "WAVE" or "TICKETS".
lmf_respawnTickets = 0; // Non-negative integer allowance per client session for "TICKETS"; consumed on death.

// Players
lmf_playerGear = true; // Applies custom player gear; false retains starting Eden equipment and restores it on respawn.
lmf_keepRole = false; // Role after respawn: true restores the slot's original role; false gives Rifleman.
lmf_camoCoef = 1; // Higher values make players easier for AI to spot.
lmf_jipTp = true; // Enables JIP teleport to friendlies.
lmf_personalArsenal = true; // Enables role-aware ACE Personal Arsenal during warmup; requires lmf_playerGear.

// Player loadout options
lmf_personalRadio = true; // Gives everyone the configured personal radio.
lmf_playerGps = 2; // Recipients: 0 = all, 1 = configured leader and pilot roles, 2 = none.
lmf_pistolAll = false; // Gives all players sidearms.
lmf_playerNvg = 0; // Recipients: 0 = all, 1 = pilots, 2 = none.
lmf_playerMaps = 0; // Recipients: 0 = all, 1 = configured leader and pilot roles, 2 = none.
lmf_riflemanLat = true; // Gives riflemen a light anti-tank weapon.

// Map systems
lmf_oldSchoolMap = false; // Disables sharing of markers and drawings on the map.
lmf_bft = true; // Enables blue force tracking.

// Available BFT callsigns (only relevant if lmf_bft = true)
lmf_bftInfantryCallsigns = ["FOX"]; // Infantry: NAME/6, NAME/1-4 and NAME/1V-4V.
lmf_bftGroundCallsigns = []; // Vehicles: NAME1-4.
lmf_bftAirCallsigns = []; // Air: NAME1-4.

// Ground vehicle classnames.
lmf_groundVehicles = [
	"CUP_M1240_OGPK_M240_NATO",
	"B_Quadbike_01_F"
];

// Aircraft classnames.
lmf_airVehicles = [
	"B_Heli_Light_01_dynamicLoadout_F",
	"B_Heli_Transport_01_pylons_F"
];

// Shared supply crates: enabled categories must use unique classnames (case-insensitive).
lmf_supLarge = "I_supplyCrate_F"; // Large Supplies; "" disables this category.
lmf_supSmall = "Box_IND_Ammo_F"; // Small Supplies; "" disables this category.
lmf_supExplosives = "Box_IND_AmmoOrd_F"; // Explosives; "" disables this category.
lmf_supMedical = "ACE_medicalSupplyCrate"; // Medical; "" disables this category.
lmf_supVehicle = "Box_IND_AmmoVeh_F"; // Vehicle Supplies (RRR); "" disables this category.

// Supply drop
lmf_supplyDropLimit = 3; // Number of available supply drops.
lmf_supplyDropAircraft = "B_Heli_Transport_01_unarmed_F"; // Aircraft classname; planes and helicopters use the same parachute delivery.
lmf_supplyDropVehicles = true; // Allows vehicle requests through supply drop.

// Forward deploy
lmf_forwardDeploy = false; // Allows group leaders to register for forward deployment during warmup.
lmf_forwardDeploy_height = 0; // Deployment height in meters: 0 = ground; positive values below 100 use 100.
