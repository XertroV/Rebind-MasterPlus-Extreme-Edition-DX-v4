/* to set user config we need to access the .MainUserProfile object which is null during normal runtime contexts.
*/

class SetVehicleTogglesSoon {
    bool accel, brake, steer;
    SetVehicleTogglesSoon(CGameUserProfileWrapper_VehicleSettings@ v) {
        accel = v.AccelIsToggleMode;
        brake = v.BrakeIsToggleMode;
        steer = v.InvertSteer;
        Meta::StartWithRunContext(Meta::RunContext::BeforeScripts, CoroutineFunc(this.RunSet));
        // Meta::StartWithRunContext(Meta::RunContext::AfterMainLoop, CoroutineFunc(this.RunSet));
        // Meta::StartWithRunContext(Meta::RunContext::GameLoop, CoroutineFunc(this.RunSet));
        // Meta::StartWithRunContext(Meta::RunContext::MainLoop, CoroutineFunc(this.RunSet));
        // Meta::StartWithRunContext(Meta::RunContext::NetworkAfterMainLoop, CoroutineFunc(this.RunSet));
    }

    void RunSet() {
        auto userMgr = GI::GetCoreUserManagerScript();
        auto cmap = GetTmApp().Network.ClientManiaAppPlayground;
        _RunSet(userMgr);
        // @userMgr = null;
        // sleep(1000);
        // if (cmap is null) return;
        // _RunSet(cmap.UserMgr);
    }

    void _RunSet(CGameUserManagerScript@ userMgr) {
        auto mainUserProfile = userMgr.MainUserProfile;
        if (mainUserProfile is null) {
            warn("SetVehicleTogglesSoon: MainUserProfile is null, cannot set vehicle toggles.");
            return;
        }
        for (uint i = 0; i < mainUserProfile.Inputs_Vehicles.Length; i++) {
            auto v = mainUserProfile.Inputs_Vehicles[i];
            v.AccelIsToggleMode = accel;
            v.BrakeIsToggleMode = brake;
            v.InvertSteer = steer;
        }
        trace("SetVehicleTogglesSoon: Set vehicle toggles to Accel: " + accel + ", Brake: " + brake + ", Steer: " + steer);

        _TryUpdatePlayground();
    }

    void _TryUpdatePlayground() {
        auto pg = cast<CSmArenaClient>(GetApp().CurrentPlayground);
        if (pg is null) return;
        auto ai = pg.ArenaInterface;
        if (ai is null) return;
        // buffer of 2 things at 0x1170.
        auto bufPtr = Dev::GetOffsetUint64(ai, 0x1170);
        auto bufLen = Dev::GetOffsetUint32(ai, 0x1170 + 0x8);
        auto bufCap = Dev::GetOffsetUint32(ai, 0x1170 + 0xC);
        if (bufLen > bufCap || bufLen == 0 || bufLen > 10 || bufCap > 10) {
            warn("SetVehicleTogglesSoon: Invalid buffer length or capacity for vehicle toggles: " + bufLen + ", " + bufCap);
            return;
        }
        if (bufPtr == 0 || bufPtr % 8 != 0 || bufPtr < 0xFFFFFF || bufPtr > 0xF00AABBCCDD || (bufPtr & 0xFFFFFFFF) <= 0xFFFF) {
            warn("SetVehicleTogglesSoon: Invalid buffer pointer for vehicle toggles: " + Text::FormatPointer(bufPtr));
            return;
        }
        // struct of 0x20, but only first in buffer matters.
        // layout: [bool invertSteer (4bytes)] [bool accelToggle] [bool brakeToggle] [float] [float] [float] [unk4] [centerSpringIntensity]
        Dev::Write(bufPtr + 0x0, uint(steer ? 1 : 0));
        Dev::Write(bufPtr + 0x4, uint(accel ? 1 : 0));
        Dev::Write(bufPtr + 0x8, uint(brake ? 1 : 0));
    }

}
