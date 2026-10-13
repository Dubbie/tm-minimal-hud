void Notify(const string &in text) {
    if (!showNotifications) return;

    UI::ShowNotification("Minimal HUD", text, 2000);
}