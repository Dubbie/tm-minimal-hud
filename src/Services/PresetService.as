namespace Presets {
    array<HudPreset@> all;
    HudPreset@ active;
    bool initialized = false;

    // BuildDefault and ResetDefault use this
    void FillDefaults(HudPreset@ preset) {
        for (uint i = 0; i < Targets::all.Length; i++) {
            HideTarget@ tgt = Targets::all[i];
            preset.SetHidden(tgt.key, tgt.defaultHidden);
        }
    }

    bool IsTaken(const string &in id, const string &in name) {
        // check if this id or name exists in any preset
        for (uint i = 0; i < all.Length; i++) {
            HudPreset@ preset = all[i];
            if (preset.id == id || preset.name == name) return true;
        }
        return false;
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

    void ResetDefault() {
        FillDefaults(all[0]);
        Save();
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

    HudPreset@ Create() {
        string id;
        string name = NextFreeName(id);

        HudPreset@ preset = active.CopyAs(id, name);

        all.InsertLast(preset);
        Select(preset);

        return preset;
    }

    string Rename(HudPreset@ preset, const string &in newName) {
        if (preset.isBuiltIn) return "Default can't be renamed.";
        if (newName == "") return "Name can't be empty.";
        // TODO: names consisting of only spaces are allowed

        for (uint i = 0; i < all.Length; i++) {
            HudPreset@ other = all[i];
            if (other !is preset && other.name == newName) return "A preset with that name already exists.";
        }

        preset.name = newName;
        Save();

        return "";
    }

    void Delete(HudPreset@ preset) {
        // guard in case ui allows deleting built in
        if (preset.isBuiltIn) return;

        bool wasActive = preset is active;

        all.RemoveAt(all.FindByRef(preset));

        if (wasActive) {
            Select(all[0]);
        } else {
            Save();
        }
    }

    void SetHidden(const string &in key, bool value) {
        active.SetHidden(key, value);
        Save();
    }

    string NextFreeName(string &out id) {
        uint n = 1;
        string nextId = "custom-" + n;
        string nextName = "Custom preset " + n;

        while (IsTaken(nextId, nextName)) {
            n++;
            nextId = "custom-" + n;
            nextName = "Custom preset " + n;
        }

        id = nextId;

        return nextName;
    }

    void Save() {
        // stub for now
    }
}