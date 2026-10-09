/*
	LMF function registration
	Functions are named lmf_<system>_fnc_<action>. Subfolders do not change the tag.
*/

class objectSorting {
	tag = "lmf_objectSorting";
	class functions {
		file = "framework\objectSorting";
		class sortUnits {};
		class sortGroundVehicles {};
		class sortAirVehicles {};
		class sortSupplyCrates {};
		class sortWaterVehicles {};
	};
};
class ai {
	tag = "lmf_ai";
	class functions {
		file = "framework\ai";
		class initUnit {};
		class initGroundVehicle {};
		class initAirVehicle {};
		class initWaterVehicle {};
		class buildWeaponLoadout {};
		class manageNvg {};
	};
	class eventHandlers {
		file = "framework\ai\eventHandlers";
		class onKilled {};
		class onHit {};
		class onFlare {};
	};
	class fireSupport {
		file = "framework\ai\fireSupport";
		class fireSupportAtTarget {};
	};
	class tasks {
		file = "framework\ai\tasks";
		class taskHunt {};
		class taskUavAttack {};
		class taskConverge {};
		class taskPatrol {};
	};
	class boats {
		file = "framework\ai\boats";
		class initBoatAssault {};
		class findShorelinePosition {};
		class landBoatGroup {};
		class dismountBoatGroup {};
		class spawnBoatForGroup {};
	};
	class groups {
		file = "framework\ai\groups";
		class assignCallsign {};
		class findJoinableGroups {};
		class reassignSurvivor {};
		class clearGarrisonStance {};
	};
	class spawning {
		file = "framework\ai\spawning";
		class isSpawner {};
		class spawnPatrol {};
		class spawnGarrison {};
		class spawnInfantryQrf {};
		class spawnInfantryHunters {};
		class spawnVehicleQrf {};
		class spawnParadropQrf {};
		class runWaves {};
		class getPlayerProximityState {};
	};
};
class supplyDrop {
	tag = "lmf_supplyDrop";
	class functions {
		file = "framework\supplyDrop";
		class deliverSupplies {};
	};
};
class paradrop {
	tag = "lmf_paradrop";
	class functions {
		file = "framework\paradrop";
		class paradropPassengers {};
		class dropUnit {};
		class dropUnitLocal {};
		class dropObject {};
		class fireCountermeasures {};
	};
};
class equipment {
	tag = "lmf_equipment";
	class functions {
		file = "framework\equipment";
		class getPlayerConfig {};
		class applyRoleFromClass {};
		class showRoleChangeMessage {};
		class applyBaseLoadout {};
		class addItem {};
		class giveWeapon {};
		class applyRankInsignia {};
	};
	class roles {
		file = "framework\equipment\roles";
		class applyAntiTankGunner {};
		class applyAntiTankAssistant {};
		class applyAutorifleman {};
		class applyVehicleCrew {};
		class applyVehiclePlatoonLeader {};
		class applyVehicleCommander {};
		class applyGrenadier {};
		class applyHelicopterCrew {};
		class applyHelicopterPilot {};
		class applyJtac {};
		class applyMachineGunner {};
		class applyMachineGunnerAssistant {};
		class applyMedic {};
		class applyPilot {};
		class applyPlatoonLeader {};
		class applyPlatoonSergeant {};
		class applyRifleman {};
		class applyRadioOperator {};
		class applySquadLeader {};
		class applyTeamLeader {};
	};
};
class playerVehicles {
	tag = "lmf_playerVehicles";
	class functions {
		file = "framework\playerVehicles";
		class initAirVehicle {};
		class initGroundVehicle {};
	};
};
class supplyCrates {
	tag = "lmf_supplyCrates";
	class functions {
		file = "framework\supplyCrates";
		class initSupplyCrate {};
	};
};
class briefing {
	tag = "lmf_briefing";
	class functions {
		file = "framework\briefing";
		class buildRosterText {};
	};
};
class hitEffects {
	tag = "lmf_hitEffects";
	class functions {
		file = "framework\hitEffects";
		class onHit {};
	};
};
class respawn {
	tag = "lmf_respawn";
	class functions {
		file = "framework\respawn";
		class onKilled {};
		class onRespawn {};
	};
};
class jipTeleport {
	tag = "lmf_jipTeleport";
	class functions {
		file = "framework\jipTeleport";
		class selectTeleportTarget {};
		class hasEmptySeat {};
	};
};
class forwardDeploy {
	tag = "lmf_forwardDeploy";
	class functions {
		file = "framework\forwardDeploy";
		class updateDeploymentRegistrations {};
		class deployUnitsAndAssets {};
	};
};
class notifications {
	tag = "lmf_notifications";
	class functions {
		file = "framework\notifications";
		class showAceMessage {};
	};
};
class spectator {
	tag = "lmf_spectator";
	class functions {
		file = "framework\spectator";
		class showMedicalInfo {};
	};
};
class vehicleService {
	tag = "lmf_vehicleService";
	class functions {
		file = "framework\vehicleService";
		class serviceVehicle {};
	};
};
class radio {
	tag = "lmf_radio";
	class functions {
		file = "framework\radio";
		class hasLongRangeRadio {};
	};
};
class bft {
	tag = "lmf_bft";
	class functions {
		file = "framework\bft";
		class trackObject {};
	};
};
class admin {
	tag = "lmf_admin";
	class functions {
		file = "framework\admin";
		class endWarmup {};
		class requestPerformanceReport {};
		class reportPerformance {};
		class assignZeus {};
		class triggerRespawnWave {};
		class setPlayerSafety {};
		class endMission {};
	};
};
class chat {
	tag = "lmf_chat";
	class functions {
		file = "framework\chat";
		class findPlayerByName {};
		class bringIntoVehicle {};
		class sendChatMessage {};
	};
};
class assetSpawner {
	tag = "lmf_assetSpawner";
	class functions {
		file = "framework\assetSpawner";
		class spawnObjectAtPad {};
	};
};
