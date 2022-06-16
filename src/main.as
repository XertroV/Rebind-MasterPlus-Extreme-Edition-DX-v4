const string PLUGIN_TITLE = "Quick Rebind";

void Main() {
#if TMNEXT
   auto app = GetTmApp();

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
