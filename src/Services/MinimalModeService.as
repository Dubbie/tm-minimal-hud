namespace MinimalMode {
    bool enabled = false;
    float reapplyElapsedMs = 0;
    CGamePlayground@ observedPlayground = null;

    void Toggle() {
        minimalModeRequested = !minimalModeRequested;

        if (minimalModeRequested) {
            ApplyIfRequested();
        } else {
            Restore();
        }
    }

    void Apply() {
        for (uint i = 0; i < Targets::all.Length; i++) {
            HideTarget@ target = Targets::all[i];

            if (Presets::active.IsHidden(target.key) && target.IsAvailable()) {
                if (target.Hide()) {
                    enabled = true;
                }
            } else {
                // not wanted or not available: put it back
                target.Restore();
            }
        }

        SnapshotRepository::Save();
    }

    void Restore(bool persist = true) {
        for (uint i = 0; i < Targets::all.Length; i++) {
            HideTarget@ target = Targets::all[i];
            target.Restore();
        }

        if (persist) SnapshotRepository::Save();

        enabled = false;
    }

    void Enforce() {
        if (!minimalModeRequested) return;

        // possibly okay to call this every frame
        for (uint i = 0; i < Targets::all.Length; i++) {
            HideTarget@ target = Targets::all[i];
            if (target.HasSnapshot()) target.Enforce();
        }
    }

    void Tick(float dt) {
        CGamePlayground@ currentPlayground = Game::app.CurrentPlayground;

        // map changes, just restore and hide when it loads in
        if (currentPlayground !is observedPlayground) {
            if (enabled) {
                Restore();
            }

            @observedPlayground = currentPlayground;
        }

        reapplyElapsedMs += dt;

        if (reapplyElapsedMs < 250) return;

        reapplyElapsedMs = 0;

        if (minimalModeRequested && currentPlayground !is null) {
            Apply();
        } else if (HasAnySnapshot()) {
            // not active, give back anything still hidden, e.g. a plugin missing at load
            Restore();
        }
    }

    void ApplyIfRequested() {
        if (!minimalModeRequested || !Game::InMap()) return;

        Apply();
    }

    void Recover() {
        // last session didn't restore: put the originals back before anything can hide again
        if (SnapshotRepository::Load() == Storage::LoadResult::Failed) {
            string backupName = SnapshotRepository::Backup();
            Notify::Warn(SnapshotRepository::FILE_NAME + ".json failed to load and was moved to " + backupName + ".\n If another plugin's overlay stays hidden, turn it back on in that plugin's settings.");
        }

        Restore();
    }

    bool HasAnySnapshot() {
        for (uint i = 0; i < Targets::all.Length; i++) {
            HideTarget@ target = Targets::all[i];
            if (target.HasSnapshot()) return true;
        }

        return false;
    }
}