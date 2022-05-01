const int _N_ICONS = 25;

enum LastAction {
    NoAction,
    UiManuallyClosed,
    // more?
}

class UnbindPrompt {
    string sessionIcon;

    bool currentlyVisible = true;
    LastAction lastAction = NoAction;

    // we only run this once on init
    string GetIcon(uint nonce) {
        // string[] _icons;
        // _icons.InsertLast(Icons::FighterJet);
        // _icons.InsertLast(Icons::Bolt);
        // _icons.InsertLast(Icons::Exclamation);
        // _icons.InsertLast(Icons::Anchor);
        // _icons.InsertLast(Icons::FireExtinguisher);
        // _icons.InsertLast(Icons::Shield);
        // _icons.InsertLast(Icons::Rocket);
        // _icons.InsertLast(Icons::LevelUp);
        // _icons.InsertLast(Icons::Rebel);
        // _icons.InsertLast(Icons::Empire);
        // _icons.InsertLast(Icons::SpaceShuttle);
        // _icons.InsertLast(Icons::PaperPlane);
        // _icons.InsertLast(Icons::Bomb);
        // _icons.InsertLast(Icons::Heartbeat);
        // _icons.InsertLast(Icons::Motorcycle);
        // _icons.InsertLast(Icons::PaperPlaneO);
        // _icons.InsertLast(Icons::BirthdayCake);
        // _icons.InsertLast(Icons::BalanceScale);
        // _icons.InsertLast(Icons::InternetExplorer);
        // _icons.InsertLast(Icons::Firefox);
        // _icons.InsertLast(Icons::FortAwesome);
        // _icons.InsertLast(Icons::Expand);
        // _icons.InsertLast(Icons::Sun);
        // _icons.InsertLast(Icons::Kenney::Flag);
        // _icons.InsertLast(Icons::Kenney::HeartO);

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
            error(errMsg);
            throw(errMsg);
        }

        // assume the nonce was random enough and take the mod to pick an icon.
        return _icons[nonce % _N_ICONS];
    }

    UnbindPrompt() {
        // set the icon for this session.
        sessionIcon = GetIcon(Time::get_Now());

        print(sessionIcon + ' constructor');
    }


    // do icon stuff to title -- simple atm but could be more complex / interesting later.
    string IconifyTitle(string _title) {
        return sessionIcon + " " + _title;
    }


    void Draw() {
        if (!Setting_Enabled) {
            return;
        }

        auto app = GetTmApp();

        // print("draw unbind");

        // setup -- settings and prep flags
        auto _pos = Setting_Pos;
        auto _dims = Setting_Dims;
        auto _locked = Setting_PromptLocked;
        int _flags = 0
                //    | UI::WindowFlags::NoTitleBar
                   | UI::WindowFlags::NoCollapse
                //    | UI::WindowFlags::AlwaysAutoResize
                   | (_locked ? (UI::WindowFlags::NoMove | UI::WindowFlags::NoResize) : 0)
                   | UI::WindowFlags::MenuBar
                   | UI::WindowFlags::NoDocking;
                // ;
        _flags |= UI::IsOverlayShown() ? 0 : UI::WindowFlags::NoInputs;

        // draw window
        // UI::SetNextWindowPos(int(_pos.x), int(_pos.y), UI::Cond::FirstUseEver);
        // UI::SetNextWindowSize(int(_dims.x), int(_dims.y), UI::Cond::FirstUseEver);
        UI::SetNextWindowSize(800, 300);
        UI::Begin(IconifyTitle(PLUGIN_TITLE), Setting_Enabled, _flags);

        // update window position in settings if it's been moved
        // if (!_locked) {
        //     Setting_Pos = UI::GetWindowPos();
        // }

        if(UI::BeginChild("Matches", vec2(0, -40), true)) {
            UI::Text(".. matches ..");
            UI::EndChild();
        }
        UI::BeginGroup();
            UI::Text("test text");
            DrawTestTable();
        UI::EndGroup();

        UI::End();
    }

    void DrawTestTable() {
        UI::BeginTable("header", 1, UI::TableFlags::SizingFixedFit);
            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text("\\$ddd" + "A name!");
            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text("\\$888" + "An author!");
        UI::EndTable();
    }

    void RenderMenu() {
        if (UI::MenuItem(PLUGIN_TITLE, "", currentlyVisible)) {
            if (currentlyVisible) {
                lastAction = LastAction::UiManuallyClosed;
            }
        }
    }
}
