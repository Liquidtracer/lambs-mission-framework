/*
	Mission settings
	Defines mission-wide framework settings.
*/

// Mission metadata
var_missionTitle = "LAMBS Mission Framework";
var_missionSubtitle = "Development mission";
var_author = "Alex2k";
var_enemySide = EAST; // Enemy side: WEST, EAST or INDEPENDENT.

// Warmup
var_warmup = true; // Starts the mission with warmup.
var_maxWarmupTime = ""; // Maximum warmup duration as "MM:SS"; "" disables the deadline.

// Respawn
var_respawnType = "OFF"; // "OFF", "WAVE", "TICKETS", delay in seconds or custom display text.
var_respawnTime = 900; // Respawn delay in seconds for "WAVE" or "TICKETS".
var_respawnTickets = 0; // Tickets per player when using "TICKETS".

// Players
var_playerGear = true; // Applies custom player gear; false retains starting Eden equipment and restores it on respawn.
var_keepRole = false; // Role after respawn: true restores the slot's original role; false gives Rifleman.
var_camoCoef = 1; // Higher values make players easier for AI to spot.
var_jipTp = true; // Enables JIP teleport to friendlies.
var_personalArsenal = true; // Enables Personal Arsenal and Available Optics during warmup; requires var_playerGear.

// Player gear (only relevant if var_playerGear = true)
var_personalRadio = true; // Gives everyone an AN/PRC-343.
var_playerGps = 2; // Recipients: 0 = all, 1 = leaders, 2 = none.
var_pistolAll = false; // Gives all players sidearms.
var_playerNvg = 0; // Recipients: 0 = all, 1 = pilots, 2 = none.
var_playerMaps = 0; // Recipients: 0 = all, 1 = leaders, 2 = none.
var_riflemanLat = true; // Gives riflemen a light anti-tank weapon.

// Map systems
var_oldSchoolMap = false; // Disables sharing of markers and drawings on the map.
var_bft = true; // Enables blue force tracking.

// Available BFT callsigns (only relevant if var_bft = true)
var_bftInfantry = ["FOX"]; // Infantry: NAME/6, NAME/1-4 and NAME/1V-4V.
var_bftGroundVehicles = []; // Vehicles: NAME1-4.
var_bftAirVehicles = []; // Air: NAME1-4.

// Ground vehicle classnames.
var_vic1 = "";
var_vic2 = "";
var_vic3 = "";
var_vic4 = "";

// Aircraft classnames.
var_air1 = "";
var_air2 = "";
var_air3 = "";
var_air4 = "";

var_supSquad = "Box_IND_Ammo_F"; // Supply spawnpad squad supplies
var_supLarge = "I_supplyCrate_F"; // Supply spawnpad large supplies
var_supExplosives = "Box_IND_AmmoOrd_F"; // Supply spawnpad explosives supplies
var_supMedical = "ACE_medicalSupplyCrate"; // Supply spawnpad medical supplies
var_supVehicle = "Box_IND_AmmoVeh_F"; // Vehicle supply crate

// Supply drop
var_supplyDropLimit = 12; // Number of available supply drops.
var_supplyDropAircraft = "B_Heli_Transport_01_unarmed_F"; // Aircraft classname; planes and helicopters use the same parachute delivery.
var_supplyDropVehicles = true; // Allows vehicle requests through supply drop.

// Forward deploy
var_forwardDeploy = false; // Allows group leaders to register for forward deployment during warmup.
var_deployHeight = 0; // Deployment height in meters: 0 = ground; positive values below 100 use 100.
