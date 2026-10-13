bool toggleKeyDown = false;

void RenderMenu() {
    if (UI::MenuItem("Minimal mode", "", minimalModeRequested)) {
        MinimalMode::Toggle();
    }
}

void OnSettingsChanged() {
    toggleKeyDown = false;
}

void OnKeyPress(bool down, VirtualKey key) {
    if (key == toggleKey) {
        if (down && !toggleKeyDown) {
            toggleKeyDown = true;

            MinimalMode::Toggle();
            Notify("Minimal mode: " + (minimalModeRequested ? "enabled" : "disabled"));
        } else if (!down && toggleKeyDown) {
            toggleKeyDown = false;
        }
    }
}