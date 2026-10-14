namespace PresetRepository {
    // constants so I don't accidentally make typos
    const string KEY_ACTIVE = "activePresetId";
    const string KEY_ID = "id";
    const string KEY_PRESETS = "presets";
    const string KEY_VERSION = "version";
    const string KEY_HIDDEN = "hidden";
    const string KEY_NAME = "name";
    const int FORMAT_VERSION = 1;

    string Path() {
        return IO::FromStorageFolder("presets.json");
    }

    Json::Value@ PresetToJson(HudPreset@ preset) {
        Json::Value@ obj = Json::Object();
        obj[KEY_ID] = preset.id;
        obj[KEY_NAME] = preset.name;
        Json::Value@ hidden = Json::Object();

        // we loop the registry, since presets could become stale on update
        for (uint i = 0; i < Targets::all.Length; i++) {
            HideTarget@ target = Targets::all[i];
            hidden[target.key] = preset.IsHidden(target.key);
        }

        obj[KEY_HIDDEN] = hidden;

        return obj;
    }

    void Save(array<HudPreset@>@ presets, const string &in activeId) {
        // we rewrite the whole file, simpler and it's only a few kb
        Json::Value@ root = Json::Object();
        root[KEY_VERSION] = FORMAT_VERSION;
        root[KEY_ACTIVE] = activeId;

        Json::Value@ list = Json::Array();

        // presets are not read from the service to not depend on it
        for (uint i = 0; i < presets.Length; i++) {
            HudPreset@ preset = presets[i];
            list.Add(PresetToJson(preset));
        }

        root[KEY_PRESETS] = list;

        Json::ToFile(Path(), root, true);
    }
}