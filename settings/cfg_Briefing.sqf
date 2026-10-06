/*
    Briefing settings
    Defines the mission briefing text.
    Supported formats vary by category to ensure correct layout rendering:
        Plain text (string wrapped in ""): SITUATION, MISSION, EXECUTION INTENT
        Standard list (array of strings ["",""]): FRIENDLY, CONOP, COORD, LOGISTICS
        Nested list (array of [title, content] arrays): ENEMY
    You can link to map markers using HTML tags: <marker name='mrk_name'>[MARKER TEXT]</marker>
*/

// Situation
private _brfSituation = "Development mission for LAMBS Mission Framework on Altis.";

// Enemy
private _brfEnemyFaction = "Test opposition";
private _brfEnemy = [];

// Friendly
private _brfFriendFaction = "LMF test players";
private _brfFriend = ["Playable groups are available for framework testing."];

// Mission
private _brfMission = "Develop and test LMF features in Eden and on a dedicated server, including Join-in-Progress.";

private _brfExecIntent = "Verify the feature under test without unrelated scenario objectives.";
private _brfExecConop = [];
private _brfExecCoord = [];

// Logistics
private _brfAdministration = ["Player equipment and framework options are configured in settings/."];

// Special thanks: [name, explanation].
private _thanks = [
    ["The LAMBS community", "for showing up week after week, year after year, taking responsibility when needed, and creating a community where mission makers have always felt that the time and effort put into making missions is genuinely appreciated."],
    ["nKenny", "for sharing code and systems that helped shape LMF, teaching me a great deal about SQF, and for all the conversations about code, ideas, and functionality over the years."],
    ["Liquid Tracer", "for always being willing to help test LMF, spending countless hours tracking down bugs, and giving thoughtful feedback on how things actually work in practice."]
];