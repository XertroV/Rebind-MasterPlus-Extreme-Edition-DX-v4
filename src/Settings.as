/*

 dP""b8 888888 88b 88 888888 88""Yb    db    88
dP   `" 88__   88Yb88 88__   88__dP   dPYb   88
Yb  "88 88""   88 Y88 88""   88"Yb   dP__Yb  88  .o
 YboodP 888888 88  Y8 888888 88  Yb dP""""Yb 88ood8

GENERAL

*/

[Setting category="General" name="Enabled?"]
bool Setting_Enabled = true;

[Setting category="General" name="Show even if the UI is hidden?"]
bool Setting_RenderIfUiHidden = true;

[Setting category="General" name="Key to block for 'Give up'" hidden]
VirtualKey Setting_KeyGiveUp = VirtualKey::Delete;

[Setting category="General" name="Block 'Give up' in COTD (TM_KnockoutDaily_Online)"]
bool Setting_BlockDelCotd = true;

[Setting category="General" name="Block 'Give up' in Ranked (TM_Teams_Matchmaking_Online)"]
bool Setting_BlockDelRanked = true;

[Setting category="General" name="Block 'Give up' in Knockout (TM_Knockout_Online)"]
bool Setting_BlockDelKO = true;

/*

88   88 88     Yb        dP 88 88b 88 8888b.   dP"Yb  Yb        dP
88   88 88      Yb  db  dP  88 88Yb88  8I  Yb dP   Yb  Yb  db  dP
Y8   8P 88       YbdPYbdP   88 88 Y88  8I  dY Yb   dP   YbdPYbdP
`YbodP' 88        YP  YP    88 88  Y8 8888Y"   YbodP     YP  YP

UI WINDOW

*/

[Setting category="UI Window" name="Hide UI in menus and for other game modes?" description="If true, then the UI will not be shown except when it is relevant."]
bool Setting_HideWhenInactive = true;

[Setting category="UI Window" name="Hide after debind?"]
bool Setting_HideAfterDebind = true;

[Setting category="UI Window" name="Position"]
vec2 Setting_Pos = vec2(400, 400);

// [Setting category="UI Window" name="Dimensions"]
// vec2 Setting_Dims = vec2(200 * 16 / 10, 200);

[Setting category="UI Window" name="Lock Window?"]
bool Setting_PromptLocked = false;
