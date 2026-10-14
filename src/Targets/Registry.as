namespace Targets {
    const string GROUP_NATIVE_HUD = "Native HUD";
    const string GROUP_PLUGIN_OVERLAYS = "Plugin overlays";
    const string GROUP_CHAT = "Chat";

    array<HideTarget@> all;
    dictionary groupNotes;

    void Register() {
        // guard in case it gets called multiple times
        if (all.Length > 0) return;

        all.InsertLast(NativeHudTarget("hideRecords", "Hide Records", true, { "Race_Record" }));
        all.InsertLast(NativeHudTarget("hideRespawnHelper", "Hide Respawn Helper", true, { "Race_RespawnHelper" }, "Launched Respawn, Give Up etc."));
        all.InsertLast(NativeHudTarget("hideCountdown", "Hide Countdown", true, { "Race_Countdown" }));
        all.InsertLast(NativeHudTarget("hideBestRaceViewer", "Hide Best Race Viewer", true, { "Race_BestRaceViewer" }, "Best and previous times on the right side, below the countdown."));
        all.InsertLast(NativeHudTarget("hideTimeGap", "Hide Time Gap", false, { "Race_TimeGap" }, "Time gap leaderboard in the bottom right corner."));
        all.InsertLast(NativeHudTarget("hideRaceChrono", "Hide Bottom Timer", false, { "Race_Chrono" }));
        all.InsertLast(NativeHudTarget(
            "hideCheckpointSplit",
            "Hide Checkpoint Splits",
            false,
            { "frame-race-rank", "frame-race-time", "frame-race-diff" },
            "Checkpoints and time splits in the middle of your screen."
        ));

        all.InsertLast(
            PluginSettingsTarget(
                "hideDashboard",
                "Hide Dashboard",
                true,
                "Dashboard",
                {
                    "Setting_General_ShowPad", "Setting_General_ShowPadHidden",
                    "Setting_General_ShowGearbox", "Setting_General_ShowGearboxHidden",
                    "Setting_General_ShowWheels", "Setting_General_ShowWheelsHidden",
                    "Setting_General_ShowAcceleration", "Setting_General_ShowAccelerationHidden",
                    "Setting_General_ShowSpeed", "Setting_General_ShowSpeedHidden",
                    "Setting_General_ShowClock", "Setting_General_ShowClockHidden"
                }
            )
        );
        all.InsertLast(
            PluginSettingsTarget(
                "hideGrindingStats",
                "Hide Grinding Stats",
                true,
                "Grinding Stats",
                {
                    "setting_enabled"
                }
            )
        );
        all.InsertLast(
            PluginSettingsTarget(
                "hideCheckpointCounter",
                "Hide Checkpoint Counter",
                false,
                "Checkpoint Counter",
                {
                    "showCounter"
                }
            )
        );
        all.InsertLast(
            PluginSettingsTarget(
                "hideSplitSpeeds",
                "Hide Split Speeds",
                false,
                "Split Speeds",
                {
                    "showCurrentSpeed", "showSpeedDiff"
                }
            )
        );

        all.InsertLast(NativeChatTarget("hideNativeChat", "Hide Native Chat", false));
        all.InsertLast(BetterChatTarget("hideBetterChat", "Hide Better Chat", false));

        groupNotes.Set(GROUP_PLUGIN_OVERLAYS, "These options temporarily change other plugins' settings until minimal mode is disabled.\nDisabled rows mean the plugin is either not installed or has been disabled.");
        groupNotes.Set(GROUP_CHAT, "Hiding Better Chat will change the plugin's settings until minimal mode is disabled.\nNative chat is not re-hidden every frame, so it can come back.");
    }

    array<string> Groups() {
        array<string> groups;

        for (uint i = 0; i < all.Length; i++) {
            HideTarget@ target = all[i];

            if (groups.Find(target.group) < 0) {
                groups.InsertLast(target.group);
            }
        }

        return groups;
    }

    string GroupNote(const string &in group) {
        string note = "";
        if (!groupNotes.Get(group, note)) return "";

        return note;
    }
}