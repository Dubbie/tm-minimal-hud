class BetterChatTarget : PluginSettingsTarget {
    BetterChatTarget(
        const string &in key,
        const string &in label,
        bool defaultHidden,
        const string &in tooltip = ""
    ) {
        super(key, label, defaultHidden, "Better Chat", { "Setting_HideWithOP" }, tooltip);

        // these are wrong in the parent for Better Chat, so overwrite them
        hiddenValue = true;
        group = "Chat";
    }
}