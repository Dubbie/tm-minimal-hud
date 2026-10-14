bool toggleKeyDown = false;
bool cycleKeyDown = false;

void Main() {
    Presets::Initialize();
}

void Update(float dt) {
    MinimalMode::Tick(dt);
}

void RenderEarly() {
    MinimalMode::Enforce();
}

void RenderMenu() {
    if (!UI::BeginMenu("Minimal HUD")) return;

    if (UI::MenuItem("Minimal mode", "", minimalModeRequested)) MinimalMode::Toggle();

    UI::Separator();

    if (UI::MenuItem("Restore normal HUD", "", false)) {
        minimalModeRequested = false;
        MinimalMode::Restore();
        Notify::Info("Normal HUD restored");
    }

    UI::EndMenu();
}

void OnDisabled() {
    MinimalMode::Restore();
}

void OnDestroyed() {
    OnDisabled();
}

void OnSettingsChanged() {
    toggleKeyDown = false;
    cycleKeyDown = false;
}

void OnKeyPress(bool down, VirtualKey key) {
    if (key == toggleKey) {
        if (down && !toggleKeyDown) {
            toggleKeyDown = true;

            MinimalMode::Toggle();
            Notify::Info("Minimal mode: " + (minimalModeRequested ? "enabled" : "disabled"));
        } else if (!down && toggleKeyDown) {
            toggleKeyDown = false;
        }
    } else if (key == cyclePresetKey) {
        if (down && !cycleKeyDown) {
            cycleKeyDown = true;

            Presets::Cycle();

            // apply instantly so we don't have to wait 250ms
            MinimalMode::ApplyIfRequested();

            Notify::Info("Preset changed to: " + Presets::active.name);
        } else if (!down && cycleKeyDown) {
            cycleKeyDown = false;
        }
    }
}