import mapboxgl from "mapbox-gl";
import * as polygonMethods from "./polygonMethods";

export function decorateHooksWithMapBoxMarker(Hooks) {
    let points = [];
    let editable = true;
    const POLYGON_NAME = 'GeoJson';

    function showPolygon(reply, marker, map) {
        editable = false;

        polygonMethods.loadPolygon(reply.area, points)

        if (reply.lngLat !== null) {
            marker.setLngLat([reply.lngLat.lng, reply.lngLat.lat]).setDraggable(editable).addTo(map);
        } else {
            marker.remove();
        }


        const geoJson = polygonMethods.loadGeoJson(map, points, POLYGON_NAME);
        map.flyTo({
            center: polygonMethods.findCenterOfPolygon(geoJson.geometry.coordinates[0])
        });
    }

    Hooks.MapBox = {
        initMap() {
            let self = this;
            let def_coords = {longitude: 5.9, latitude: 52.0};

            mapboxgl.accessToken = 'pk.eyJ1IjoiYm9ubm92b29yamFucyIsImEiOiJja2h2ejZiY3kxYzN5MnJwaXE1Yng0aXAwIn0.y4YtW9Ud-WaT940YbYMucA';
            let map = new mapboxgl.Map({
                container: 'map-box-container',
                style: 'mapbox://styles/mapbox/streets-v11',
                center: [def_coords.longitude, def_coords.latitude], // starting position [lng, lat]
                zoom: 4 // starting zoom
            });

            map.addControl(new mapboxgl.FullscreenControl());

            let marker = new mapboxgl.Marker()
            self.pushEvent("request_coords", def_coords, (reply, _ref) => {
                if(!reply.longitude && !reply.latitude) {
                    reply = {longitude: def_coords.longitude, latitude: def_coords.latitude}
                }

                map.setCenter([reply.longitude, reply.latitude])
                marker.setLngLat([reply.longitude, reply.latitude]).setDraggable(editable).addTo(map)
            });

            marker.on('dragend', sendCoordsToLiveView);
            map.on('click', function (e) {
                if (editable) {
                    let {lat, lng} = e.lngLat
                    marker.setLngLat([lng, lat]).setDraggable(true).addTo(map);
                    sendCoordsToLiveView()
                }
            });

            function sendCoordsToLiveView() {
                let lngLat = marker.getLngLat();
                self.pushEvent("send_new_coords", {longitude: lngLat.lng, latitude: lngLat.lat});
            }

            return {marker, map};
        },

        mounted() {
            let {marker, map} = this.initMap();

            this.handleEvent("show_polygon", (reply) => {
                if (reply.on_page_load) {
                    map.on('load', () => { showPolygon(reply, marker, map) })
                } else {
                    showPolygon(reply, marker, map)
                }
            });

            this.handleEvent("load_coords", (reply) => {
                map.setCenter([reply.longitude, reply.latitude])
                marker.setLngLat([reply.longitude, reply.latitude]).setDraggable(true).addTo(map);
            });
        }
    }
}