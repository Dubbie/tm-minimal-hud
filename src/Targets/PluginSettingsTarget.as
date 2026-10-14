class PluginSetting {
    string name;
    bool originalValue = false;
    bool captured = false;

    PluginSetting(const string &in name) { this.name = name; }
}

class PluginSettingsTarget : HideTarget {
    string pluginName = "";             // "Dashboard"
    array<PluginSetting@> settings;
    bool hiddenValue = false;           // value written while hidden, most likely false

    PluginSettingsTarget(
        const string &in key,
        const string &in label,
        bool defaultHidden,
        const string &in pluginName,
        const array<string> &in settingNames,
        const string &in tooltip = ""
    ) {
        super(key, label, Targets::GROUP_PLUGIN_OVERLAYS, defaultHidden, tooltip);
        this.pluginName = pluginName;
        this.tooltip = tooltip != "" ? tooltip : "Requires the " + pluginName + " plugin.";

        for (uint i = 0; i < settingNames.Length; i++) {
            settings.InsertLast(PluginSetting(settingNames[i]));
        }
    }

    bool IsAvailable() override {
        Meta::Plugin@ plugin = Game::FindPlugin(pluginName);
        if (plugin is null || !plugin.Enabled) return false;

        return true;
    }

    bool Hide() override {
        Meta::Plugin@ plugin = Game::FindPlugin(pluginName);
        if (plugin is null || !plugin.Enabled) return false;

        bool newCapture = false;

        for (uint i = 0; i < settings.Length; i++) {
            PluginSetting@ setting = settings[i];

            Meta::PluginSetting@ ps = plugin.GetSetting(setting.name);
            if (ps is null || ps.TypeName != "bool") continue;

            // capture once, the first time we hide. second capture would save our own hidden value as "original" and would break it
            if (!setting.captured) {
                setting.originalValue = ps.ReadBool();
                setting.captured = true;
                newCapture = true;
            }

            // only write when it differs, every write is a settings save in their plugin
            if (ps.ReadBool() != hiddenValue) {
                ps.WriteBool(hiddenValue);
            }
        }

        return newCapture;
    }

    void Restore() override {
        Meta::Plugin@ plugin = Game::FindPlugin(pluginName);
        // plugin is missing: keep snapshot, settings are saved to disk, restore them once the plugin is back
        if (plugin is null) return;

        for (uint i = 0; i < settings.Length; i++) {
            PluginSetting@ setting = settings[i];
            if (!setting.captured) continue;

            Meta::PluginSetting@ ps = plugin.GetSetting(setting.name);
            if (ps is null || ps.TypeName != "bool") continue;

            if (ps.ReadBool() != setting.originalValue) {
                ps.WriteBool(setting.originalValue);
            }

            setting.captured = false;
        }
    }

    bool HasSnapshot() override {
        for (uint i = 0; i < settings.Length; i++) {
            PluginSetting@ setting = settings[i];
            if (setting.captured) return true;
        }
        return false;
    }

    /* re-hide happens in Hide, settings don't flip like game UI does */
}