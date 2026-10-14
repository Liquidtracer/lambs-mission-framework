/*
	Framework notifications
	Defines the framework notifications using the shared UI palette.
*/

#include "..\colors.hpp"

class CfgNotifications {
	class Default {
		title = "";
		iconPicture = "";
		iconText = "";
		description = "";
		color[] = {LMF_PALETTE_WHITE_RGBA};
		duration = 5;
		priority = 0;
		difficulty[] = {};
	};

	class lmf_notifications_victory {
		title = "Victory";
		iconPicture = "\A3\modules_f_curator\Data\portraitAnimalsSheep_ca.paa";
		iconText = "+%2";
		description = "%1";
		color[] = {LMF_PALETTE_GREEN_RGBA};
		duration = 10;
	};

	class lmf_notifications_defeat {
		title = "Defeat";
		iconPicture = "\A3\modules_f_curator\Data\portraitAnimalsSheep_ca.paa";
		iconText = "+%2";
		description = "%1";
		color[] = {LMF_PALETTE_RED_RGBA};
		duration = 10;
	};

	class lmf_notifications_message {
		title = "Notification";
		iconPicture = "\A3\modules_f_curator\Data\portraitAnimalsSheep_ca.paa";
		iconText = "+%2";
		description = "%1";
		color[] = {LMF_PALETTE_ORANGE_RGBA};
		duration = 10;
	};
};
