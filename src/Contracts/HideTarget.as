abstract class HideTarget {
    string key;     // "hideRecords", also the presets.json key
    string label;   // "Hide Records"
    string group;   // "Native HUD" | "Plugin overlays" | "Chat"
    string tooltip;
    bool defaultHidden;

    HideTarget(
        const string &in key,
        const string &in label,
        const string &in group,
        bool defaultHidden,
        const string &in tooltip = ""
    ) {
        this.key = key;
        this.label = label;
        this.group = group;
        this.tooltip = tooltip;
        this.defaultHidden = defaultHidden;
    }

    bool IsAvailable() { return true; }
    bool Hide() { return false; }
    void Restore() {}
    void Enforce() {}
    bool HasSnapshot() { return false; }
}