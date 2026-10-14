bool toggleKeyDown = false;

void Main() {
    Targets::Register();

    // preset test
    HudPreset@ testPreset = HudPreset("test", "Test");
    testPreset.SetHidden("hideRecords", true);

    print(testPreset.IsHidden("hideRecords"));
    print(testPreset.IsHidden("randomThing"));

    HudPreset@ copiedPreset = testPreset.CopyAs("copied", "Copied");
    copiedPreset.SetHidden("hideRecords", false);
    print(testPreset.IsHidden("hideRecords"));
    print(copiedPreset.IsHidden("hideRecords"));
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
    }
}