
Resources::Font@ headingFont = Resources::GetFont("DroidSans.ttf", 20, -1, -1, true, true);;
Resources::Font@ subheadingFont = Resources::GetFont("DroidSans.ttf", 18, -1, -1, true, true);;
Resources::Font@ stdBold = Resources::GetFont("DroidSans-Bold.ttf", 16, -1, -1, true, true);;

/* tooltips */

void AddSimpleTooltip(string msg) {
    if (UI::IsItemHovered()) {
        UI::BeginTooltip();
        UI::Text(msg);
        UI::EndTooltip();
    }
}

/* button */

void DisabledButton(const string &in text, const vec2 &in size = vec2 ( )) {
    UI::BeginDisabled();
    UI::Button(text, size);
    UI::EndDisabled();
}

bool MDisabledButton(bool disabled, const string &in text, const vec2 &in size = vec2 ( )) {
    if (disabled) {
        DisabledButton(text, size);
        return false;
    } else {
        return UI::Button(text, size);
    }
}

/* padding */

void VPad() { UI::Dummy(vec2(10, 2)); }

void PaddedSep() {
    VPad();
    UI::Separator();
    VPad();
}

/* heading */

void TextHeading(string t) {
    UI::PushFont(headingFont);
    VPad();
    UI::Text(t);
    UI::Separator();
    VPad();
    UI::PopFont();
}


/* sorta functional way to draw elements dynamically as a list or row or other things. */

funcdef void DrawUiElems();
funcdef void DrawUiElemsF(DrawUiElems@ f);

void DrawAsRow(DrawUiElemsF@ f, const string &in id, int cols = 64) {
    int flags = 0;
    flags |= UI::TableFlags::SizingFixedFit;
    flags |= UI::TableFlags::NoPadOuterX;
    if (UI::BeginTable(id, cols, flags)) {
        UI::TableNextRow();
        f(DrawUiElems(_TableNextColumn));
        UI::EndTable();
    }
}

void _TableNextRow() {
    UI::TableNextRow();
}
void _TableNextColumn() {
    UI::TableNextColumn();
}

/* table column pair */

void DrawAs2Cols(const string &in c1, const string &in c2) {
    UI::TableNextColumn();
    UI::Text(c1);
    UI::TableNextColumn();
    UI::Text(c2);
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
