class NativeChatTarget : HideTarget {
    bool originalHidden = false;
    bool captured = false; // hasSnapshot might get confusing since it's a method aswell

    NativeChatTarget(
        const string &in key,
        const string &in label,
        bool defaultHidden,
        const string &in tooltip = ""
    ) {
        super(key, label, "Chat", defaultHidden, tooltip);
    }

    bool Hide() override {
        CControlBase@ chat = Game::FindNativeChat();
        if (chat is null) return false;

        bool newCapture = false;

        if (!captured) {
            originalHidden = chat.IsHiddenExternal;
            captured = true;
            newCapture = true;
        }

        chat.IsHiddenExternal = true;

        return newCapture;
    }

    void Restore() override {
        if (!captured) return;

        CControlBase@ chat = Game::FindNativeChat();

        if (chat !is null) {
            chat.IsHiddenExternal = originalHidden;
        }

        captured = false;
    }

    bool HasSnapshot() override { return captured; }

    /* we are skipping Enforce for chat, as recursive lookup is possibly too expensive */
}