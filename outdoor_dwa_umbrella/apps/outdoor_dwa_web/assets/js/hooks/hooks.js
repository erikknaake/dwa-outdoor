import {decorateHooksWithMapBoxMarker} from "./MapBox/mapBoxMarker";
import {decorateHookWithTokens} from "./token";
import {decorateHooksWithCountdown} from "./countdown";
import {decorateHooksWithImageLoaded} from "./file-validation/reviewImageLoaded";
import {decorateHooksWithMapBoxMapBoxPolygon} from "./MapBox/mapBoxPolygon";

export function createHooks() {
    let Hooks = {}

    decorateHooksWithMapBoxMarker(Hooks);
    decorateHooksWithMapBoxMapBoxPolygon(Hooks);
    decorateHookWithTokens(Hooks);
    decorateHooksWithCountdown(Hooks);
    decorateHooksWithImageLoaded(Hooks);
    return Hooks;
}
