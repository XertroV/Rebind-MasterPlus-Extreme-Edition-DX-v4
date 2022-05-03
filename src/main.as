// todo: it looks like `#IF DEVELOP` is possible; not sure how yet
const bool DEV_MODE = true;

// used to rate-limit game type log msgs
uint64 lastPrint = 0;

// This seems to be constant, but might not be
const uint GIVE_UP_ACTION_INDEX = 7;

const string PLUGIN_TITLE = "Never Give Up!";

string keyBoundToGiveUp;

string gameMode;
string lastGameMode;

// debug function for printing members of a MwClassInfo recursively
void _printMembers(const Reflection::MwClassInfo@ ty) {
   auto members = ty.Members;
   string extra;
   for (uint i = 0; i < members.Length; i++) {
      // extra = " (" + members[i].Members.Length + " children)";
      print("  " + members[i].Name + extra);
   }
   if (ty.BaseType !is null) {
      _printMembers(ty.BaseType);
   }
}


// debug function for sorta pretty-printing the members of anything that inherits from CMwNod
void printMembers(CMwNod@ nod) {
   if (nod is null) {
      warn(">>> Object of type: null <<<");
      return;
   }
   auto ty = Reflection::TypeOf(nod);
   auto name = ty.Name;
   print("\n>>> Object of type: " + name + " <<<");
   print("Members:");
   _printMembers(ty);
   print("");
}


void printNameAndType(string varName, CMwNod@ nod) {
   auto ty = Reflection::TypeOf(nod);
   print("VAR/TYPE: " + varName + " :: " + (ty is null ? "null" : ty.Name));
}




bool dGetBool(dictionary@d, string k) {
   bool ret;
   d.Get(k, ret);
   return ret;
}


const string _dictIndent = "  ";
string dict2str(dictionary@ dict) {
   auto ks = dict.GetKeys();
   string[] lines;
   for (uint i = 0; i < ks.Length; i++) {
      lines.InsertLast(_dictIndent + "{ '" + ks[i] + "', " + dGetBool(dict, ks[i]) + " }");
   }
   if (lines.Length == 0) {
      return "{ }";
   }
   auto body = string::Join(lines, "\n");
   return "{\n" + body + "\n}";
}




CTrackMania@ GetTmApp() {
   return cast<CTrackMania>(GetApp());
}


UnbindPrompt unbindPrompt;


void Main() {
   auto app = GetTmApp();
   startnew(LoopCheckBinding);
   CheckGiveUpBinding();

   // ! huh, apparently we don't need to instantiate it?
   // unbindPrompt = UnbindPrompt();

   while (unbindPrompt is null) {
      yield();
   }

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

   auto pg = cast<CSmArenaClient>(app.CurrentPlayground);
   printMembers(pg);
   // printNameAndType("app.CurrentPlayground", app.CurrentPlayground);
   // printNameAndType("app.MenuManager", app.MenuManager);
   while (pg is null) {
      yield();
   }
   printNameAndType("pg.Interface", pg.Interface);
   printMembers(pg.Interface);
   // print(pg.GameTerminals.Length);
   // printMembers(pg.GameTerminals[0]);
   // auto player = cast<CSmPlayer>(pg.GameTerminals[0].GUIPlayer);
   // printMembers(player);
   // printMembers(player.ScriptAPI);
   // auto _player = cast<CSmScriptPlayer>(player.ScriptAPI);
   // print(_player.Speed);
   // printMembers(pg.GameTerminals[0].ControlledPlayer);

   auto pgUiConfig = cast<CGamePlaygroundUIConfig>(pg.UIConfigs[0]);
   // pgUiConfig.SendChat("test123"); // does not work

   printNameAndType("app.Network", app.Network);
   auto network = cast<CTrackManiaNetwork>(app.Network);
   // auto network = app.Network;
   printMembers(network);
   auto appPg = network.ClientManiaAppPlayground;
   printMembers(appPg.Input);
   // auto rules = network.TmRaceRules;
   // printNameAndType("rules", rules);
   // print(rules.RespawnBehaviour);
}


void LoopCheckBinding() {
   while (true) {
      // CheckGiveUpBinding();
      sleep(1000);
   }
}


void CheckGiveUpBinding() {
   return;

   // exit early to disable this call
   auto app = GetTmApp();
   auto pad = app.InputPort.Script_Pads[1];
   auto _in = app.MenuManager.MenuCustom_CurrentManiaApp.Input;
   auto binding = _in.GetActionBinding(pad, "Vehicle", "GiveUp");
   if (binding != keyBoundToGiveUp) {
      keyBoundToGiveUp = binding;
      print("GiveUp binding: " + keyBoundToGiveUp);
   }
   print("GiveUp binding: " + keyBoundToGiveUp);
}



void OnSettingsChanged() {
   unbindPrompt.OnSettingsChanged();
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
   if (!Setting_RenderIfUiHidden) {
      _Render();
   }
}

void Render() {
   if (Setting_RenderIfUiHidden) {
      _Render();
   }
}


// This is disabled atm b/c of the bug with blocking input.
// Possible Solutions:
// - deal with it, if your respawning it's less of a problem
// - figure out how to call the unbind/rebind functions in TM2020: not exposed via any Nod (I think) so would need to be done via some `Dev::*` method :/.
//   - note: I've tried to do some reverse engineering of TM to find the function call but not much luck. I have found the reset counter and some stuff associated with the unbind dialog, tho.
// - just call the unbind / bind dialogs instead via a button click or something
// - just show a notification to the user when the a key is bound to "Give Up"
//   - this we can test easily via `app.MenuManager.MenuCustom_CurrentManiaApp.Input.GetActionBinding(pad, "Vehicle", "GiveUp");`
// Non-solutions:
// - there are some calls like `app.SystemOverlay.OpenInputSettings()` -- all the available ones I can find do one of:
//   - open the old settings interface (not the correct one for TM2020)
//   - crash the game
//   - nothing
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
         // print("Blocked give up!");
         // return UI::InputBlocking::Block;
         print("Attempting disallowing self respawn instead");
      }
   }

   // auto app = GetTmApp();
   // auto mm = cast<CTrackManiaMenus>(app.MenuManager);
   // auto pg = app.CurrentPlayground;
   // auto _interface = cast<CTrackManiaRaceInterface>(pg.Interface);
   // trace("checking interface" + (pg !is null) + (_interface !is null));
   // if (pg !is null && _interface !is null) {
   //    print("before, allowselfrespawn is: " + _interface.Race.AllowSelfRespawn);
   //    _interface.Race.AllowSelfRespawn = false;
   //    print("after, allowselfrespawn is: " + _interface.Race.AllowSelfRespawn);
   // }

   // crashes TM2020
   // mm.DialogQuickChooseGhostOpponents();

   // if (false) {

   //    // these do nothing
   //    // mm.DialogInputSettings_OnBindingsUnbindKey();
   //    // mm.MenuConfigureInputs_OnUnbindKey();

   //    // these are the same and have an easy to find 'unbind' button
   //    // mm.DialogInGameMenuAdvanced_OnInputSettings();
   //    // mm.DialogQuitRace_OnInputSettings();

   //    print('done');

   //    auto ila = mm.InputsList_Actions;

   //    for (uint i = 0; i < ila.Length; i++) {
   //       print("" + ila[i].StrInt1 + ": " + ila[i].StrInt2);
   //    }
   // }

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
   bool ret = false;

   if (app.CurrentPlayground !is null && !isWarmUp) {
      gameMode = server_info.CurGameModeStr;
      ret =
         ( false  // this `false` is just to make the below ORs line up nicely (for easy commenting)
         || (Setting_BlockDelCotd   && gameMode == "TM_KnockoutDaily_Online")
         || (Setting_BlockDelKO     && gameMode == "TM_Knockout_Online")
         || (Setting_BlockDelRanked && gameMode == "TM_Teams_Matchmaking_Online")
         || (gameMode == Settings_BlockDelCustom1)
         || (gameMode == Settings_BlockDelCustom2)
         || (gameMode == Settings_BlockDelCustom3)
         || ("*" == Settings_BlockDelCustom1)
         || ("*" == Settings_BlockDelCustom2)
         || ("*" == Settings_BlockDelCustom3)
         );
      if (lastGameMode != gameMode) {
         lastGameMode = gameMode;
         unbindPrompt.OnNewMode();
      }
   }

   /*
    ? Note: We might be able to get the game mode also via:
    ? - `ManiaPlanetScriptAPI.CurrentServerModeName`
    ? - `MenuManager.NetworkGameModeName`
    */

   // if (DEV_MODE) {
   //    // debug: print the current game mode for gathering relevant game modes
   //    // we don't want to fill up the logs with 1+ lines each frame, tho, so only print at most every so many seconds.
   //    uint64 now = Time::get_Now();
   //    if (now - lastPrint > 5000) {
   //       lastPrint = now;
   //       print("CurGameModeStr = " + server_info.CurGameModeStr);
   //    }
   // }

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
