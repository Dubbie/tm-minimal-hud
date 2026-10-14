class ControlSnapshot {
    string id;
    bool originalVisible = false;
    bool captured = false;

    ControlSnapshot(const string &in id) { this.id = id; }
}

class NativeHudTarget : HideTarget {
    array<ControlSnapshot@> controls;

    NativeHudTarget(
        const string &in key,
        const string &in label,
        bool defaultHidden,
        const array<string> &in ids,
        const string &in tooltip = ""
    ) {
        super(key, label, Targets::GROUP_NATIVE_HUD, defaultHidden, tooltip);

        for (uint i = 0; i < ids.Length; i++) {
            controls.InsertLast(ControlSnapshot(ids[i]));
        }
    }

    bool Hide() override {
        bool newCapture = false;

        for (uint i = 0; i < controls.Length; i++) {
            ControlSnapshot@ snapshot = controls[i];
            CGameManialinkControl@ control = Game::FindNativeControl(snapshot.id);
            if (control is null) continue;

            if (!snapshot.captured) {
                snapshot.originalVisible = control.Visible;
                snapshot.captured = true;
                newCapture = true;
            }

            control.Visible = false;
        }

        return newCapture;
    }

    void Restore() override {
        for (uint i = 0; i < controls.Length; i++) {
            ControlSnapshot@ snapshot = controls[i];
            if (!snapshot.captured) continue;

            CGameManialinkControl@ control = Game::FindNativeControl(snapshot.id);

            if (control !is null) {
                control.Visible = snapshot.originalVisible;
            }

            snapshot.captured = false;
        }
    }

    void Enforce() override {
        for (uint i = 0; i < controls.Length; i++) {
            ControlSnapshot@ snapshot = controls[i];
            if (!snapshot.captured) continue;

            CGameManialinkControl@ control = Game::FindNativeControl(snapshot.id);
            if (control !is null && control.Visible) {
                control.Visible = false;
            }
        }
    }

    bool HasSnapshot() override {
        for (uint i = 0; i < controls.Length; i++) {
            ControlSnapshot@ snapshot = controls[i];
            if (snapshot.captured) return true;
        }
        return false;
    }
}