import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationService {
  // Check and request location permissions
  Future<bool> handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Optionally, prompt the user to enable location services (e.g., via dialog)
      return false;
    }
    PermissionStatus permission = await Permission.location.request();
    if (permission == PermissionStatus.permanentlyDenied) {
      // Optionally, open app settings if permanently denied
      // await openAppSettings();
      return false;
    }
    return permission == PermissionStatus.granted;
  }

  // Start broadcasting courier's location to Firestore
  Future<void> startLocationUpdates(String courierId, String rideId) async {
    bool hasPermission = await handleLocationPermission();
    if (!hasPermission) {
      // Handle permission denied (e.g., show a dialog or log the issue)
      return;
    }

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update only when courier moves 10 meters
    );

    Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      FirebaseFirestore.instance.collection('rides').doc(rideId).update({
        'courierLocation': {
          'lat': position.latitude,
          'lng': position.longitude,
        },
        'timestamp': FieldValue.serverTimestamp(),
      }).catchError((error) {
        // Handle Firestore update errors (e.g., log or notify)
        print('Error updating location: $error');
      });
    }, onError: (error) {
      // Handle location stream errors
      print('Location stream error: $error');
    });
  }

  // Stop location updates (optional, to conserve resources)
  void stopLocationUpdates() {
    Geolocator.getPositionStream().drain(); // Stops the stream
  }
}