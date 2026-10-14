namespace Presets {
    array<HudPreset@> all;
    HudPreset@ active;
    bool initialized = false;

    void FillDefaults(HudPreset@ preset) {
        for (uint i = 0; i < Targets::all.Length; i++) {
            HideTarget@ tgt = Targets::all[i];
            preset.SetHidden(tgt.key, tgt.defaultHidden);
        }
    }

    HudPreset@ BuildDefault() {
        HudPreset@ preset = HudPreset("default", "Default", true);
        FillDefaults(preset);
        return preset;
    }

    void Initialize() {
        if (initialized) return;
        initialized = true;

        Targets::Register(); // moved from main

        all.InsertLast(BuildDefault());
        @active = all[0]; // active should always point into all, and not make a new copy!
    }

    void Save() {
        // stub for now
    }
}