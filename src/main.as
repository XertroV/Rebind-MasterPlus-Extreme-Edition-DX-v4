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


uint64 lastPrint = 0;


void _printMembers(const Reflection::MwClassInfo@ ty) {
   auto members = ty.Members;
   for (uint i = 0; i < members.Length; i++) {
      print("  " + members[i].Name);
   }
   if (ty.BaseType !is null) {
      _printMembers(ty.BaseType);
   }
}


void printMembers(CMwNod@ nod) {
   auto ty = Reflection::TypeOf(nod);
   auto name = ty.Name;
   print("\n>>> Object of type: " + name + " <<<");
   print("Members:");
   _printMembers(ty);
   print("");
}

// void printMembers(CMwNod@ nod) {
//    auto ty = Reflection::TypeOf(nod);
//    auto members = ty.Members;
//    auto name = ty.Name;
//    print("\n>>> Object of type: " + name + " <<<");
//    print("Members:");
//    for (uint i = 0; i < members.Length; i++) {
//       print("  " + members[i].Name);
//    }
//    if (ty.BaseType !is null) {
//       printMembers(ty.BaseType);
//    }
//    print("");
// }


CInputScriptPad@ GetKeyboardInput() {
   auto ip = GetApp().InputPort;
   auto pads = ip.Script_Pads;
   for (uint i = 0; i < pads.Length; i++) {
      auto pad = pads[i];
      if (pad.Type == CInputScriptPad::EPadType::Keyboard) {
         return pad;
      }
   }
   return null;
}


void Main()
{
   // // CGameCtnApp@ app = GetApp();
   // // CTrackMania@ tmApp = cast<CTrackMania>(GetApp());
   // // auto app = tmApp;
   // // auto audioPort = app.AudioPort;

   // // for (uint i = 0; i < audioPort.Sources.Length; i++) {
   // //    auto source = audioPort.Sources[i];
   // //    auto sound = source.PlugSound;

   // //    if (cast<CPlugFileOggVorbis>(sound.PlugFile) is null) {
   // //       continue;
   // //    } else {
   // //       // we found an ogg file
   // //       float pitch = Setting_SlowerMusic ? 0.01 : 1.7;
   // //       source.Pitch = pitch;
   // //    }
   // // }

   // CTrackMania@ app = cast<CTrackMania>(GetApp());

   // // printMembers(app);
   // // printMembers(app.LoadedCore);
   // // printMembers(app.ManiaPlanetScriptAPI);
   // // printMembers(app.ManiaPlanetScriptAPI.UserMgr);
   // // if (app.ManiaPlanetScriptAPI.UserMgr !is null) {
   // //    print(app.ManiaPlanetScriptAPI.UserMgr is null);
   // //    print(app.ManiaPlanetScriptAPI.LoadedTitle is null);
   // //    print(app.ManiaPlanetScriptAPI.UserMgr.MainUserPad is null);
   // //    print(app.ManiaPlanetScriptAPI.UserMgr.MainUserProfile is null);
   // // }
   // // printMembers(app.PlaygroundScript);
   // // printMembers(app.PlaygroundScript.Input);
   // printMembers(app.InputPort);
   // print(">> " + app.InputPort.InputsMode);
   // print(">> " + app.InputPort.CurrentActionMap);
   // // printMembers(app.CurrentProfile);

   // // for (uint i = 0; i < app.MenuManager.InputsList_Actions.Length; i++) {
   // //    print(tostring(app.MenuManager.InputsList_Actions[i]));
   // // }

   // uint giveUpActionId;

   // auto bindings = app.ManiaPlanetScriptAPI.InputBindings_Bindings;
   // auto names = app.ManiaPlanetScriptAPI.InputBindings_ActionNames;
   // for (uint i = 0; i < bindings.Length; i++) {
   //    print(names[i] + ": " + bindings[i]);
   //    if (names[i] == "Give up") {
   //       // bindings[i] = "";
   //       giveUpActionId = i;
   //       break;
   //       // app.ManiaPlanetScriptAPI.Update_InputBinding();
   //    }
   // }

   // print("Give up action id: " + giveUpActionId);

   // // print(keeb.CurrentActionMap);
   // // printMembers(keeb);
   // // print("> " + input.GetActionBinding(keeb, "Vehicle", "give_up"));



   // // while (!UpdatePitch()) {
   // //    yield();
   // // }
}

// void Unbind

void OnSettingsChanged() {
   // UpdatePitch();
}

// bool UpdatePitch() {
//    auto audioPort = GetApp().AudioPort;
//    bool updated = false;

//    for (uint i = 0; i < audioPort.Sources.Length; i++) {
//       auto source = audioPort.Sources[i];
//       auto sound = source.PlugSound;

//       if (cast<CPlugFileOggVorbis>(sound.PlugFile) is null) {
//          continue;
//       } else {
//          // we found an ogg file
//          float pitch = Setting_SlowerMusic ? 0.01 : 1.7;
//          source.Pitch = pitch;
//          updated = true;
//       }
//    }

//    return updated;
// }

void RenderMenu() {
   bool clickedMenu = UI::MenuItem("TestMenu");
   if (clickedMenu) {
      print("clickedMenu = true");
   }
}


UI::InputBlocking OnKeyPress(bool down, VirtualKey key) {
   string actionMap = UI::CurrentActionMap();
   if (actionMap == "MenuInputsMap" || !Setting_Enabled) {
      return UI::InputBlocking::DoNothing;
   }

   bool appropriateMatch = IsRankedOrCOTD();

   if (down) {
      if (key == Setting_KeyGiveUp && appropriateMatch) {
         print("Blocked give up!");
         return UI::InputBlocking::Block;
      }
   }

   return UI::InputBlocking::DoNothing;
}


bool IsRankedOrCOTD() {
   // https://github.com/chipsTM/tm-cotd-stats/blob/main/src/COTDStats.as
   auto app = cast<CTrackMania>(GetApp());
   auto network = cast<CTrackManiaNetwork>(app.Network);
   auto server_info = cast<CTrackManiaNetworkServerInfo>(network.ServerInfo);

   // print("CurGameModeStr = " + server_info.CurGameModeStr);

   // we want to allow resets when in the warm-up phase.
   bool isWarmUp = server_info.IsWarmUp;

   bool ret = (app.CurrentPlayground !is null && !isWarmUp &&
      ( false  // this `false` is just to make the below ORs line up nicely (for easy commenting)
      || (Setting_BlockDelCotd   && server_info.CurGameModeStr == "TM_KnockoutDaily_Online")
      || (Setting_BlockDelKO     && server_info.CurGameModeStr == "TM_Knockout_Online")
      || (Setting_BlockDelRanked && server_info.CurGameModeStr == "TM_Teams_Matchmaking_Online")
      )
   );

   uint64 now = Time::get_Now();
   if (now - lastPrint > 5000) {
      lastPrint = now;
      print("CurGameModeStr = " + server_info.CurGameModeStr);
   }

   return ret;
}


// actually don't want TM_TimeAttackDaily_Online -- that's quali I think


// TM_Cup_Online -- "cup" game format on server
// TM_Knockout_Online
