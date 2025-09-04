import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class MapUtils {
  /// Opens a map location in the user's preferred map application
  static Future<bool> openMap(double latitude, double longitude, {String? label}) async {
    String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    
    if (label != null && label.isNotEmpty) {
      googleMapsUrl += '&query_place_id=$label';
    }
    
    final Uri uri = Uri.parse(googleMapsUrl);
    
    try {
      // Launch in external application for better experience
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Error opening map: $e');
      return false;
    }
  }

  /// Opens a map showing directions to a location
  static Future<bool> openDirections(double latitude, double longitude, {String? destinationName}) async {
    String destination = '$latitude,$longitude';
    
    if (destinationName != null && destinationName.isNotEmpty) {
      // Use destination name if provided (URL encoded)
      destination = Uri.encodeComponent(destinationName);
    }
    
    final String googleMapsDirectionsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$destination';
    final Uri uri = Uri.parse(googleMapsDirectionsUrl);
    
    try {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Error opening directions: $e');
      return false;
    }
  }
  
  /// Opens a map view inside the app using MapPickerPage
  static void openMapView(BuildContext context, LatLng location, {Function(String, double, double)? onLocationSelected}) {
    // Implementation will depend on your app's map widget
  }
}
