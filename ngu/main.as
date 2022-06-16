// todo: it looks like `#IF DEVELOP` is possible; not sure how yet
// ! update: define it in info.toml -- check other projects for examples
const bool DEV_MODE = true;

// used to rate-limit game type log msgs
uint64 lastPrint = 0;

// This seems to be constant, but might not be
// ! it's not for controllers
// const uint GIVE_UP_ACTION_INDEX = 7;
// const uint RESET_ACTION_INDEX = 8;
const string GIVE_UP_ACTION_NAME = "Give up";
const string RESPAWN_ACTION_NAME = "Respawn";
/* player inputs count = 15 for KB and 19 for GamePad */

const string PLUGIN_TITLE = "Never Give Up!";

string keyBoundToGiveUp;

string gameMode;
string lastGameMode;

bool isGiveUpBound;

string[] giveUpBindings;
string prevBindings = "";



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

bool InputBindingsInitialized() {
   auto mpsa = gi.GetManiaPlanetScriptApi();
   if (mpsa is null) return false;
   if (mpsa.InputBindings_Bindings.Length < 7) return false;
   return true;
}

uint GetActionIndex(const string &in actionName) {
   auto mpsa = gi.GetManiaPlanetScriptApi();
   for (uint i = 0; i < mpsa.InputBindings_ActionNames.Length; i++) {
      // debugPrint("mpsa.InputBindings_ActionNames[i]: " + mpsa.InputBindings_ActionNames[i]);
      if (string(mpsa.InputBindings_ActionNames[i]) == actionName)
         return i;
   }
   throw("Could not find action index for action name: " + actionName);
   return 0xffffff;
}

bool HasOkayPad() {
   auto pads = GetTmApp().InputPort.Script_Pads;
   for (uint i = 0; i < pads.Length; i++) {
      if (CheckPadOkaySettings(pads[i])) return true;
   }
   return false;
}

bool IsGiveUpBound() {
   // seems like this is somewhat problematic, so just use the other way that should be more robust.
   // return IsGiveUpBoundAux();
   auto app = GetTmApp();
   auto mpsa = gi.GetManiaPlanetScriptApi();
   if (!InputBindingsInitialized()) {
      return IsGiveUpBoundAux();
   }
   auto pads = app.InputPort.Script_Pads;
   giveUpBindings.RemoveRange(0, giveUpBindings.Length);
   for (uint i = 0; i < pads.Length; i++) {
      auto pad = pads[i];
      if (!CheckPadOkaySettings(pad)) continue;
      mpsa.InputBindings_UpdateList(CGameManiaPlanetScriptAPI::EInputsListFilter::All, pad);
      uint giveUpIx = GetActionIndex(GIVE_UP_ACTION_NAME);
      string currBindings = string(mpsa.InputBindings_Bindings[giveUpIx]);
      if (currBindings.Length > 0) {
         giveUpBindings.InsertLast(currBindings);
      }
   }
   if (giveUpBindings.Length > 0) {
      return true;
   }
   return IsGiveUpBoundAux(); // fallback
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
      if (!CheckPadOkaySettings(pad)) continue;
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
   return giveUpBindings.Length > 0;
}


bool CheckPadOkaySettings(CInputScriptPad@ pad) {
   // CInputScriptPad::EPadType
   if (Setting_PadType == PadType::Keyboard)
      return pad.Type == CInputScriptPad::EPadType::Keyboard;
   if (Setting_PadType == PadType::Mouse)
      return pad.Type == CInputScriptPad::EPadType::Mouse;
   if (Setting_PadType == PadType::GamePad)
      return pad.Type == CInputScriptPad::EPadType::Generic
         || pad.Type == CInputScriptPad::EPadType::XBox
         || pad.Type == CInputScriptPad::EPadType::PlayStation
         || pad.Type == CInputScriptPad::EPadType::Vive
         ;
   // if (Setting_PadType == PadType::AnyInputButMouse)
   //    return pad.Type != CInputScriptPad::EPadType::Mouse;
   // if Setting_PadType == AnyInputDevice then we'll return true anyway.
   return true;
}

// CInputScriptPad@ firstPadGUBound;
int firstPadGUBoundIx = -1;
CInputScriptPad@ GetPadWithGiveUpBound() {
      // todo check setting for controller
   auto app = GetTmApp();
   auto pads = app.InputPort.Script_Pads;
   auto _in = app.MenuManager.MenuCustom_CurrentManiaApp.Input;
   string binding;
   for (uint i = 0; i < pads.Length; i++) {
      auto pad = app.InputPort.Script_Pads[i];
      binding = _in.GetActionBinding(pad, "Vehicle", "GiveUp");
      if (binding != "" && CheckPadOkaySettings(pad)) {
         // @firstPadGUBound = pad;
         firstPadGUBoundIx = int(i);
         return pad;
      }
   }
   firstPadGUBoundIx = -1;
   return null;
}

CInputScriptPad@ GetFirstPadGiveUpBoundOrDefault() {
   // if (firstPadGUBound !is null) {
   //    return firstPadGUBound;
   // }
   auto app = GetTmApp();
   auto pads = app.InputPort.Script_Pads;
   if (firstPadGUBoundIx > 0 && firstPadGUBoundIx < int(pads.Length)) {
      auto pad = pads[firstPadGUBoundIx];
      if (CheckPadOkaySettings(pad))
         return pad;
   } else if (firstPadGUBoundIx > 0) {
      // we used to have a pad but don't anymore, so use the other function and re-cache.
      return GetPadWithGiveUpBound();
   }
   CInputScriptPad@ mouse;
   for (uint i = 0; i < pads.Length; i++) {
      // todo check setting for controller
      auto pad = app.InputPort.Script_Pads[i];
      // don't return the mouse first -- skip and return at end if no other pads
      if (pad.Type == CInputScriptPad::EPadType::Mouse) {
         @mouse = pad;
      } else if (CheckPadOkaySettings(pad)) {
         return pad;
      }
   }
   return mouse;
}



void OnSettingsChanged() {
   unbindPrompt.OnSettingsChanged();
   auto mpsa = gi.GetManiaPlanetScriptApi();
   if (mpsa !is null) {
      mpsa.InputBindings_UpdateList(CGameManiaPlanetScriptAPI::EInputsListFilter::All, GetFirstPadGiveUpBoundOrDefault());
   }
}

void RenderMenu() {
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
   Wizard::Render();
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

void debugPrint(const string &in msg) {
   print("\\$29f" + msg);
}
