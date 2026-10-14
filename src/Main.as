bool toggleKeyDown = false;

void Main() {
    Presets::Initialize();

    // presets service test
    print(Presets::all.Length); // expected: 1
    print(Presets::active.name); // expected: "Default"
    print(Presets::active.isBuiltIn); // expected: true

    for (uint i = 0; i < Targets::all.Length; i++) {
        HideTarget@ target = Targets::all[i];
        print(target.key + " " + Presets::active.IsHidden(target.key));
    }
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