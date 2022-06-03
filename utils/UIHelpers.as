
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
