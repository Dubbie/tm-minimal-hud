class HudPreset {
    string id;
    string name;
    bool isBuiltIn;
    dictionary hidden;

    HudPreset(const string &in id, const string &in name, bool isBuiltIn = false) {
        this.id = id;
        this.name = name;
        this.isBuiltIn = isBuiltIn;
        this.hidden = dictionary();
    }

    bool IsHidden(const string &in key) {
        // missing key should return false as a safety net
        bool value = false;
        if (!hidden.Get(key, value)) return false;

        return value;
    }

    void SetHidden(const string &in key, bool value) {
        hidden.Set(key, value);
    }

    HudPreset@ CopyAs(const string &in newId, const string &in newName) {
        HudPreset@ newPreset = HudPreset(newId, newName, false);

        array<string>@ keys = hidden.GetKeys(); // we are not making a copy of the keys
        for (uint i = 0; i < keys.Length; i++) {
            bool value = false;
            hidden.Get(keys[i], value);
            newPreset.SetHidden(keys[i], value);
        }

        return newPreset;
    }
}