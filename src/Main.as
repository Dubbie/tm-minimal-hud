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

    // presets service test
    if (UI::MenuItem("DEBUG: create preset")) {
        Presets::Create();
    }

    if (UI::MenuItem("DEBUG: delete active")) {
        Presets::Delete(Presets::active);
    }

    if (UI::MenuItem("DEBUG: rename active")) {
        string errorMessage = Presets::Rename(Presets::active, "Renamed");
        print("Message after rename: " + errorMessage);
    }

    if (UI::MenuItem("DEBUG: reset Default")) {
        Presets::ResetDefault();
    }

    if (UI::MenuItem("DEBUG: flip Records")) {
        Presets::SetHidden("hideRecords", !Presets::active.IsHidden("hideRecords"));
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