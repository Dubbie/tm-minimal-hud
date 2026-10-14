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

    HudPreset@ FindById(array<HudPreset@>@ list, const string &in id) {
        for (uint i = 0; i < list.Length; i++) {
            HudPreset@ preset = list[i];
            if (preset.id == id) return preset;
        }
        return null;
    }

    void Initialize() {
        // setup
        if (initialized) return;
        initialized = true;
        Targets::Register();

        // reading stuff
        array<HudPreset@> loaded;
        string activeId;
        PresetRepository::LoadResult result = PresetRepository::Load(loaded, activeId); // this sets up both loaded and activeId

        // find default preset
        HudPreset@ defaultPreset = FindById(loaded, "default");

        if (defaultPreset is null) {
            @defaultPreset = BuildDefault(); // file had no default
        } else {
            loaded.RemoveAt(loaded.FindByRef(defaultPreset)); // take it out of loaded as we will iterate next
        }

        // assembling the list + active selecting
        all.InsertLast(defaultPreset);
        for (uint i = 0; i < loaded.Length; i++) {
            all.InsertLast(loaded[i]);
        }
        HudPreset@ saved = FindById(all, activeId);
        @active = saved is null ? all[0] : saved;

        // handle load results
        if (result == PresetRepository::LoadResult::Missing) {
            Save();
        } else if (result == PresetRepository::LoadResult::Failed) {
            // move the file out of the way before saving, so it's not overwritten
            string backupName = PresetRepository::Backup();
            Notify::Warn("presets.json could not be read and was moved to " + backupName + ". Using default presets.");
            Save();
        } // loaded has nothing to do
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
        string trimmed = newName.Trim();
        if (trimmed == "") return "Name can't be empty.";

        for (uint i = 0; i < all.Length; i++) {
            HudPreset@ other = all[i];
            if (other !is preset && other.name == trimmed) return "A preset with that name already exists.";
        }

        preset.name = trimmed;
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
        PresetRepository::Save(all, active.id);
    }
}