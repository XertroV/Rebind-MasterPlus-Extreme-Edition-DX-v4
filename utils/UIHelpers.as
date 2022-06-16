void AddSimpleTooltip(string msg) {
    if (UI::IsItemHovered()) {
        UI::BeginTooltip();
        UI::Text(msg);
        UI::EndTooltip();
    }
}

vec2 GetMenuItemSize(float cols = 2) {
    return vec2(UI::GetWindowContentRegionWidth() / cols - 2 * (cols - 1), UI::GetTextLineHeightWithSpacing());
}

float GetSpacingBetweenLines() {
    return (UI::GetTextLineHeightWithSpacing() - UI::GetTextLineHeight()) / 2;
}

// bool HoverRegion(const string &in label) {
//     vec2 cp = UI::GetCursorPos();
//     UI::InvisibleButton("hr-ib-" + label, GetMenuItemSize());
//     UI::SetCursorPos(cp);
//     return UI::IsItemHovered();
// }

bool MouseHoveringRegion(vec2 tlPos, vec2 size) {
    vec2 mousePos = UI::GetMousePos();
    vec2 brPos = tlPos + size;
    // trace(tostring(tlPos) + " | " + tostring(mousePos) + " | " + tostring(brPos));
    return tlPos.x <= mousePos.x && tlPos.y <= mousePos.y
        && mousePos.x <= brPos.x && mousePos.y <= brPos.y;
}

void ModCursorPos(vec2 deltas) {
    UI::SetCursorPos(UI::GetCursorPos() + deltas);
}

bool MenuItemNoClose(const string &in label, const string &in shortcut = "", bool selected = false, bool enabled = true) {
    bool hovered = MouseHoveringRegion(UI::GetWindowPos() + UI::GetCursorPos(), GetMenuItemSize());
    float alpha = hovered ? 1.0 : 0.0;

    UI::PushStyleColor(UI::Col::ChildBg, vec4(.231, .537, .886, alpha));
    UI::PushStyleVar(UI::StyleVar::WindowPadding, vec2(2,2));

    UI::BeginChild("c-" + label, GetMenuItemSize());
    // "pad" top a bit
    ModCursorPos(vec2(GetSpacingBetweenLines(), GetSpacingBetweenLines()));
    // store current cursor pos
    vec2 tl = UI::GetCursorPos();
    if (selected)
        UI::Text(Icons::Check);
    // right of check mark
    UI::SetCursorPos(tl + vec2(24, 0));
    UI::Text(label);
    UI::EndChild();

    UI::PopStyleVar();
    UI::PopStyleColor();

    return UI::IsItemClicked();
}
