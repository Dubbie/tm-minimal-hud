namespace Game {
    CTrackMania@ get_app() { return cast<CTrackMania>(GetApp()); }

    CGameManialinkControl@ FindNativeControl(const string &in id) {
        if (app is null) return null;

        CTrackManiaNetwork@ network = cast<CTrackManiaNetwork>(app.Network);
        if (network is null) return null;

        CGameManiaAppPlayground@ playground = network.ClientManiaAppPlayground;
        if (playground is null) return null;

        MwFastBuffer<CGameUILayer@> layers = playground.UILayers;

        for (uint i = 0; i < layers.Length; i++) {
            CGameUILayer@ layer = layers[i];
            if (layer is null) continue;

            CGameManialinkPage@ page = layer.LocalPage;
            if (page is null) continue;

            CGameManialinkControl@ control = page.GetFirstChild(id);
            if (control !is null) return control;
        }

        return null;
    }

    CControlBase@ FindInContainer(CControlContainer@ container, const string &in id) {
        if (container is null) return null;

        for (uint i = 0; i < container.Childs.Length; i++) {
            CControlBase@ child = container.Childs[i];
            if (child is null) continue;

            if (child.IdName == id) return child;

            CControlContainer@ nested = cast<CControlContainer>(child);
            if (nested is null) continue;

            CControlBase@ found = FindInContainer(nested, id);
            if (found !is null) return found;
        }

        return null;
    }

    CControlBase@ FindNativeChat() {
        if (app is null) return null;

        CGamePlayground@ playground = app.CurrentPlayground;
        if (playground is null) return null;

        CGamePlaygroundInterface@ gameInterface = playground.Interface;
        if (gameInterface is null) return null;

        CControlContainer@ root = gameInterface.InterfaceRoot;
        if (root is null) return null;

        return FindInContainer(root, "FrameChat");
    }

    Meta::Plugin@ FindPlugin(const string &in name) {
        array<Meta::Plugin@> plugins = Meta::AllPlugins();

        for (uint i = 0; i < plugins.Length; i++) {
            Meta::Plugin@ plugin = plugins[i];
            if (plugin is null) continue;

            if (plugin.Name == name) return plugin;
        }

        return null;
    }
}