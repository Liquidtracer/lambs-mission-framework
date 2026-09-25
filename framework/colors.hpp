/*
    UI palette
    Defines shared colour constants for SQF and notification configuration.
*/

#ifndef LMF_COLORS_HPP
#define LMF_COLORS_HPP

// Hex values initialize the SQF constants in preInit.
#define LMF_PALETTE_BLUE_HEX "#45B5FF"
#define LMF_PALETTE_ORANGE_HEX "#FFB84D"
#define LMF_PALETTE_GREEN_HEX "#32DB44"
#define LMF_PALETTE_GRAY_HEX "#858585"
#define LMF_PALETTE_RED_HEX "#F2513C"
#define LMF_PALETTE_WHITE_HEX "#FFFFFF"

// RGBA components for CfgNotifications; braces belong to the consuming config.
#define LMF_PALETTE_ORANGE_RGBA 1,0.7215686275,0.3019607843,1
#define LMF_PALETTE_GREEN_RGBA 0.1960784314,0.8588235294,0.2666666667,1
#define LMF_PALETTE_RED_RGBA 0.9490196078,0.3176470588,0.2352941176,1
#define LMF_PALETTE_WHITE_RGBA 1,1,1,1

#endif
