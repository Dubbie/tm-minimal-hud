[SettingsTab name="HUD"]
void RenderSettingsTab() {
    SettingsView::Render();
}

namespace SettingsView {
    void Render() {
        if (Presets::active is null) return;

        if (UI::BeginCombo("Presets", Presets::active.name)) {
            for (uint i = 0; i < Presets::all.Length; i++) {
                HudPreset@ preset = Presets::all[i];
                string selectLabel = preset.name + "###preset-" + preset.id;

                if (UI::Selectable(selectLabel, preset is Presets::active)) {
                    Presets::Select(preset);
                }
            }

            UI::EndCombo();
        }

        UI::SameLine();

        if (UI::Button("Create preset")) Presets::Create();

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
        }
    }
}