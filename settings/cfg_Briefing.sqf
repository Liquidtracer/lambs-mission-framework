/*
	Briefing settings
	Defines the mission briefing text.
	Supported formats vary by category to ensure correct layout rendering:
		Plain text (string wrapped in ""): SITUATION, MISSION, EXECUTION INTENT
		Standard list (array of strings ["",""]): FRIENDLY, CONOP, COORD, LOGISTICS
		Nested list (array of [title, content] arrays): ENEMY
	You can link to map markers using HTML tags: <marker name='mrk_name'>[MARKER TEXT]</marker>
*/

// Example OPORD for an Altis infantry mission. Adapt the scenario to your Eden mission.
// Situation
private _brfSituation = "CSAT troops occupy a settlement on Altis. Defensive positions cover the main approaches, while patrols operate in the surrounding area. Enemy reinforcements may respond if the garrison is alerted.";

// Enemy
private _brfEnemyFaction = "CSAT local security forces";
private _brfEnemy = [
	["Composition", "Infantry holding the settlement, supported by nearby patrols."],
	["Threats", "Prepared defensive positions and possible reinforcements."],
	["MLCOA", "Maintain security and patrol the approaches."],
	["MDCOA", "Call reinforcements and counterattack once engaged."]
];

// Friendly
private _brfFriendFaction = "NATO Task Force FOX";
private _brfFriend = [
	"FOX: Infantry platoon (players).",
	"Higher HQ: Provides mission tasking and support."
];

// Mission
private _brfMission = "FOX will secure the settlement and deny CSAT control of the area in order to establish a position for follow-on operations.";

// Execution
private _brfExecIntent = "Approach under cover, isolate the defenders and clear the objective. End state: The settlement is secure and FOX is regrouped.";
private _brfExecConop = [
	"Phase I (Approach): Reconnoiter the settlement and identify enemy positions.",
	"Phase II (Assault): Clear the objective and defeat any reinforcements.",
	"Phase III (Consolidate): Regroup, treat casualties and report mission complete."
];
private _brfExecCoord = [
	"Maintain positive identification and avoid unnecessary civilian casualties.",
	"Squad leaders report contacts and casualties to platoon HQ."
];

// Logistics
private _brfAdministration = [
	"Medical: Treat and report casualties using ACE medical procedures.",
	"Resupply: Coordinate ammunition and medical supply requirements within FOX."
];

// Special thanks: [name, explanation].
private _thanks = [
	["The LAMBS community", "for showing up week after week, year after year, taking responsibility when needed, and creating a community where mission makers have always felt that the time and effort put into making missions is genuinely appreciated."],
	["nKenny", "for sharing code and systems that helped shape LMF, teaching me a great deal about SQF, and for all the conversations about code, ideas, and functionality over the years."],
	["Liquid Tracer", "for always being willing to help test LMF, spending countless hours tracking down bugs, and giving thoughtful feedback on how things actually work in practice."]
];
