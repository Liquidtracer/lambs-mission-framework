/*
	Show ACE message
	Displays a local structured ACE message. No queue or JIP replay.
	Call on the receiving client; callers own recipient selection and timing.
	Author: Alex2k.

	Arguments:
		0: Title <STRING> ("" omits title and its line)
		1: Message text <STRING> (supports structured text markup)
		2: Icon path <STRING> (default: "A3\modules_f_curator\data\portraitradio_ca.paa"; "" omits icon and its line)
		3: Text box height <NUMBER> (default: 3.3)
		4: Text box width <NUMBER> (default: 12)
		5: Sound <STRING> (default: "TacticalPing4"; "" disables sound)
		6: Icon size <NUMBER> (default: 1.45)
		7: Error body color <BOOLEAN> (default: false; explicit inline colors are preserved)
	Height/width are ACE textbox units, not duration. ACE owns display lifetime.

	Presentation: errors use red text and addItemFailed; explanatory text may be white.
	Passive negative status may remain silent. Callers choose color and sound independently.
	Separate complete sentences with <br/> when text continues; omit trailing breaks.

	Example:
		["SUPPLY DROP", "A map is required.", "\A3\ui_f_orange\Data\CfgTaskTypes\airdrop_ca.paa", 2.5, 10, "addItemFailed", 1, true] call lmf_notifications_fnc_showAceMessage;
*/

if (!hasInterface || {isNull player}) exitWith {};

params [
	"_title",
	"_text",
	["_icon", "A3\modules_f_curator\data\portraitradio_ca.paa", [""]],
	["_height", 3.3, [0]],
	["_width", 12, [0]],
	["_sound", "TacticalPing4", [""]],
	["_iconSize", 1.45, [0]],
	["_isError", false, [true]]
];

private _img = if (_icon == "") then {""} else {
	format ["<img image='%1' size='%2' color='%3'/><br/>", _icon, _iconSize, LMF_MAIN_COLOR]
};
private _textTitle = if (_title == "") then {""} else {
	format ["<t font='PuristaBold' shadow='2' color='%2' size='1.1' >%1</t><br/>", _title, LMF_MAIN_COLOR]
};
private _textContent = format ["<t shadow='2' color='%2' size='1' >%1</t>", _text, [LMF_TEXT_COLOR, LMF_ERROR_COLOR] select _isError];

[_img + _textTitle + _textContent, _height, player, _width] call ace_common_fnc_displayTextStructured;

if (_sound isNotEqualTo "") then {
	playSound _sound;
};
