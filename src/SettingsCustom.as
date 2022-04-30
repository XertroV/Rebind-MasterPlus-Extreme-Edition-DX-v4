const uint N_CUSTOM_FIELDS = 3;

// todo: implementation for the below

[Setting hidden]
string Settings_BlockDelCustom1 = "";
[Setting hidden]
string Settings_BlockDelCustom2 = "";
[Setting hidden]
string Settings_BlockDelCustom3 = "";

string[] Settings_BlockDelCustoms; // [Settings_BlockDelCustom1, Settings_BlockDelCustom2, Settings_BlockDelCustom3];

void RenderSettingsCustomGameModes() {
    if (UI::IsWindowAppearing()) {
        // init code
        Settings_BlockDelCustoms.InsertAt(0, Settings_BlockDelCustom1);
        Settings_BlockDelCustoms.InsertAt(1, Settings_BlockDelCustom2);
        Settings_BlockDelCustoms.InsertAt(2, Settings_BlockDelCustom3);
    }
    Settings_BlockDelCustoms.RemoveRange(0, Settings_BlockDelCustoms.Length);
    Settings_BlockDelCustoms.InsertLast(Settings_BlockDelCustom1);
    Settings_BlockDelCustoms.InsertLast(Settings_BlockDelCustom2);
    Settings_BlockDelCustoms.InsertLast(Settings_BlockDelCustom3);

    bool changed = false;
    string newVal = "";
    for (uint i = 0; i < N_CUSTOM_FIELDS; i++) {
        UI::Text("Custom Mode " + (i+1) + " to block 'Give up' in (empty for none)");
        // UI::LabelText goes in the RHS column (values are in the LHS column)
        // UI::LabelText("Custom Mode " + (i+1) + " to block 'Give up' in (empty for none)", Settings_BlockDelCustoms[i]);
        newVal = UI::InputText("Custom Mode " + (i+1), Settings_BlockDelCustoms[i], changed);
        Settings_BlockDelCustoms[i] = newVal;
    }

    Settings_BlockDelCustom1 = Settings_BlockDelCustoms[0];
    Settings_BlockDelCustom2 = Settings_BlockDelCustoms[1];
    Settings_BlockDelCustom3 = Settings_BlockDelCustoms[2];
}


[SettingsTab name="Custom Modes"]
void RenderSettingsCustomModesTab() {
    Settings_BlockDelCustoms.InsertAt(0, Settings_BlockDelCustom1);
    Settings_BlockDelCustoms.InsertAt(1, Settings_BlockDelCustom2);
    Settings_BlockDelCustoms.InsertAt(2, Settings_BlockDelCustom3);

    UI::TextWrapped(
        "Add custom game modes to block 'Give up'."
        // "Known game modes: TM_Cup_Online, TM_Teams_Online, TM_Rounds_Online, TM_TimeAttack_Online, TM_Royal_Online, or TM_Campaign_Local. "
    );

    RenderSettingsCustomGameModes();

    UI::TextWrapped(
        "Known game modes:\n"
        "- TM_Cup_Online\n"
        "- TM_Teams_Online\n"
        "- TM_Rounds_Online\n"
        "- TM_TimeAttack_Online\n"
        "- TM_Royal_Online\n"
        "- TM_Campaign_Local\n"
        "- TM_TimeAttackDaily_Online (COTD qualifier)\n"
        "- TM_KnockoutDaily_Online (COTD KO rounds)\n"
        "- TM_Knockout_Online (KO Tournament)\n"
        "- TM_Teams_Matchmaking_Online (Ranked)\n"
    );
}
