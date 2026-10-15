namespace SnapshotRepository {
    // we store snapshots so they survive an exit or crash

    const int FORMAT_VERSION = 1;
    const string KEY_VERSION = "version";
    const string KEY_TARGETS = "targets";
    const string FILE_NAME = "snapshots";

    string lastWritten = "";    // what's on disk now, so unchanged content isn't written again

    string Path() {
        return IO::FromStorageFolder(FILE_NAME + ".json");
    }

    void Save() {
        bool anyCaptured = false;
        Json::Value@ root = Json::Object();

        root[KEY_VERSION] = FORMAT_VERSION;
        root[KEY_TARGETS] = Json::Object();

        for (uint i = 0; i < Targets::all.Length; i++) {
            PluginSettingsTarget@ pluginTarget = cast<PluginSettingsTarget>(Targets::all[i]);
            if (pluginTarget is null) continue; // not a plugin, skip

            Json::Value@ entry = Json::Object();
            bool entryHasAny = false;
            for (uint j = 0; j < pluginTarget.settings.Length; j++) {
                PluginSetting@ setting = pluginTarget.settings[j];
                if (!setting.captured) continue;

                entry[setting.name] = setting.originalValue;
                entryHasAny = true;
            }

            if (entryHasAny) {
                root[KEY_TARGETS][pluginTarget.key] = entry;

                anyCaptured = true;
            }
        }

        string text = Json::Write(root);
        if (text == lastWritten) return;

        lastWritten = text;

        if (anyCaptured) {
            Json::ToFile(Path(), root, true);
        } else {
            if (IO::FileExists(Path())) {
                IO::Delete(Path());
            }
        }
    }

    Storage::LoadResult Load() {
        if (!IO::FileExists(Path())) return Storage::LoadResult::Missing;

        Json::Value@ root;
        try {
            @root = Json::FromFile(Path());
        } catch {
            return Storage::LoadResult::Failed;
        }

        if (!JsonUtil::HasField(root, KEY_VERSION, Json::Type::Number) || !JsonUtil::HasField(root, KEY_TARGETS, Json::Type::Object)) {
            return Storage::LoadResult::Failed;
        }

        int version = root[KEY_VERSION];

        // time traveling or nonsense
        if (version > FORMAT_VERSION || version < 1) {
            return Storage::LoadResult::Failed;
        }

        for (uint i = 0; i < Targets::all.Length; i++) {
            PluginSettingsTarget@ pluginTarget = cast<PluginSettingsTarget>(Targets::all[i]);
            if (pluginTarget is null) continue; // not a plugin, skip

            if (JsonUtil::HasField(root[KEY_TARGETS], pluginTarget.key, Json::Type::Object)) {
                Json::Value@ entry = root[KEY_TARGETS][pluginTarget.key];
                for (uint j = 0; j < pluginTarget.settings.Length; j++) {
                    PluginSetting@ setting = pluginTarget.settings[j];
                    if (JsonUtil::HasField(entry, setting.name, Json::Type::Boolean)) {
                        bool original = entry[setting.name];
                        setting.Seed(original);
                    }
                }
            }
        }

        return Storage::LoadResult::Loaded;
    }

    string Backup() {
        return Storage::Backup(FILE_NAME);
    }
}