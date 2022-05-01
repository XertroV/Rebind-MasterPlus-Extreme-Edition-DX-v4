// todo: it looks like `#IF DEVELOP` is possible; not sure how yet
const bool DEV_MODE = true;

// used to rate-limit game type log msgs
uint64 lastPrint = 0;

// This seems to be constant, but might not be
const uint GIVE_UP_ACTION_INDEX = 7;

const string PLUGIN_TITLE = "Never Give Up!";

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


CTrackMania@ GetTmApp() {
   return cast<CTrackMania>(GetApp());
}


UnbindPrompt unbindPrompt;


void Main() {
   auto app = GetTmApp();

   // ! huh, apparently we don't need to instantiate it?
   // unbindPrompt = UnbindPrompt();

   // while (true) {
   //    // auto pad = app.InputPort.Script_Pads[1];
   //    // auto _in = app.MenuManager.MenuCustom_CurrentManiaApp.Input;
   //    // auto dn = _in.GetActionDisplayName("Vehicle", "GiveUp");  // => "Give Up"
   //    // auto binding = _in.GetActionBinding(pad, "Vehicle", "GiveUp");  // => "Delete"
   //    // // print(tostring(binding));
   //    // // app.MenuManager.DialogInputSettings();
   //    // // app.MenuManager.MenuConfigureInputs();
   //    // // printMembers(app.MenuManager);
   //    // // app.MenuManager.MenuStatistics();
   //    // // app.MenuManager.MenuCampaignChallenges();
   //    // sleep(5000);
   //    yield();
   // }
}


void OnSettingsChanged() {
   // nothing to update
}

void RenderMenu() {
   // bool clickedMenu = UI::MenuItem("TestMenu");
   // if (clickedMenu) {
   //    print("clickedMenu = true");
   // }
   auto app = GetTmApp();
   auto mm = cast<CTrackManiaMenus>(app.MenuManager);
   // if (UI::MenuItem("MenuTest: Main")) {
   //    mm.MenuMain();
   // }
   // if (UI::MenuItem("MenuTest: Profile")) {
   //    mm.MenuProfile();
   // }
   // if (UI::MenuItem("MenuMultiPlayerNetworkCreate")) {
   //    mm.MenuMultiPlayerNetworkCreate();
   // }
   // if (UI::MenuItem("MenuHotSeatCreate")) {
   //    mm.MenuHotSeatCreate();
   // }
   // if (UI::MenuItem("MenuConfigureInputs")) {
   //    mm.MenuConfigureInputs();
   // }
   // if (UI::MenuItem("MenuProfileAdvanced")) {
   //    mm.MenuProfileAdvanced();
   // }
   // if (UI::MenuItem("MenuProfile_Launch")) {
   //    mm.MenuProfile_Launch();
   // }
   // if (UI::MenuItem("DialogChooseLeague")) {
   //    mm.DialogChooseLeague();
   // }

   if (unbindPrompt !is null) {
      unbindPrompt.RenderMenu();
   }
}


void _Render() {
   if (unbindPrompt !is null) {
      unbindPrompt.Draw();
   }
}

void RenderInterface() {
   _Render();
}

void Render() {
   // RenderInterface();
}


UI::InputBlocking OnKeyPress(bool down, VirtualKey key) {
   string actionMap = UI::CurrentActionMap();
   if (actionMap == "MenuInputsMap" || !Setting_Enabled) {
      return UI::InputBlocking::DoNothing;
   }

   // print("Key (" + key + ") " + (down ? "pressed" : "released"));

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

   auto app = GetTmApp();
   auto mm = cast<CTrackManiaMenus>(app.MenuManager);

   // crashes TM2020
   // mm.DialogQuickChooseGhostOpponents();

   if (false) {

      // these do nothing
      // mm.DialogInputSettings_OnBindingsUnbindKey();
      // mm.MenuConfigureInputs_OnUnbindKey();

      // these are the same and have an easy to find 'unbind' button
      // mm.DialogInGameMenuAdvanced_OnInputSettings();
      // mm.DialogQuitRace_OnInputSettings();

      print('done');

      auto ila = mm.InputsList_Actions;

      for (uint i = 0; i < ila.Length; i++) {
         print("" + ila[i].StrInt1 + ": " + ila[i].StrInt2);
      }
   }

   return UI::InputBlocking::DoNothing;
}


bool IsRankedOrCOTD() {
   // borrowed method for checking game mode from: https://github.com/chipsTM/tm-cotd-stats/blob/main/src/COTDStats.as
   auto app = cast<CTrackMania>(GetApp());
   auto network = cast<CTrackManiaNetwork>(app.Network);
   if (network is null) { return false; }
   auto server_info = cast<CTrackManiaNetworkServerInfo>(network.ServerInfo);
   if (server_info is null) { return false; }
   // auto player_info = network.PlayerInfo;
   // auto race_rules = network.TmRaceRules

   // UIConfigMgr_Rules.UiAll.SendChat -- works

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
      || ("*" == Settings_BlockDelCustom1)
      || ("*" == Settings_BlockDelCustom2)
      || ("*" == Settings_BlockDelCustom3)
      )
   );

   if (app.CurrentPlayground !is null) {
      // app.CurrentPlayground.Interface
   }

   /*
    ? Note: We might be able to get the game mode also via:
    ? - `ManiaPlanetScriptAPI.CurrentServerModeName`
    ? - `MenuManager.NetworkGameModeName`
    */

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
// TM_Champion_Online (not sure what this is)
// TM_Laps_Online
