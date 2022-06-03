// todo: it looks like `#IF DEVELOP` is possible; not sure how yet
// ! update: define it in info.toml -- check other projects for examples
const bool DEV_MODE = true;

// used to rate-limit game type log msgs
uint64 lastPrint = 0;

// This seems to be constant, but might not be
const uint GIVE_UP_ACTION_INDEX = 7;
const uint RESET_ACTION_INDEX = 8;

const string PLUGIN_TITLE = "Never Give Up!";

string keyBoundToGiveUp;

string gameMode;
string lastGameMode;

bool isGiveUpBound;

string[] giveUpBindings;
string prevBindings = "";

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


string array2str(string[] arr) {
   string[] lines;
   for (uint i = 0; i < arr.Length; i++) {
      lines.InsertLast("'" + arr[i] + "'");
   }
   if (lines.Length == 0) {
      return "[ ]";
   }
   return "[" + string::Join(lines, ", ") + "]";
}



CTrackMania@ GetTmApp() {
   return cast<CTrackMania>(GetApp());
}


UnbindPrompt unbindPrompt = UnbindPrompt();


void Main() {
#if TMNEXT
   auto app = GetTmApp();
   startnew(LoopCheckBinding);
   IsGiveUpBound();

   while (unbindPrompt is null) {
      yield();
   }

#if DEV
   DebugPrintBindings();
#endif

   auto pg = cast<CSmArenaClient>(app.CurrentPlayground);
   while (pg is null) {
      yield();
   }

#else
   warn("Never Give Up is only compatible with TM2020. It doesn't do anything in other games.");
#endif
}


void LoopCheckBinding() {
   while (true) {
      isGiveUpBound = IsGiveUpBound();
      sleep(60); // ~16.7x per second at most
   }
}

bool IsGiveUpBound() {
   string currBindings = string(GameInfo().GetManiaPlanetScriptApi().InputBindings_Bindings[7]);
   giveUpBindings.RemoveRange(0, giveUpBindings.Length);
   if (currBindings.Length > 0) {
      giveUpBindings.InsertLast(currBindings);
      return true;
   }
   return false;
}

// hmm, this doesn't work in menus -- mb b/c GetActionBinding checks "Vehicle"?
bool IsGiveUpBoundAux() {
   auto app = GetTmApp();
   auto pads = app.InputPort.Script_Pads;
   auto _in = app.MenuManager.MenuCustom_CurrentManiaApp.Input;
   string binding;
   giveUpBindings.RemoveRange(0, giveUpBindings.Length);
   // auto curAM = UI::CurrentActionMap();
   CInputScriptPad@ firstPad;
   for (uint i = 0; i < pads.Length; i++) {
      auto pad = app.InputPort.Script_Pads[i];
      binding = _in.GetActionBinding(pad, "Vehicle", "GiveUp");
      if (binding != "") {
         giveUpBindings.InsertLast(binding);
         if (firstPad !is null) {
            @firstPad = pad;
         }
      }
   }
   binding = array2str(giveUpBindings);
   if (prevBindings != binding) {
      trace("GiveUp bindings: " + binding);
      prevBindings = binding;
   }
   if (giveUpBindings.Length == 0) {
      return false;
   }
   return true;
}

CInputScriptPad@ firstPadGUBound;
CInputScriptPad@ GetPadWithGiveUpBound() {
   auto app = GetTmApp();
   auto pads = app.InputPort.Script_Pads;
   auto _in = app.MenuManager.MenuCustom_CurrentManiaApp.Input;
   string binding;
   for (uint i = 0; i < pads.Length; i++) {
      auto pad = app.InputPort.Script_Pads[i];
      binding = _in.GetActionBinding(pad, "Vehicle", "GiveUp");
      if (binding != "") {
         @firstPadGUBound = pad;
         return pad;
      }
   }
   return null;
}

CInputScriptPad@ GetFirstPadGiveUpBoundOrDefault() {
   if (firstPadGUBound !is null) {
      return firstPadGUBound;
   }
   auto app = GetTmApp();
   auto pads = app.InputPort.Script_Pads;
   for (uint i = 0; i < pads.Length; i++) {
      auto pad = app.InputPort.Script_Pads[i];
      if (pad.Type != CInputScriptPad::EPadType::Mouse) {
         return pad;
      }
   }
   return null;
}



void OnSettingsChanged() {
   unbindPrompt.OnSettingsChanged();
}

void RenderMenu() {
   auto app = GetTmApp();
   auto mm = cast<CTrackManiaMenus>(app.MenuManager);
   unbindPrompt.RenderMenu();
}


void _Render() {
   unbindPrompt.Draw();
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
   return UI::InputBlocking::DoNothing;
   /*
   string actionMap = UI::CurrentActionMap();
   // if (actionMap == "MenuInputsMap" || !Setting_Enabled) {
   if (actionMap != "Vehicle" || !Setting_Enabled) {
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
         // print("Blocked give up!");
         // return UI::InputBlocking::Block;
         print("Attempting disallowing self respawn instead");
      }
   }
   return UI::InputBlocking::DoNothing;
   */
}


CTrackManiaNetwork@ getNetwork() {
   return cast<CTrackManiaNetwork>(GetTmApp().Network);
}

CTrackManiaNetworkServerInfo@ getServerInfo() {
   return cast<CTrackManiaNetworkServerInfo>(getNetwork().ServerInfo);
}


bool IsRankedOrCOTD() {
   // borrowed method for checking game mode from: https://github.com/chipsTM/tm-cotd-stats/blob/main/src/COTDStats.as
   auto app = cast<CTrackMania>(GetApp());
   auto network = cast<CTrackManiaNetwork>(app.Network);
   if (network is null) { return false; }
   auto server_info = cast<CTrackManiaNetworkServerInfo>(network.ServerInfo);
   if (server_info is null) { return false; }

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

void DebugPrintBindings() {
   print("\\$29f" + 'Bindings:');
   MwFastBuffer<wstring> bs = GameInfo().GetManiaPlanetScriptApi().InputBindings_Bindings;
   MwFastBuffer<wstring> as = GameInfo().GetManiaPlanetScriptApi().InputBindings_ActionNames;
   for (uint i = 0; i < bs.Length; i++) {
      print("  \\$39f" + string(as[i]) + ": " + string(bs[i]));
   }
}
