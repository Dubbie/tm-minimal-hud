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

    // preset repo test
    if (UI::MenuItem("DEBUG: preset save test")) {
        Presets::Create();                                  // Custom preset 1, selected
        Presets::SetHidden("hideTimeGap", true);
        Presets::Create();                                  // Custom preset 2, copy of 1
        Presets::Rename(Presets::active, "Streaming");
    }

    if (UI::MenuItem("Restore normal HUD", "", false)) {
        minimalModeRequested = false;
        MinimalMode::Restore();
        Notify("Normal HUD restored");
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
    } else if (key == cyclePresetKey) {
        if (down && !cycleKeyDown) {
            cycleKeyDown = true;

            Presets::Cycle();

            // apply instantly so we don't have to wait 250ms
            if (minimalModeRequested) {
                MinimalMode::Apply();
            }

            Notify("Preset changed to: " + Presets::active.name);
        } else if (!down && cycleKeyDown) {
            cycleKeyDown = false;
        }
    }
}