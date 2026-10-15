namespace PresetRepository {
    const string KEY_ACTIVE = "activePresetId";
    const string KEY_ID = "id";
    const string KEY_PRESETS = "presets";
    const string KEY_VERSION = "version";
    const string KEY_HIDDEN = "hidden";
    const string KEY_NAME = "name";
    const string FILE_NAME = "presets";
    const int FORMAT_VERSION = 1;

    string Path() {
        return IO::FromStorageFolder(FILE_NAME + ".json");
    }

    bool ContainsId(array<HudPreset@>@ list, const string &in id) {
        for (uint i = 0; i < list.Length; i++) {
            HudPreset@ preset = list[i];
            if (preset.id == id) return true;
        }
        return false;
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

    HudPreset@ PresetFromJson(const Json::Value@ data) {
        if (!JsonUtil::HasField(data, KEY_ID, Json::Type::String) || !JsonUtil::HasField(data, KEY_NAME, Json::Type::String)) return null;

        string id = data[KEY_ID];
        string name = data[KEY_NAME];

        // can't identify, can't show name in dropdown
        if (id == "" || name == "") return null;

        HudPreset@ preset = null;
        if (id == "default") {
            @preset = HudPreset("default", "Default", true);
        } else {
            @preset = HudPreset(id, name);
        }

        bool hasHidden = JsonUtil::HasField(data, KEY_HIDDEN, Json::Type::Object);

        // iterate registry so we have all possible keys with values, unknown keys are ignored automatically
        for (uint i = 0; i < Targets::all.Length; i++) {
            HideTarget@ target = Targets::all[i];
            bool value = target.defaultHidden; // handles missing entirely, missing key and wrong type

            if (hasHidden && JsonUtil::HasField(data[KEY_HIDDEN], target.key, Json::Type::Boolean)) {
                value = data[KEY_HIDDEN][target.key];
            }

            preset.SetHidden(target.key, value);
        }

        return preset;
    }

    Storage::LoadResult Load(array<HudPreset@>@ into, string &out activeId) {
        activeId = "";

        if (!IO::FileExists(Path())) return Storage::LoadResult::Missing;

        Json::Value@ root;
        try {
            @root = Json::FromFile(Path());
        } catch {
            return Storage::LoadResult::Failed;
        }

        if (!JsonUtil::HasField(root, KEY_VERSION, Json::Type::Number) || !JsonUtil::HasField(root, KEY_PRESETS, Json::Type::Array)) {
            return Storage::LoadResult::Failed;
        }

        int version = root[KEY_VERSION];

        // time traveling or nonsense
        if (version > FORMAT_VERSION || version < 1) {
            return Storage::LoadResult::Failed;
        }

        if (JsonUtil::HasField(root, KEY_ACTIVE, Json::Type::String)) {
            activeId = root[KEY_ACTIVE];
        }

        for (uint i = 0; i < root[KEY_PRESETS].Length; i++) {
            HudPreset@ preset = PresetFromJson(root[KEY_PRESETS][i]);
            if (preset is null) {
                Notify::Warn("Failed to load preset, see log", "Failed to load preset: " + Json::Write(root[KEY_PRESETS][i]));
                continue;
            }

            // if preset with same id is already in into, skip it
            if (ContainsId(into, preset.id)) {
                Notify::Warn("Preset with id already exists: " + preset.id);
                continue;
            }

            into.InsertLast(preset);
        }

        return Storage::LoadResult::Loaded;
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

    string Backup() {
        return Storage::Backup(FILE_NAME);
    }
}