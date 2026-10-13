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
}