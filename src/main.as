[Setting name="Enabled?"]
bool Setting_Enabled = true;

[Setting name="Key to block for 'Give up'"]
VirtualKey Setting_KeyGiveUp = VirtualKey::Delete;

[Setting name="Block 'Give up' in COTD"]
bool Setting_BlockDelCotd = true;

[Setting name="Block 'Give up' in Ranked"]
bool Setting_BlockDelRanked = true;

[Setting name="Block 'Give up' in Knockout"]
bool Setting_BlockDelKO = true;

[Setting name="Block 'Give up' in Custom Mode 1 (e.g., 'TM_Cup_Online') -- blank for none."]
string Settings_BlockDelCustom1 = "";

[Setting name="Block 'Give up' in Custom Mode 2 (e.g., 'TM_Cup_Online') -- blank for none."]
string Settings_BlockDelCustom2 = "";

[Setting name="Block 'Give up' in Custom Mode 3 (e.g., 'TM_Cup_Online') -- blank for none."]
string Settings_BlockDelCustom3 = "";


uint64 lastPrint = 0;


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

   if (down) {
      // todo: handle an override key
      //   0. set override key to 'up' on map load
      //   1. track override key up/down status
      //   2. check if override key is down when Delete is pressed

      bool appropriateMatch = IsRankedOrCOTD();

      if (key == Setting_KeyGiveUp && appropriateMatch) {
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
   bool isWarmUp = server_info.IsWarmUp;

   bool ret = (app.CurrentPlayground !is null && !isWarmUp &&
      ( false  // this `false` is just to make the below ORs line up nicely (for easy commenting)
      || (Setting_BlockDelCotd   && server_info.CurGameModeStr == "TM_KnockoutDaily_Online")
      || (Setting_BlockDelKO     && server_info.CurGameModeStr == "TM_Knockout_Online")
      || (Setting_BlockDelRanked && server_info.CurGameModeStr == "TM_Teams_Matchmaking_Online")
      )
   );

   if (DEV_MODE) {
      // debug: print the current game mode for gathering relevant game modes
      // we don't want to fill up the logs with 1+ lines each frame, tho, so only print at most every so many seconds.
      uint64 now = Time::get_Now();
      if (now - lastPrint > 5000) {
         lastPrint = now;
         print("CurGameModeStr = " + server_info.CurGameModeStr);
         print("isWarmUp = " + isWarmUp);
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

// ? not sure about whether to enable/disable for these
// TM_Cup_Online -- "cup" game format on server
// Champion (mb TM_Champion_Online) -- a guess
// TM_Teams_Online -- a guess (like ranked but ad-hoc?)
