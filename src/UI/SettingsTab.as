[SettingsTab name="HUD"]
void RenderSettingsTab() {
    SettingsView::Render();
}

namespace SettingsView {
    bool renaming = false;
    bool focusInput = false;
    string nameBuffer = "";
    string renameError = "";
    string renamingId = ""; // needed in case user cycles preset while renaming

    string armedKey = "";
    uint64 armedAt = 0;

    void Render() {
        if (Presets::active is null) return;

        // cancel handling
        if (renaming && renamingId != Presets::active.id) {
            renaming = false;
        }

        if (armedKey != "" && Time::Now - armedAt > 3000) {
            armedKey = "";
        }

        if (!renaming) {
            UI::SetNextItemWidth(240);

            if (UI::BeginCombo("Presets", Presets::active.name)) {
                for (uint i = 0; i < Presets::all.Length; i++) {
                    HudPreset@ preset = Presets::all[i];
                    string selectLabel = preset.name + "###preset-" + preset.id;

                    if (UI::Selectable(selectLabel, preset is Presets::active) && preset !is Presets::active) {
                        Presets::Select(preset);
                        MinimalMode::ApplyIfRequested();
                    }
                }

                UI::EndCombo();
            }

            UI::SameLine();

            if (UI::Button("Create preset")) {
                Presets::Create();
                StartRename();
            }

            UI::SameLine();

            UI::BeginDisabled(Presets::active.isBuiltIn);
            if (UI::Button("Rename preset")) StartRename();
            UI::EndDisabled();

            if (Presets::active.isBuiltIn && UI::IsItemHovered(UI::HoveredFlags::AllowWhenDisabled)) {
                UI::SetTooltip("You can't rename the built in preset.");
            }

            UI::SameLine();

            if (Presets::active.isBuiltIn) {
                if (ConfirmButton("Reset to defaults", "reset-default")) {
                    Presets::ResetDefault();
                    MinimalMode::ApplyIfRequested();
                }

                if (UI::IsItemHovered()) {
                    UI::SetTooltip("Reset the default preset to its original state.");
                }
            } else {
                if (ConfirmButton("Delete preset", "delete-" + Presets::active.id)) {
                    Presets::Delete(Presets::active);
                    MinimalMode::ApplyIfRequested();
                }
            }
        } else {
            UI::SetNextItemWidth(240);

            if (focusInput) {
                UI::SetKeyboardFocusHere();
                focusInput = false;
            }

            bool enterPressed = false;
            nameBuffer = UI::InputText("Preset name", nameBuffer, enterPressed, UI::InputTextFlags::EnterReturnsTrue);
            if (enterPressed) TrySave();

            UI::SameLine();

            if (UI::Button("Save")) {
                TrySave();
            }

            UI::SameLine();

            if (UI::Button("Cancel")) {
                renaming = false;
                renameError = "";
            }

            // error handling
            if (renameError != "") {
                UI::Text("\\$f66" + renameError);
            }
        }

        array<string> groups = Targets::Groups();

        for (uint i = 0; i < groups.Length; i++) {
            string group = groups[i];

            UI::SeparatorText(group);
            for (uint j = 0; j < Targets::all.Length; j++) {
                HideTarget@ target = Targets::all[j];
                if (target.group != group) continue;

                RenderTarget(target);
            }
        }
    }

    void RenderTarget(HideTarget@ target) {
        bool current = Presets::active.IsHidden(target.key);
        bool available = target.IsAvailable();

        // build the label with availability
        string label = target.label;
        if (!available) {
            label += " (not available)";
        }
        label += "###" + target.key;

        UI::BeginDisabled(!available);
        bool next = UI::Checkbox(label, current);
        UI::EndDisabled();

        // IsItemHovered uses previous control
        if (target.tooltip != "" && UI::IsItemHovered()) {
            UI::SetTooltip(target.tooltip);
        }

        if (next != current) {
            Presets::SetHidden(target.key, next);
            MinimalMode::ApplyIfRequested();
        }
    }

    void StartRename() {
        nameBuffer = Presets::active.name;
        renameError = "";
        renamingId = Presets::active.id;
        renaming = true;

        // focus the input
        focusInput = true;

        // fixes clicking arm delete, clicking rename, cancelling within the timelimit (would delete in 1 click)
        armedKey = "";
    }

    void TrySave() {
        string error = Presets::Rename(Presets::active, nameBuffer);

        if (error == "") {
            renaming = false;
        } else {
            renameError = error;
            focusInput = true;
        }
    }

    bool ConfirmButton(const string &in label, const string &in key) {
        bool armed = armedKey == key;

        // build label
        string btnLabel = armed ? "Are you sure?" : label;
        btnLabel += "###" + key;

        // draw button
        if (armed) {
            if (UI::ButtonColored(btnLabel, 0.0f)) {
                armedKey = "";
                return true;
            }
        } else {
            if (UI::Button(btnLabel)) {
                armedKey = key;
                armedAt = Time::Now;
            }
        }

        return false;
    }
}