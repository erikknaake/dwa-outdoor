export function loadPolygon(area, points) {
    area.forEach((point) => {
        points.push({
            id: points.length,
            lat: point.lat,
            lng: point.lng
        });
    })
}

export function loadGeoJson(map, points, polygon_name) {
    const geoJson = pointsAsGeoJson(points);

    map.addSource(polygon_name, {
        'type': 'geojson',
        'data': geoJson
    });
    map.addLayer({
        'id': polygon_name,
        'type': 'fill',
        'source': polygon_name,
        'layout': {},
        'paint': {
            'fill-color': '#088',
            'fill-opacity': 0.6
        }
    });

    return geoJson;
}

export function pointsAsGeoJson(points) {
    return {
        'type': 'Feature',
        'geometry': {
            'type': 'Polygon',
            'coordinates': [
                pointsToLngLatArrays(points)
            ]
        }
    }
}

export function pointsToLngLatArrays(points) {
    return points.map(x => [x.lng, x.lat]);
}

export function findCenterOfPolygon(coordinates) {
    if(coordinates == null || coordinates.length === 0) {
        return {
            lng: 6,
            lat: 52
        };
    }
    let minLng = 9999, maxLng = -9999, minLat = 9999, maxLat = -9999;
    coordinates.forEach(point => {
        if(point[0] > maxLng) {
            maxLng = point[0];
        }
        if(point[0] < minLng) {
            minLng = point[0];
        }
        if(point[1] > maxLat) {
            maxLat = point[1];
        }
        if(point[1] < minLat) {
            minLat = point[1];
        }
    });
    return {
        lng: minLng + ((maxLng - minLng) / 2),
        lat: minLat + ((maxLat - minLat) / 2)
    }
}
