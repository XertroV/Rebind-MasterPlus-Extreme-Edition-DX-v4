const int _N_ICONS = 25;

const int _width = 300;
const float _font_size = _width / 5;
const int _window_height = 45;
const vec2 _UNBIND_WINDOW_DIMS = vec2(_width, _window_height);
// const vec2 _UNBIND_WINDOW_DIMS = vec2(150, 75);
const vec2 _UNBIND_TEXT_XY = vec2(_width, _width * .3);

enum LastAction {
    NoAction,
    UiManuallyClosed,
    // more?
}

class UnbindPrompt {
    string sessionIcon;

    LastAction lastAction = NoAction;

    Resources::Font@ btnFont;
    Resources::Font@ inlineTitleFont;

    // we only run this once on init
    string GetIcon(uint nonce) {
        string[] _icons = {
            Icons::FighterJet,
            Icons::Bolt,
            Icons::Exclamation,
            Icons::Anchor,
            Icons::FireExtinguisher,
            Icons::Shield,
            Icons::Rocket,
            Icons::LevelUp,
            Icons::Rebel,
            Icons::Empire,
            Icons::SpaceShuttle,
            Icons::PaperPlane,
            Icons::Bomb,
            Icons::Heartbeat,
            Icons::Motorcycle,
            Icons::PaperPlaneO,
            Icons::BirthdayCake,
            Icons::BalanceScale,
            Icons::InternetExplorer,
            Icons::Firefox,
            Icons::FortAwesome,
            Icons::Expand,
            Icons::Sun,
            Icons::Kenney::Flag,
            Icons::Kenney::HeartO
        };

        // print("_icons.Length: " + _icons.Length);
        // print("nonce: " + nonce);
        // print("nonce % _N_ICONS: " + nonce % _N_ICONS);

        if (_icons.Length != _N_ICONS) {
            string errMsg = "Assertion failed: _icons.Length != _N_ICONS (" + _icons.Length + " != " + _N_ICONS + ")";
            // error(errMsg);
            throw(errMsg);
        }

        // assume the nonce was random enough and take the mod to pick an icon.
        return _icons[nonce % _N_ICONS];
    }

    UnbindPrompt() {
        // set the icon for this session.
        sessionIcon = GetIcon(Time::get_Now());
        @btnFont = Resources::GetFont("DroidSans-Bold.ttf", 20.);
        @inlineTitleFont = Resources::GetFont("DroidSans.ttf", 19., -1, -1, true, true);
        // set up state stuff
        OnNewMode();
    }


    // do icon stuff to title -- simple atm but could be more complex / interesting later.
    string IconifyTitle(string _title) {
        return sessionIcon + "  " + _title;
    }


    void Draw() {
        bool appropriateMatch = IsRankedOrCOTD();

        bool _disabled = !Setting_Enabled;
        bool _irrelevant = !appropriateMatch  || !State_CurrentlyVisible;
        bool _showAnyway = !Setting_HideWhenIrrelevant && State_CurrentlyVisible;

        // if (Time::get_Now() % 1000 < 10) {
        //     dictionary@ vars = {
        //         { "_disabled", _disabled },
        //         { "_irrelevant", _irrelevant },
        //         { "_showAnyway", _showAnyway }
        //     };
        //     print(dict2str(vars));
        // }

        if (_disabled || (_irrelevant && !_showAnyway)) {
            return;
        }

        auto app = GetTmApp();

        // print("draw unbind");

        // setup -- settings and prep flags
        auto _pos = Setting_Pos;
        // auto _dims = Setting_Dims;
        auto _locked = Setting_PromptLocked;
        int _flags = 0
                   | UI::WindowFlags::NoTitleBar
                   | UI::WindowFlags::NoCollapse
                //    | UI::WindowFlags::AlwaysAutoResize
                   | UI::WindowFlags::NoResize
                   | (_locked ? (UI::WindowFlags::NoMove | UI::WindowFlags::NoResize) : 0)
                //    | UI::WindowFlags::MenuBar
                   | UI::WindowFlags::NoDocking;
                // ;
        _flags |= UI::IsOverlayShown() ? 0 : UI::WindowFlags::NoInputs;

        // draw window
        UI::SetNextWindowPos(int(_pos.x), int(_pos.y), UI::Cond::Appearing);
        // UI::SetNextWindowSize(int(_dims.x), int(_dims.y), UI::Cond::FirstUseEver);
        // UI::SetNextWindowSize(800, 300);
        string _title = IconifyTitle(PLUGIN_TITLE);
        UI::Begin(_title, Setting_Enabled, _flags);
        UI::SetWindowSize(_UNBIND_WINDOW_DIMS, UI::Cond::Always);
        Setting_Pos = UI::GetWindowPos();

        // update window position in settings if it's been moved
        // if (!_locked) {
        //     Setting_Pos = UI::GetWindowPos();
        // }

        // if(UI::BeginChild("Matches", vec2(100, 40), true)) {
        //     UI::Text(".. matches ..");
        //     UI::EndChild();
        // }
        UI::BeginGroup();
            if (UI::BeginTable("header", 3, UI::TableFlags::SizingStretchProp)) {
                UI::TableNextRow();

                UI::TableNextColumn();
                UI::PushFont(inlineTitleFont);
                UI::Text(_title);
                UI::PopFont();

                UI::TableNextColumn();
                // auto visibleIcon = Icons::EyeSlash;
                auto visibleIcon = Icons::Eye;
                if (UI::Button(visibleIcon)) {
                    // clicked hide
                    State_CurrentlyVisible = false;
                }

                UI::TableNextColumn();
                auto lockToggle = !Setting_PromptLocked ? Icons::Unlock : Icons::Lock;
                if (UI::Button(lockToggle)) {
                    // clicked lock/unlock
                    Setting_PromptLocked = !Setting_PromptLocked;
                }

                UI::EndTable();
            }
        //     // DrawTestTable();
        UI::EndGroup();

        // nvg stuff after ImGui, but before we End() so that we can do buttons and things, still.
        DrawUnbindMain();

        UI::End();
    }

    void OnNewMode() {
        State_CurrentlyVisible = true;

        // log updated gameMode
        string p = gameMode == "" ? "<null>" : gameMode;
        trace("Changing game mode to: " + p);
    }

    void DrawUnbindMain() {
        auto _pos = Setting_Pos;
        nvg::FontSize(_font_size);
        nvg::TextAlign(nvg::Align::Center | nvg::Align::Middle);
        nvg::TextBox(_pos.x, _UNBIND_WINDOW_DIMS.y + _pos.y + _UNBIND_TEXT_XY.y/2, _UNBIND_TEXT_XY.x, "UNBIND\n'GIVE UP'");
    }


    // void DrawTestTable() {
    //     bool clickedUnbind = false;
    //     UI::PushStyleVar(UI::StyleVar::ButtonTextAlign, vec2(.5, .5));

    //     if (UI::BeginTable("header", 3, UI::TableFlags::SizingStretchProp)) {
    //         UI::TableNextRow();
    //         UI::TableNextColumn();
    //         UI::Text("\\$ddd" + Icons::HandORight);
    //         UI::TableNextColumn();

    //         UI::PushFont(btnFont);
    //         clickedUnbind = UI::Button("\\$z" + "  UNBIND \n<GIVE UP>");
    //         // UI::Text("  UNBIND \n<GIVE UP>");
    //         UI::PopFont();

    //         UI::TableNextColumn();
    //         UI::Text("\\$ddd" + Icons::HandOLeft);
    //         // UI::TableNextColumn();
    //         // UI::TableNextRow();
    //         // UI::TableNextRow();
    //         // UI::TableNextColumn();
    //         // UI::Text("\\$888" + "An author!");
    //         UI::EndTable();
    //     }

    //     UI::PopStyleVar();

    //     if (clickedUnbind) {
    //         OnClickUnbind();
    //     }

    //     // UI::Columns(3, "UnbindButtonCols", true);
    //     // UI::Text("\\$ddd" + Icons::HandORight);
    //     // UI::NextColumn();
    //     // UI::Text("\\$z" + "UNBIND\nGIVE UP");
    //     // UI::NextColumn();
    //     // UI::Text("\\$ddd" + Icons::HandOLeft);

    //     // UI::Columns(1);

    // }


    void RenderMenu() {
        if (UI::MenuItem(IconifyTitle(PLUGIN_TITLE), "", Setting_Enabled)) {
            Setting_Enabled = !Setting_Enabled;
        }
    }


    void OnClickUnbind() {
        UI::ShowNotification("You clicked unbind give up", 1500);
        auto app = GetTmApp();
        auto mm = cast<CTrackManiaMenus>(app.MenuManager);
        // mm.DialogInGameMenuAdvanced_OnInputSettings();
        // mm.DialogQuitRace_OnInputSettings();
        // app.SystemOverlay.SwitchFullscreen();
        // app.SystemOverlay.OpenInputSettings();
        // app.SystemOverlay.OpenInterfaceSettings();
        // mm.DialogInputSettings();
    }
}
