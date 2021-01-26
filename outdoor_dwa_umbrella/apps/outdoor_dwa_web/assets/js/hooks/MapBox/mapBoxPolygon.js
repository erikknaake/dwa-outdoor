import mapboxgl from "mapbox-gl";
import * as polygonMethods from "./polygonMethods";
import {MAP_BOX_TOKEN} from "./accessToken";

export function decorateHooksWithMapBoxMapBoxPolygon(Hooks) {
    let markers = [];
    const POLYGON_NAME = 'GeoJson';
    const AREA_INPUT = 'areaInput';

    function createMarker(map, lat, lng, sendCoordsToLiveView) {
        let marker = new mapboxgl.Marker();
        marker.setLngLat([lng, lat]).setDraggable(true).addTo(map);
        const id = markers.length;
        marker.on('dragend', () => {
            updateGeoJson(map, sendCoordsToLiveView);
        });
        markers.push({
            id,
            lat: lat,
            lng: lng,
            marker
        });
    }

    function addNewMarker(e, map, sendCoordsToLiveView) {
        let {lat, lng} = e.lngLat;
        createMarker(map, lat, lng, sendCoordsToLiveView);
        updateGeoJson(map, sendCoordsToLiveView);
    }

    function updateGeoJson(map, sendCoordsToLiveView) {
        map.getSource(POLYGON_NAME).setData(polygonMethods.pointsAsGeoJson(pointsToLngLatObjects(markers)));
        sendCoordsToLiveView();
    }

    function pointsToLngLatObjects() {
        return markers.map(point => point.marker.getLngLat());
    }

    function loadPoints(area, map, sendCoordsToLiveView) {
        JSON.parse(area).forEach((point) => {
            createMarker(map, point.lat, point.lng, sendCoordsToLiveView);
        });
    }

    Hooks.MapBoxPolygon = {
        revertMarkerElem: document.querySelector('#revert-last-marker'),
        wrapperClasses: 'absolute z-10 top-3 right-3'.split(' '),
        defaultActionClasses: 'bg-black text-white ml-2 p-2 rounded cursor-pointer hidden'.split(' '),
        actionSpacing: 20,
        actions: [
            {
                elem: null,
                label: 'Remove last marker',
                hideWhen: () => markers.length === 0,
                triggers: [
                    {
                        event: 'click',
                        callback: (map, sendCoordsToLiveView, context) => {
                            markers.pop().marker.remove();

                            updateGeoJson(map, sendCoordsToLiveView);
                            context.updateActionsVisibility();
                        }
                    }]
            }
        ],

        initMap() {
            let def_coords = {longitude: 5.9, latitude: 52.0}

            mapboxgl.accessToken = MAP_BOX_TOKEN;
            let map = new mapboxgl.Map({
                container: 'map-box-container',
                style: 'mapbox://styles/mapbox/streets-v11',
                center: [def_coords.longitude, def_coords.latitude],
                zoom: 4
            });

            const sendCoordsToLiveView = () => this.sendCoordsToLiveView(this);

            this.registerActions(map, sendCoordsToLiveView);

            map.on('load', () => {
                const inputElem = document.getElementById(AREA_INPUT);

                if (inputElem && inputElem.value !== 'null') {
                    loadPoints(inputElem.value, map, sendCoordsToLiveView);
                }

                const geoJson = polygonMethods.loadGeoJson(map, markers, POLYGON_NAME);

                map.flyTo({
                    center: polygonMethods.findCenterOfPolygon(geoJson.geometry.coordinates[0])
                });
                this.updateActionsVisibility();
            });
        },

        registerActions(map, sendCoordsToLiveView) {
            map.on('click', (e) => {
                addNewMarker(e, map, sendCoordsToLiveView);
                this.updateActionsVisibility();
            });

            const actionsWrapper = this.createActionsWrapper();
            map._container.appendChild(actionsWrapper);

            this.actions = this.actions.map(action => {
                const actionBtn = this.createActionButton(action.label);

                action.triggers.forEach(trigger => {
                    actionBtn.addEventListener(trigger.event, () => trigger.callback(map, sendCoordsToLiveView, this))
                });

                actionsWrapper.appendChild(actionBtn)

                return {...action, elem: actionBtn};
            });
        },

        updateActionsVisibility() {
            this.actions.forEach(action => {
                action.elem.classList.toggle('hidden', action.hideWhen());
            });
        },

        createActionsWrapper() {
            const wrapper = document.createElement("div");
            wrapper.classList.add(...this.wrapperClasses);
            return wrapper;
        },
        createActionButton(label) {
            const actionBtn = document.createElement("button");
            actionBtn.classList.add(...this.defaultActionClasses);
            actionBtn.innerText = label;
            return actionBtn;
        },

        mounted() {
            this.initMap();
        },

        sendCoordsToLiveView(self) {
            self.pushEvent("new_coords", pointsToLngLatObjects());
        }
    }
}