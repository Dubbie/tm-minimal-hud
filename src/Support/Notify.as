namespace Notify {
    void Info(const string &in text) {
        if (!showNotifications) return;

        UI::ShowNotification("Minimal HUD", text, 2000);
    }

    void Warn(const string &in text, const string &in logText = "") {
        // warning doesn't care if the user wants no notifications.
        UI::ShowNotification("Minimal HUD", text, vec4(0.9, 0.5, 0.1, 1), 5000);

        warn(logText ==  "" ? text : logText);
    }
}