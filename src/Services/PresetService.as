namespace Presets {
    array<HudPreset@> all;
    HudPreset@ active;
    bool initialized = false;

    // should be private
    void FillDefaults(HudPreset@ preset) {
        for (uint i = 0; i < Targets::all.Length; i++) {
            HideTarget@ tgt = Targets::all[i];
            preset.SetHidden(tgt.key, tgt.defaultHidden);
        }
    }

    void Initialize() {
        if (initialized) return;
        initialized = true;

        Targets::Register(); // moved from main

        all.InsertLast(BuildDefault());
        @active = all[0]; // active should always point into all, and not make a new copy!
    }

    HudPreset@ BuildDefault() {
        HudPreset@ preset = HudPreset("default", "Default", true);
        FillDefaults(preset);
        return preset;
    }

    void Select(HudPreset@ preset) {
        @active = preset;
        Save();
    }

    void Cycle() {
        int index = all.FindByRef(active);
        int next = (index + 1) % all.Length;
        Select(all[next]);
    }

    void Save() {
        // stub for now
    }
}