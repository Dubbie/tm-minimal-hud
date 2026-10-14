namespace MinimalMode {
    bool enabled = false;
    float reapplyElapsedMs = 0;
    CGamePlayground@ observedPlayground = null;

    void Toggle() {
        minimalModeRequested = !minimalModeRequested;

        if (minimalModeRequested) {
            Apply();
        } else {
            Restore();
        }
    }

    void Apply() {
        for (uint i = 0; i < Targets::all.Length; i++) {
            HideTarget@ target = Targets::all[i];

            if (target.defaultHidden && target.IsAvailable()) {
                if (target.Hide()) {
                    enabled = true;
                }
            } else {
                // not wanted or not available: put it back
                target.Restore();
            }
        }
    }

    void Restore() {
        for (uint i = 0; i < Targets::all.Length; i++) {
            HideTarget@ target = Targets::all[i];
            target.Restore();
        }

        enabled = false;
    }

    void Enforce() {
        if (!minimalModeRequested) return;

        for (uint i = 0; i < Targets::all.Length; i++) {
            HideTarget@ target = Targets::all[i];
            if (target.HasSnapshot()) target.Enforce();
        }
    }

    void Tick(float dt) {
        CGamePlayground@ currentPlayground = Game::app.CurrentPlayground;

        if (currentPlayground !is observedPlayground) {
            if (enabled) {
                Restore();
            }

            @observedPlayground = currentPlayground;
        }

        if (!minimalModeRequested || currentPlayground is null) {
            reapplyElapsedMs = 0;
            return;
        } else {
            reapplyElapsedMs += dt;
            if (reapplyElapsedMs >= 250) {
                reapplyElapsedMs = 0;
                Apply();
            }
        }
    }
}