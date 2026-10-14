bool toggleKeyDown = false;
bool cycleKeyDown = false;

void TestPreset(const string &in json) {
    HudPreset@ p = PresetRepository::PresetFromJson(Json::Parse(json));
    if (p is null) {
        print("null");
        return;
    }
    print(p.id + " | " + p.name + " | builtIn=" + p.isBuiltIn
        + " | hideRecords=" + p.IsHidden("hideRecords")
        + " | hideTimeGap=" + p.IsHidden("hideTimeGap"));
}

void Main() {
    Presets::Initialize();

    // Test JSON parsing
    TestPreset('{"id":"custom-1","name":"A","hidden":{"hideRecords":false}}');
    TestPreset('{"id":"custom-2","name":"B"}');
    TestPreset('{"id":"custom-3","name":"C","hidden":{"hideRecords":"yes"}}');
    TestPreset('{"id":"custom-4","name":"D","hidden":{"hideSomethingRemoved":true}}');
    TestPreset('{"name":"E"}');
    TestPreset('{"id":"","name":"F"}');
    TestPreset('{"id":"custom-7","name":42}');
    TestPreset('{"id":"default","name":"Hacked","hidden":{"hideRecords":false}}');
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