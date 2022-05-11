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
        UI::Text("Custom Mode " + (i+1) + " to block 'Give up' in (empty for none; '*' for any)");
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
        "Add custom game modes to block 'Give up'.\n"
        "'*'' is a special value: if any of these modes are just '*', then all game modes will be matched.\n"
        // "Known game modes: TM_Cup_Online, TM_Teams_Online, TM_Rounds_Online, TM_TimeAttack_Online, TM_Royal_Online, or TM_Campaign_Local. "
    );

    UI::Separator();

    RenderSettingsCustomGameModes();

    UI::Separator();

    UI::TextWrapped(
        "Known game modes:\n"
        "- TM_Campaign_Local\n"
        "- TM_Cup_Online\n"
        "- TM_Laps_Online\n"
        "- TM_Teams_Online\n"
        "- TM_Royal_Online\n"
        "- TM_Rounds_Online\n"
        "- TM_Champion_Online\n"
        "- TM_TimeAttack_Online\n"
        "- TM_Knockout_Online (KO Tournament)\n"
        "- TM_KnockoutDaily_Online (COTD KO rounds)\n"
        "- TM_TimeAttackDaily_Online (COTD qualifier)\n"
        "- TM_Teams_Matchmaking_Online (Ranked)\n"
        "\n"
        "More fragments of game mode names can be found in:\n  Trackmania.Title.Pack.gbx/Scripts/Libs/Nadeo/TMNext/TrackMania/Modes"
    );
}


bool State_CurrentlyVisible = true;
bool State_UserDidUnbindWhenPrompted = false;

[SettingsTab name="Plugin State"]
void RenderSettingsPluginState() {
    State_CurrentlyVisible = UI::Checkbox("Currently visible?", State_CurrentlyVisible);
    AddSimpleTooltip("If this is false, then the prompt will be temporarily hidden for the rest of this map.");

    State_UserDidUnbindWhenPrompted = UI::Checkbox("User did unbind when prompted", State_UserDidUnbindWhenPrompted);
    AddSimpleTooltip("This flag is true if the user unbound giveup when prompted to.\nThis is used to figure out if the rebind prompt should be shown.");
}
