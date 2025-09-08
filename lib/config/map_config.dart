import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapConfig {
  // API key configuration (kept for backward compatibility)
  static String get apiKey => dotenv.env['STADIA_API_KEY'] ?? '';
  
  // Base tile URL for CartoDB
  static String get tileUrl => 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png';
  
  // Attribution text for CartoDB
  static String get attribution => '© CARTO | © OpenStreetMap contributors';
  
  // Geocoding API (still using StadiaMaps for now)
  static String get geocodingUrl => 'https://api.stadiamaps.com/geocoding/v1';
  
  // Routing API (still using StadiaMaps for now)
  static String get routingUrl => 'https://api.stadiamaps.com/routing/v1/route';
  
  // Function to build headers with API key
  static Map<String, String> get headers => {
    'Authorization': 'Api-Key $apiKey',
    'Content-Type': 'application/json',
  };
}
