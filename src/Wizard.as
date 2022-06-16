namespace Wizard {
    Resources::Font@ font = Resources::GetFont("DroidSans.ttf", 20);

    int currWizardSlide = 0;

    void Render() {
        if (State_WizardShouldRun)
            RenderWizardUI();
    }

    void RenderWizardUI() {
        UI::PushFont(font);
        if (UI::Begin("Setup Wizard: Never Give Up", State_WizardShouldRun, GetWinFlags())) {
            UI::Dummy(vec2(150, 0));
            RenderSlide(currWizardSlide);
            UI::End();
        }
        UI::PopFont();
    }

    int GetWinFlags() {
        return 0
            | UI::WindowFlags::AlwaysAutoResize
            | UI::WindowFlags::NoCollapse
            | UI::WindowFlags::NoDocking
            ;
    }

    void RenderSlide(int slideIx) {
        if (slideIx == 0) RenderOpeningSlide();
        else if (slideIx == 1) RenderDoneSlide();
        else {
            UI::Text("unknown slide: " + slideIx);
        }
    }

    void VPad() {
        UI::Dummy(vec2(2, 10));
    }
    void Sep() {
        VPad();
        UI::Separator();
        VPad();
    }

    void RenderOpeningSlide() {
        UI::TextWrapped("Welcome to the Never Give Up Wizard!");
        VPad();
        UI::TextWrapped("A preview of the NGU prompt should appear shortly.");
        Sep();
        UI::TextWrapped("What input device do you want NGU to use? (You can change this in settings later.)");
        VPad();
        auto currPt = PadTypeToStr(Setting_PadType);
        if (UI::BeginCombo("Input Device", currPt, UI::ComboFlags::HeightLarge)) {
            for (uint i = 0; i < ALL_PAD_TYPES.Length; i++) {
                auto pt = ALL_PAD_TYPES[i];
                if (UI::Selectable(PadTypeToStr(pt), pt == Setting_PadType, UI::SelectableFlags::None)) {
                    Setting_PadType = pt;
                    OnSettingsChanged();
                }
            }
            UI::EndCombo();
        }
        VPad();
        UI::TextWrapped("If the preview has appeared, you should see the current bindings for your selected input device.");
        Sep();
        if (UI::Button("Next")) {
            currWizardSlide++;
        }
    }

    void RenderDoneSlide() {
        UI::TextWrapped("\\$5e8    You're done! Gz.");
        VPad();
        UI::TextWrapped("The preview will go away when you close this window.");
        VPad();
        if (UI::Button("Never Give Up! Never Surrender!")) {
            State_WizardShouldRun = false;
        }
    }
}
