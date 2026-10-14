class BetterChatTarget : PluginSettingsTarget {
    BetterChatTarget(
        const string &in key,
        const string &in label,
        bool defaultHidden,
        const string &in tooltip = "Better Chat shows while the Openplanet overlay (F3) is open."
    ) {
        super(key, label, defaultHidden, "Better Chat", { "Setting_HideWithOP" }, tooltip);

        // Better Chat is hidden when Setting_HideWithOP is true, invert the default hidden value
        hiddenValue = true;
        group = Targets::GROUP_CHAT;
    }
}