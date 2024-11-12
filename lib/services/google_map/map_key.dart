
class MapKey {
  static String mapKey = "AIzaSyAcg4t_7-h6LvAaYz80KlTCrKtWhfsVCm0";
}
//Google map url
String getLatLngFromAddressUrl(adress, key) =>
    "https://maps.googleapis.com/maps/api/geocode/json?address=$adress&key=$key";
String getAddressFromlatlngUrl(lat, long, key) =>
    "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$long&key=$key";
String getRouteBetweenCoordinateUrl(latlng1, latlng2, mode, key) =>
    "https://maps.googleapis.com/maps/api/directions/json?origin=${latlng1.latitude},${latlng1.longitude}&destination=${latlng2.latitude},${latlng2.longitude}&mode=$mode&avoidHighways=false&avoidFerries=true&avoidTolls=false&key=$key";
String getTimeBetweenCoordinateUrl(latlng1, latlng2, key) => 'https://maps.googleapis.com/maps/api/distancematrix/json?origins=${latlng1.latitude},${latlng1.longitude}&destinations=${latlng2.latitude},${latlng2.longitude}&key=$key';
