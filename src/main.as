[Setting name="Enabled?"]
bool Setting_Enabled = true;

[Setting name="Key to block for 'Give up'"]
VirtualKey Setting_KeyGiveUp = VirtualKey::Delete;

[Setting name="Block 'Give up' in COTD (TM_KnockoutDaily_Online)"]
bool Setting_BlockDelCotd = true;

[Setting name="Block 'Give up' in Ranked (TM_Teams_Matchmaking_Online)"]
bool Setting_BlockDelRanked = true;

[Setting name="Block 'Give up' in Knockout (TM_Knockout_Online)"]
bool Setting_BlockDelKO = true;

// // todo: implementation for the below
// [Setting category="Custom Modes" name="Block 'Give up' in Custom Mode 1 -- blank for none."]
// string Settings_BlockDelCustom1 = "";

// [Setting category="Custom Modes" name="Block 'Give up' in Custom Mode 2 -- blank for none."]
// string Settings_BlockDelCustom2 = "";

// [Setting category="Custom Modes" name="Block 'Give up' in Custom Mode 3 -- blank for none."]
// string Settings_BlockDelCustom3 = "";



// used to rate-limit game type log msgs
uint64 lastPrint = 0;


// todo: it looks like `#IF DEVELOP` is possible; not sure how yet
const bool DEV_MODE = true;


// debug function for printing members of a MwClassInfo recursively
void _printMembers(const Reflection::MwClassInfo@ ty) {
   auto members = ty.Members;
   for (uint i = 0; i < members.Length; i++) {
      print("  " + members[i].Name);
   }
   if (ty.BaseType !is null) {
      _printMembers(ty.BaseType);
   }
}


// debug function for sorta pretty-printing the members of anything that inherits from CMwNod
void printMembers(CMwNod@ nod) {
   auto ty = Reflection::TypeOf(nod);
   auto name = ty.Name;
   print("\n>>> Object of type: " + name + " <<<");
   print("Members:");
   _printMembers(ty);
   print("");
}


void Main() {
   // nothing to do on init
}


void OnSettingsChanged() {
   // nothing to update
}


void RenderMenu() {
   // bool clickedMenu = UI::MenuItem("TestMenu");
   // if (clickedMenu) {
   //    print("clickedMenu = true");
   // }
}


UI::InputBlocking OnKeyPress(bool down, VirtualKey key) {
   string actionMap = UI::CurrentActionMap();
   if (actionMap == "MenuInputsMap" || !Setting_Enabled) {
      return UI::InputBlocking::DoNothing;
   }

   print("Key (" + key + ") " + (down ? "pressed" : "released"));

   if (true || down) {
      // todo: handle an override key
      //   0. set override key to 'up' on map load
      //   1. track override key up/down status
      //   2. check if override key is down when Delete is pressed

      bool appropriateMatch = IsRankedOrCOTD();

      // note: whether we check for down or not doesn't seem to matter

      if (down && key == Setting_KeyGiveUp && appropriateMatch) {
         print("Blocked give up!");
         return UI::InputBlocking::Block;
      }
   }

   return UI::InputBlocking::DoNothing;
}


bool IsRankedOrCOTD() {
   // borrowed method for checking game mode from: https://github.com/chipsTM/tm-cotd-stats/blob/main/src/COTDStats.as
   auto app = cast<CTrackMania>(GetApp());
   auto network = cast<CTrackManiaNetwork>(app.Network);
   auto server_info = cast<CTrackManiaNetworkServerInfo>(network.ServerInfo);

   // we want to allow resets when in the warm-up phase.
   // note: This seems to always be false in TM_KnockoutDaily_Online
   // bool isWarmUp = server_info.IsWarmUp;
   const bool isWarmUp = false;

   bool ret = (app.CurrentPlayground !is null && !isWarmUp &&
      ( false  // this `false` is just to make the below ORs line up nicely (for easy commenting)
      || (Setting_BlockDelCotd   && server_info.CurGameModeStr == "TM_KnockoutDaily_Online")
      || (Setting_BlockDelKO     && server_info.CurGameModeStr == "TM_Knockout_Online")
      || (Setting_BlockDelRanked && server_info.CurGameModeStr == "TM_Teams_Matchmaking_Online")
      || (server_info.CurGameModeStr == Settings_BlockDelCustom1)
      || (server_info.CurGameModeStr == Settings_BlockDelCustom2)
      || (server_info.CurGameModeStr == Settings_BlockDelCustom3)
      )
   );

   if (DEV_MODE) {
      // debug: print the current game mode for gathering relevant game modes
      // we don't want to fill up the logs with 1+ lines each frame, tho, so only print at most every so many seconds.
      uint64 now = Time::get_Now();
      if (now - lastPrint > 5000) {
         lastPrint = now;
         print("CurGameModeStr = " + server_info.CurGameModeStr);
      }
   }

   return ret;
}


// TM_TimeAttackDaily_Online -- COTD during qualifier (we want to allow 'give up' here)
// TM_KnockoutDaily_Online -- COTD during KO
// TM_Knockout_Online -- Server knockout mode
// TM_Teams_Matchmaking_Online -- Ranked

// * don't do these ones

// TM_Royal_Online -- royal during Super Royal qualis; Super Royal Finals; (?? normally, too ??)
// TM_Campaign_Local -- local campaign, local TOTD

// ? not sure about whether to enable/disable for these -- can be added as custom tho
// TM_Cup_Online -- "cup" game format on server
// Champion (mb TM_Champion_Online) -- a guess -- not sure if this even exists
// TM_Teams_Online -- teams, first points to 100 by default
// TM_Rounds_Online
// TM_TimeAttack_Online
