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
lmf_maxWarmupTime = ""; // Maximum warmup duration as "MM:SS"; "" disables the deadline.

// Respawn
lmf_respawnType = "OFF"; // "OFF", "WAVE", "TICKETS", delay in seconds or custom display text.
lmf_respawnTime = 900; // Respawn delay in seconds for "WAVE" or "TICKETS".
lmf_respawnTickets = 0; // Tickets per player when using "TICKETS".

// Players
lmf_playerGear = true; // Applies custom player gear; false retains starting Eden equipment and restores it on respawn.
lmf_keepRole = false; // Role after respawn: true restores the slot's original role; false gives Rifleman.
lmf_camoCoef = 1; // Higher values make players easier for AI to spot.
lmf_jipTp = true; // Enables JIP teleport to friendlies.
lmf_personalArsenal = true; // Enables Personal Arsenal and Available Optics during warmup; requires lmf_playerGear.

// Player gear (only relevant if lmf_playerGear = true)
lmf_personalRadio = true; // Gives everyone an AN/PRC-343.
lmf_playerGps = 2; // Recipients: 0 = all, 1 = leaders, 2 = none.
lmf_pistolAll = false; // Gives all players sidearms.
lmf_playerNvg = 0; // Recipients: 0 = all, 1 = pilots, 2 = none.
lmf_playerMaps = 0; // Recipients: 0 = all, 1 = leaders, 2 = none.
lmf_riflemanLat = true; // Gives riflemen a light anti-tank weapon.

// Map systems
lmf_oldSchoolMap = false; // Disables sharing of markers and drawings on the map.
lmf_bft = true; // Enables blue force tracking.

// Available BFT callsigns (only relevant if lmf_bft = true)
lmf_bftInfantry = ["FOX"]; // Infantry: NAME/6, NAME/1-4 and NAME/1V-4V.
lmf_bftGroundVehicles = []; // Vehicles: NAME1-4.
lmf_bftAirVehicles = []; // Air: NAME1-4.

// Ground vehicle classnames.
lmf_vic1 = "";
lmf_vic2 = "";
lmf_vic3 = "";
lmf_vic4 = "";

// Aircraft classnames.
lmf_air1 = "";
lmf_air2 = "";
lmf_air3 = "";
lmf_air4 = "";

lmf_supSquad = "Box_IND_Ammo_F"; // Supply spawnpad squad supplies
lmf_supLarge = "I_supplyCrate_F"; // Supply spawnpad large supplies
lmf_supExplosives = "Box_IND_AmmoOrd_F"; // Supply spawnpad explosives supplies
lmf_supMedical = "ACE_medicalSupplyCrate"; // Supply spawnpad medical supplies
lmf_supVehicle = "Box_IND_AmmoVeh_F"; // Vehicle supply crate

// Supply drop
lmf_supplyDropLimit = 12; // Number of available supply drops.
lmf_supplyDropAircraft = "B_Heli_Transport_01_unarmed_F"; // Aircraft classname; planes and helicopters use the same parachute delivery.
lmf_supplyDropVehicles = true; // Allows vehicle requests through supply drop.

// Forward deploy
lmf_forwardDeploy = false; // Allows group leaders to register for forward deployment during warmup.
lmf_deployHeight = 0; // Deployment height in meters: 0 = ground; positive values below 100 use 100.
