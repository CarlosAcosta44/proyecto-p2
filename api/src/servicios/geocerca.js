// Haversine: distancia sobre la superficie terrestre, en metros.
export function distanciaMetros(lat1, lon1, lat2, lon2) {
 const R = 6371000;
 const rad = (g) => g * Math.PI / 180;
 const dLat = rad(lat2 - lat1);
 const dLon = rad(lon2 - lon1);
 const a = Math.sin(dLat/2)**2 +
           Math.cos(rad(lat1)) * Math.cos(rad(lat2)) * Math.sin(dLon/2)**2;
 return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}
