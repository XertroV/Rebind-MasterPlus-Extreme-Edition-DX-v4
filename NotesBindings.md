# dialog at wrong time is rly bad

menus lock up, bad stuff happens

# missing inputs sometimes (e.g., menus)

`InputBindings_UpdateList(CGameManiaPlanetScriptAPI::EInputsListFilter Filter, CInputScriptPad@ Device)`

might help? from maniaplanetscriptapi

# active context:

CGameManiaPlanetScriptAPI.ActiveContext


EContext::MenuStartUp
EContext::MenuManiaPlanet
EContext::MenuManiaTitleMain
EContext::MenuProfile
EContext::MenuSolo
EContext::MenuLocal
EContext::MenuMulti
EContext::MenuEditors
EContext::EditorPainter
EContext::EditorTrack
EContext::EditorMediaTracker
EContext::Solo
EContext::SoloLoadScreen
EContext::Multi
EContext::MultiLoadScreen
EContext::MenuCustom
EContext::Unknown




# idea: intercept `MwFastBuffer<CInputScriptPad::EButton> ButtonEvents` in `CInputPadScript`?

# callbacks that might reset input problems:

DialogInputSettings_OnBindingsUnbindKey
DialogInGameMenuAdvanced_OnInputSettings

(note: these don't work)


# unbind a button

`ManiaPlanet.Dialog_BindInput(-1, Pad);`

source: inputsapi.script.txt
