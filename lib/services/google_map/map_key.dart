
class MapKey {//
  static String mapKey = "AIzaSyC9FPLBwpCIQIRVERrlmHv94qv4u9zmILw";
}
//Google map url
String getLatLngFromAddressUrl(address, key) =>
    "https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$key";
String getAddressFromlatlngUrl(lat, long, key) =>
    "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$long&key=$key";
String getRouteBetweenCoordinateUrl(latlng1, latlng2, mode, key) =>
    "https://maps.googleapis.com/maps/api/directions/json?origin=${latlng1.latitude},${latlng1.longitude}&destination=${latlng2.latitude},${latlng2.longitude}&mode=$mode&avoidHighways=false&avoidFerries=true&avoidTolls=false&key=$key";
String getTimeBetweenCoordinateUrl(latlng1, latlng2, key) => 'https://maps.googleapis.com/maps/api/distancematrix/json?origins=${latlng1.latitude},${latlng1.longitude}&destinations=${latlng2.latitude},${latlng2.longitude}&key=$key';
