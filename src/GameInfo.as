CTrackMania@ GetTmApp() {
   return cast<CTrackMania>(GetApp());
}

namespace GI {
    CTrackMania@ GetApp() {
        return GetTmApp();
    }

    CTrackManiaNetwork@ GetNetwork() {
        return cast<CTrackManiaNetwork>(GetApp().Network);
    }

    CTrackManiaNetworkServerInfo@ GetServerInfo() {
        return cast<CTrackManiaNetworkServerInfo>(GetNetwork().ServerInfo);
    }

    bool PlaygroundIsNull() {
        auto network = GetNetwork();
        return network.ClientManiaAppPlayground is null
            || network.ClientManiaAppPlayground.Playground is null;
    }

    bool PlaygroundNotNull() {
        auto network = GetNetwork();
        return network.ClientManiaAppPlayground !is null
            && network.ClientManiaAppPlayground.Playground !is null;
    }

    /* some core objects that expose API methods for NadeoServices */

    CGameManiaAppPlayground@ GetManiaAppPlayground() {
        return GetNetwork().ClientManiaAppPlayground;
    }

    CGamePlaygroundClientScriptAPI@ GetPlaygroundClientScriptAPI() {
        return GetNetwork().PlaygroundClientScriptAPI;
    }

    CSmArenaClient@ GetCurrentPlayground() {
        return cast<CSmArenaClient>(GetApp().CurrentPlayground);
    }

    MwFastBuffer<CGamePlaygroundUIConfig@> GetPlaygroundUIConfigs() {
        auto pg = GetCurrentPlayground();
        if (pg is null) return MwFastBuffer<CGamePlaygroundUIConfig@>();
        return pg.UIConfigs;
    }

    int GetPlaygroundFstUISequence() {
        auto cs = GetPlaygroundUIConfigs();
        if (cs.Length == 0) { return 0; }
        return cs[0].UISequence;
    }

    CInputPortDx8@ GetInputPort() {
        return cast<CInputPortDx8@>(GetApp().InputPort);
    }

    CTrackManiaMenus@ GetMenuManager() {
        return cast<CTrackManiaMenus>(GetApp().MenuManager);
    }

    CGameManiaAppTitle@ GetMenuCustom() {
        return GetTmApp().MenuManager.MenuCustom_CurrentManiaApp;
    }

    CGameUILayer@ GetUILayer(uint i) {
        return GetMenuCustom().UILayers[i];
    }

    // CGamePlaygroundUIConfig@ GetPlaygroundUIConfig() {
    //     auto pg = GetCurrentPlayground();
    //     if (pg is null) return null;
    //     return pg.UI;
    // }

    // CGamePlaygroundUIConfig@ GetPlaygroundClientUIConfig() {
    //     auto pg = GetCurrentPlayground();
    //     if (pg is null) return null;
    //     return pg.ClientUI;
    // }

    CGameDataFileManagerScript@ GetCoreApiThingForMaps() {
        return GetTmApp().MenuManager.MenuCustom_CurrentManiaApp.DataFileMgr;
    }

    CGameUserManagerScript@ GetCoreUserManagerScript() {
        return GetTmApp().UserManagerScript;
    }

    CGameManiaPlanetScriptAPI@ GetManiaPlanetScriptApi() {
        return GetTmApp().ManiaPlanetScriptAPI;
    }

    /* UI Sequence
        CGamePlaygroundUIConfig::EUISequence {
            0=None, 1=Playing, 2=Intro, 3=Outro, 4=Podium, CustomMTClip, 6=EndRound,
            7=PlayersPresentation, 8=UIInteraction, 9=RollingBackgroundIntro,
            10=CustomMTClip_WithUIInteraction, 11=Finish

            does not change in escape menu or when viewing scores via <tab>

            On game start: 0
            In Loading screen: 0 or 8?

            Around msg: The match is over, thank you for playing. You can leave now.
            before: 8, after: 4
            nb: before might have had an end of game menu up

            Around COTD end (but after elimination):
            before: 1, after: 8

            During COTD round-end: 8

            sequences on server join:
            start: 4 -> 8 -> 2 -> 1

            local: 1 -> 9 -> 1
        }

    /* menu / dialog stuff */

    void BindInput(int ActionIndex, CInputScriptPad@ Device) {
        auto mpsapi = GetManiaPlanetScriptApi();
        mpsapi.Dialog_BindInput(ActionIndex, Device);
    }

    // Press a button to unbind it.
    void UnbindInput(CInputScriptPad@ Device) {
        GetManiaPlanetScriptApi().Dialog_BindInput(-1, Device);
    }

    void UnbindInputDevice(CInputScriptPad@ Device) {
        GetManiaPlanetScriptApi().Dialog_UnbindInputDevice(Device);
    }

    /* dialog bug notes
        MPScriptApi.Dialog_IsFinished = true/false
                   .ActiveContext_ClassicDialogDisplayed
        GetApp().Operation_InProgress = true/false
    */

    /* does not work or do anything */
    // void UnbindInput(CInputScriptPad@ pad) {
    //     GetManiaPlanetScriptApi().Dialog_UnbindInputDevice(pad);
    // }

    /* Utility Functions */

    bool IsLoadingScreen() {
        auto pgCSApi = GetPlaygroundClientScriptAPI();
        if (pgCSApi !is null && pgCSApi.IsLoadingScreen) {
            return true;
        }
        auto pg = GetManiaAppPlayground();
        if (pg !is null && pg.HoldLoadingScreen) {
            return true;
        }
        return false;
    }

    string PlayersId() {
        return GetNetwork().PlayerInfo.WebServicesUserId;
    }

    bool InMainMenu() {
        return UI::CurrentActionMap() == "MenuInputsMap" && PlaygroundIsNull();
    }

    bool InGame() {
        return PlaygroundNotNull() && (string(GetServerInfo().CurGameModeStr).Length > 0);
    }

    uint GameTimeMsLeft() {
        if (GetCurrentPlayground() is null || GetManiaAppPlayground() is null
            || GetCurrentPlayground().Arena is null
            || GetCurrentPlayground().Arena.Rules is null) return 0;
        int end = GetCurrentPlayground().Arena.Rules.RulesStateEndTime;
        int now = GetManiaAppPlayground().Playground.GameTime;
        return end - now;
    }

    /* context */

    CGameManiaPlanetScriptAPI::EContext GetActiveContext() {
        // https://next.openplanet.dev/Game/CGameManiaPlanetScriptAPI
        return GetManiaPlanetScriptApi().ActiveContext;
    }

    bool ActiveContextIsMultiplayerInGame() {
        return GetActiveContext() == CGameManiaPlanetScriptAPI::EContext::Multi;
    }

    /* COTD / Game mode stuff */

    bool IsCotdQuali() {
        auto server_info = GetServerInfo();
        return PlaygroundNotNull()
            && server_info.CurGameModeStr == "TM_TimeAttackDaily_Online";
    }

    bool IsCotdKO() {
        auto server_info = GetServerInfo();
        return PlaygroundNotNull()
            && server_info.CurGameModeStr == "TM_KnockoutDaily_Online";
    }

    bool IsCotd() {
        auto server_info = GetServerInfo();
        return PlaygroundNotNull()
            && (server_info.CurGameModeStr == "TM_TimeAttackDaily_Online" || server_info.CurGameModeStr == "TM_KnockoutDaily_Online");
    }

    string MapId() {
        auto rm = GetApp().RootMap;
#if DEV
        int now = Time::get_Now();
        if ((now % 1000) < 100) {
            // trace("[MapId()," + now + "] rm is null: " + (rm is null));
            if (rm !is null) {
                // trace("[MapId()," + now + "] rm.IdName: " + rm.IdName);
            }
        }
#endif
        return (rm is null) ? "" : rm.IdName;
    }

    MwSArray<CGameNetPlayerInfo@> getPlayerInfos() {
        return GetNetwork().PlayerInfos;
    }

    CTrackManiaPlayerInfo@ NetPIToTrackmaniaPI(CGameNetPlayerInfo@ netpi) {
        return cast<CTrackManiaPlayerInfo@>(netpi);
    }
}
