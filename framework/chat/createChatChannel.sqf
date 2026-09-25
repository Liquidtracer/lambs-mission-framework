/*
    Framework chat channel
    Creates the chat channel; included in the server section of XEH_postInit.sqf.
*/

lmf_chatChannel = radioChannelCreate [[0.9,0.1,0.1,1], "Chat", "Chat", [], true];
publicVariable "lmf_chatChannel";

