namespace Targets {
    array<HideTarget@> all;

    void Register() {
        // guard in case it gets called multiple times
        if (all.Length > 0) return;

        all.InsertLast(NativeHudTarget("hideRecords", "Hide Records", true, { "Race_Record" }));
        all.InsertLast(NativeHudTarget("hideRespawnHelper", "Hide Respawn Helper", true, { "Race_RespawnHelper" }));
        all.InsertLast(NativeHudTarget("hideCountdown", "Hide Countdown", true, { "Race_Countdown" }));
        all.InsertLast(NativeHudTarget("hideBestRaceViewer", "Hide Best Race Viewer", true, { "Race_BestRaceViewer" }));
        all.InsertLast(NativeHudTarget("hideTimeGap", "Hide Time Gap", false, { "Race_TimeGap" }));
        all.InsertLast(NativeHudTarget("hideRaceChrono", "Hide Bottom Timer", false, { "Race_Chrono" }));
        all.InsertLast(NativeHudTarget(
            "hideCheckpointSplit",
            "Hide Checkpoint Splits",
            false,
            { "frame-race-rank", "frame-race-time", "frame-race-diff" }
        ));

        all.InsertLast(NativeChatTarget("hideNativeChat", "Hide Native Chat", true));
    }

    HideTarget@ Find(const string &in key) {
        for (uint i = 0; i < all.Length; i++) {
            HideTarget@ target = all[i];
            if (target.key == key) return target;
        }
        return null;
    }
}