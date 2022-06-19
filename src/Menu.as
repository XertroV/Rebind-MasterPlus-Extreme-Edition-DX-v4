namespace Menu {
    // const string MAIN_COLOR = "\\$4af";  // blue
    // const string MAIN_COLOR = "\\$92f";  // purple
    const string MAIN_COLOR = "\\$5f4";  // green
    const string L_GRAY = "\\$aaa";
    const vec4 L_GRAY_VEC = vec4(2,2,2,1) / vec4(3,3,3,1);

    int selectedPadIx = -1;
    bool _enabled = false;

    UI::Font@ fontSectionLabel = UI::LoadFont("fonts/Lato-MediumItalic.ttf", 16, -1, -1, true, true);
    UI::Font@ fontWarning = UI::LoadFont("fonts/Lato-BlackItalic.ttf", 30, -1, -1, true, true);

    array<string> bindings;
    array<string> actions;
    uint playerInputsCount;

    string grp(const string &in s) {
        return "\\$<" + s + "\\$>";
    }

    string mainColor(const string &in s) {
        return grp(MAIN_COLOR + s);
    }

    string UE(const string &in s) {
        if (Setting_UberExtremo) {
            return rainbowLoopColorCycle(s, true);
        } else {
            return s;
        }
    }

    const string GetIcon(CInputScriptPad@ pad = null) {
        PadType ty = pad !is null ? FromEPadType(pad.Type) : Setting_PadType;
        if (ty == PadType::Keyboard)
            return Icons::KeyboardO;
        if (ty == PadType::Mouse)
            return Icons::Kenney::MouseAlt;
        return Icons::Kenney::GamepadAlt;
    }
    string CurrIcon = GetIcon();

    void OnSettingsChanged() {
        CurrIcon = GetIcon();
        selectedPadIx = GetPreferredPadIx();
        // if we don't have a suitable pad then remove all the bindings until a new device is selected.
        if (selectedPadIx < 0) {
            for (uint i = 0; i < bindings.Length; i++) {
                bindings[i] = '';
            }
        }
    }

    /********/

    void RenderPluginMenuItem() {
        if (UI::MenuItem(mainColor(CurrIcon) + " Rebind Master+ Extreme Edition DX v4", "", Setting_Enabled)) {
            Setting_Enabled = !Setting_Enabled;
        }
    }

    /********/

    const string MenuL_Bindings = " Bindings";

    void RenderMenuMain() {
        _enabled = IsUiDialogSafe();
        if (!Setting_Enabled) return;
        UI::PushStyleColor(UI::Col::TextDisabled, L_GRAY_VEC);
        auto menuLabel = !Setting_UberExtremo ? MenuL_Bindings : MenuL_Bindings.ToUpper();
        bool menuOpen = UI::BeginMenu(mainColor(CurrIcon) + menuLabel, _enabled);
        if (!_enabled) {
            //if the disabled menubar menuitem is hovered. Hover logic handled by AddSimpleTooltip -- however, IsItemHovered doesn't work on disabled items??!
            AddSimpleTooltip("\\$f62" + "Sorry, it's unsafe to bind keys right now.");
        }
        if (_enabled && Setting_UberExtremo) {
            UI::PushFont(fontWarning);
            AddSimpleTooltip("Last warning...");
            UI::PopFont();
        }
        if (menuOpen) {
            if (UI::IsWindowAppearing()) {
                trace("appearing. selected pad ix: " + selectedPadIx);
                OnWindowAppearing();
            }
            if (UI::BeginTable("bindings-menu-table", 2)) {
                UI::TableSetupColumn("l", UI::TableColumnFlags::WidthFixed, 300);
                UI::TableSetupColumn("r", UI::TableColumnFlags::WidthFixed, 300);

                UI::TableNextRow();

                UI::TableNextColumn();
                // MenuMinWidth();
                MenuLabelSep("Selected Input", true);
                ListInputDevices();
                MenuLabelSep("Device", true);
                ListDeviceSettings();
                MenuLabelSep("Player Bindings", true);
                ListPlayerBindings();

                UI::TableNextColumn();
                // MenuMinWidth();
                MenuLabelSep("Other Bindings", true);
                ListOtherBindings();

                UI::EndTable();
            }

            UI::EndMenu();
        } else {
            string newi = GetIcon(GetCurrPad());
            if (newi != CurrIcon)
                CurrIcon = newi;
        }

        UI::PopStyleColor(1);
        // UI::PopFont();
    }

    void OnWindowAppearing() {
        if (selectedPadIx < 0 || selectedPadIx >= int(GetPads().Length)) {
            selectedPadIx = GetPreferredPadIx();
        }
        RecachePadBindings(GetCurrPad());
    }

    /********/

    void MenuLabelSep(const string &in l, bool padAbove = false) {
        if (padAbove) UI::Dummy(vec2(0, 0));
        UI::PushFont(fontSectionLabel);
        UI::TextDisabled("  " + l + "  ");
        UI::Separator();
        UI::PopFont();
    }

    void MenuMinWidth() {
        vec2 initPos = UI::GetCursorPos();
        UI::Dummy(vec2(150, 1));  // setting min width basically
        UI::SetCursorPos(initPos);
    }

    void ListInputDevices() {
        auto pads = GetPads();

        // reset if a controller is removed
        if (selectedPadIx >= int(pads.Length))
            selectedPadIx = -1;

        for (uint i = 0; i < pads.Length; i++) {
            auto pad = pads[i];

            // default to keyboard
            if (selectedPadIx < 0 && FromEPadType(pad.Type) == Setting_PadType) {
                OnSelectedPad(i);
            }
            string padName = "^ " + pad.ModelName;
            if (MenuItemNoClose(UE(padName).Replace("^", GetIcon(pad)), UE(''), int(i) == selectedPadIx)) {
                OnSelectedPad(i);
            }
        }
    }

    void OnSelectedPad(int ix) {
        selectedPadIx = ix;
        auto pad = GetPad(ix);
        Setting_PadType = FromEPadType(pad.Type);
        RecachePadBindings(pad);
    }

    void RecachePadBindings(CInputScriptPad@ pad) {
        if (pad is null) {
            warn("Not recaching pad bindings b/c pad is null.");
            return;
        }
        trace("Caching Pad Bindings.");
        auto mspa = GI::GetManiaPlanetScriptApi();
        mspa.InputBindings_UpdateList(CGameManiaPlanetScriptAPI::EInputsListFilter::All, pad);
        bindings.RemoveRange(0, bindings.Length);
        actions.RemoveRange(0, actions.Length);
        auto b = mspa.InputBindings_Bindings;
        auto a = mspa.InputBindings_ActionNames;
        for (uint i = 0; i < b.Length; i++) {
            bindings.InsertLast(string(b[i]));
            actions.InsertLast(string(a[i]));
        }
        playerInputsCount = GetPlayerInputsCount();
    }



    CInputScriptPad@ GetPad(uint i) {
        auto pads = GetPads();
        if (i >= pads.Length)
            return null;
        return pads[i];
    }

    CInputScriptPad@ GetCurrPad() {
        return GetPad(selectedPadIx);
    }

    MwFastBuffer<CInputScriptPad@> GetPads() {
        return GI::GetInputPort().Script_Pads;
    }

    int GetPreferredPadIx() {
        auto pads = GetPads();
        auto preferredType = Setting_PadType;
        for (uint i = 0; i < pads.Length; i++) {
            if (FromEPadType(pads[i].Type) == preferredType) {
                return i;
            }
        }
        return -1;
    }

    void ListDeviceSettings() {
        if (UI::MenuItem(UE("Unbind one button"), UE("Ctrl+U"), false, _enabled)) {
            GI::UnbindInput(GetPad(selectedPadIx));
        }
    }

    uint GetPlayerInputsCount() {
        return GI::GetManiaPlanetScriptApi().InputBindings_PlayerInputsCount;
    }

    void ListPlayerBindings() {
        ListBindingsFrom(0, playerInputsCount);
    }

    void ListOtherBindings() {
        ListBindingsFrom(playerInputsCount, 0xffff);
    }

    void ListBindingsFrom(uint start, uint length) {
        for (uint i = start; i < uint(Math::Min(start + length, bindings.Length)); i++) {
            if (UI::MenuItem(UE(actions[i]), UE(bindings[i]), false, _enabled)) {
                debugPrint("Clicked: " + actions[i]);
                GI::BindInput(i, GetCurrPad());
            }
        }
    }
}
