
class GameInfo {
    CTrackMania@ get_app() {
        return GetTmApp();
    }

    CTrackManiaNetwork@ GetNetwork() {
        return cast<CTrackManiaNetwork>(app.Network);
    }

    CTrackManiaNetworkServerInfo@ GetServerInfo() {
        return cast<CTrackManiaNetworkServerInfo>(GetNetwork().ServerInfo);
    }

    bool PlaygroundNotNull() {
        auto network = GetNetwork();
        return network.ClientManiaAppPlayground !is null
            && network.ClientManiaAppPlayground.Playground !is null;
    }

    /* some core objects that expose API methods for NadeoServices */

    CGameDataFileManagerScript@ GetCoreApiThingForMaps() {
        return GetTmApp().MenuManager.MenuCustom_CurrentManiaApp.DataFileMgr;
    }

    CGameUserManagerScript@ GetCoreUserManagerScript() {
        return GetTmApp().UserManagerScript;
    }

    CGameManiaPlanetScriptAPI@ GetManiaPlanetScriptApi() {
        return GetTmApp().ManiaPlanetScriptAPI;
    }

    /* menu / dialog stuff */

    void BindInput(int ActionIndex, CInputScriptPad@ Device) {
        auto mpsapi = GetManiaPlanetScriptApi();
        mpsapi.Dialog_BindInput(ActionIndex, Device);
    }

    /* Utility Functions */

    string PlayersId() {
        return GetNetwork().PlayerInfo.WebServicesUserId;
    }

    bool InGame() {
        return PlaygroundNotNull() && (string(GetServerInfo().CurGameModeStr).Length > 0);
    }

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
        auto rm = app.RootMap;
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
