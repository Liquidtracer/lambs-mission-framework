/*
    Mission settings
    Defines mission-wide framework settings.
*/

// Mission metadata
var_missionTitle = "Lambs Mission Framework";
var_missionSubtitle = "Development mission";
var_author = "Alex2k";
var_enemySide = EAST; // Enemy side: WEST, EAST or INDEPENDENT. Default: EAST.

// Warmup
var_warmup = true; // Starts the mission with warmup. Default: true.
var_maxWarmupTime = ""; // Maximum warmup duration as "MM:SS"; "" disables the deadline.

// Respawn
var_respawnType = "OFF"; // "OFF", "WAVE", "TICKETS", delay in seconds or custom display text. Default: "OFF".
var_respawnTime = 900; // Respawn delay in seconds for "WAVE" or "TICKETS". Default: 900.
var_respawnTickets = 0; // Tickets per player when using "TICKETS". Default: 0.

// Players
var_playerGear = true; // Applies custom player gear. Default: true.
var_keepRole = false; // Role after respawn: true restores the slot's original role; false gives Rifleman. Default: false.
var_camoCoef = 1; // Higher values make players easier for AI to spot. Default: 1.
var_jipTp = true; // Enables JIP teleport to friendlies. Default: true.
var_personalArsenal = true; // Enables the limited personal arsenal during warmup. Default: true.

// Player gear (only relevant if var_playerGear = true)
var_personalRadio = true; // Gives everyone an AN/PRC-343. Default: false.
var_playerGps = 2; // Recipients: 0 = all, 1 = leaders, 2 = none. Default: 2.
var_pistolAll = false; // Gives all players sidearms. Default: false.
var_playerNvg = 0; // Recipients: 0 = all, 1 = pilots, 2 = none. Default: 2.
var_playerMaps = 0; // Recipients: 0 = all, 1 = leaders, 2 = none. Default: 0.
var_riflemanLat = true; // Gives riflemen a light anti-tank weapon. Default: true.

// Map systems
var_oldSchoolMap = false; // Disables sharing of markers and drawings on the map. Default: false.
var_bft = true; // Enables blue force tracking. Default: true.

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
var_supplyDropLimit = 12; // Number of available supply drops. Default: 0.
var_suppDropPlane = "B_Heli_Transport_01_unarmed_F"; // Delivery aircraft classname.
var_supplyDropDelivery = "SLINGLOAD"; // PARACHUTE supports planes and helicopters. SLINGLOAD requires a helicopter that can lift the configured cargo.
var_supplyDropVehicles = true; // Allows vehicle requests through supply drop.

// Mine clearance support
var_supportClearanceLimit = 0; // Number of dispatches; 0 disables support. Default: 0.
var_supportVehicleClass = "B_Truck_01_transport_F"; // Support land vehicle classname.

// Forward deploy
var_forwardDeploy = false; // Allows group leaders to register for forward deployment during warmup. Default: false.
var_deployHeight = 0; // Deployment height in metres: 0 = ground; positive values below 100 use 100. Default: 0.
