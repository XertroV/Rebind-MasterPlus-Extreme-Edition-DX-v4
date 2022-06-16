const string PLUGIN_TITLE = "Rebind Master+ Extreme Edition DX v4";

void Main() {
#if TMNEXT
   startnew(AsyncLoop_AbortBindingDialogsWhenDangerous);

#if DEV
   DebugPrintBindings();
#endif

// not TMNEXT
#else
   warn(PLUGIN_TITLE + " is only compatible with TM2020. It doesn't do anything in other games.");
#endif
}

void OnSettingsChanged() {
}

void RenderMenu() {
   Menu::RenderPluginMenuItem();
}

void _Render() {
}

void RenderInterface() {
}

void Render() {
   Wizard::Render();
}

void RenderMenuMain() {
   Menu::RenderMenuMain();
}

void DebugPrintBindings() {
   debugPrint('Bindings:');
   MwFastBuffer<wstring> bs = GI::GetManiaPlanetScriptApi().InputBindings_Bindings;
   MwFastBuffer<wstring> as = GI::GetManiaPlanetScriptApi().InputBindings_ActionNames;
   for (uint i = 0; i < bs.Length; i++) {
      debugPrint(" > " + string(as[i]) + ": " + string(bs[i]));
   }
}

void debugPrint(const string &in msg) {
   print("\\$1cf" + msg);
}

bool ctrlDown = false;
void OnKeyPress(bool down, VirtualKey key) {
   if (key == VirtualKey::Control) {
      ctrlDown = down;
   } else if (ctrlDown && key == VirtualKey::U && down) {
      if (IsUiDialogSafe()) {
         GI::UnbindInput(Menu::GetPad(Menu::selectedPadIx));
      } else {
         UI::ShowNotification("Not safe to unbind!", "Ignored Ctrl+U because it is not safe to launch an unbind dialog right now.",
            vec4(1.0, .4, .1, 1));
      }
   }
}
