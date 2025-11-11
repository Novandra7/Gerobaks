import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:bloc/bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:bank_sha/services/tracking_service.dart';
import 'tracking_event.dart';
import 'tracking_state.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  // Cache for route data to avoid repeated API calls
  final Map<String, List<LatLng>> _routeCache = {};
  StreamSubscription<List<Tracking>>? _trackingSubscription;

  TrackingBloc({
    TrackingService? trackingService,
    int? initialScheduleId,
    LatLng? initialDestination,
  }) : _trackingService = trackingService ?? TrackingService(),
       super(
         TrackingState.initial(
           scheduleId: initialScheduleId,
           destination: initialDestination,
         ),
       ) {
    on<FetchRoute>(_onFetchRoute);
    on<UpdateTruckLocation>(_onUpdateLocation);
    on<UpdateDestination>(_onUpdateDestination);
    on<TrackingHistoryUpdated>(_onHistoryUpdated);
    on<TrackingHistoryFailed>(_onHistoryFailed);
  }

  final TrackingService _trackingService;

  void _onUpdateDestination(
    UpdateDestination event,
    Emitter<TrackingState> emit,
  ) {
    emit(state.copyWith(destination: event.destination));
  }

  void _onUpdateLocation(
    UpdateTruckLocation event,
    Emitter<TrackingState> emit,
  ) {
    try {
      final bearing = calculateBearing(event.position, state.destination);
      emit(
        state.copyWith(truckPosition: event.position, truckBearing: bearing),
      );
    } catch (e) {
      // Safely handle any errors in bearing calculation without crashing
      print('Error updating location: $e');
      emit(state.copyWith(truckPosition: event.position));
    }
  }

  Future<void> _onFetchRoute(
    FetchRoute event,
    Emitter<TrackingState> emit,
  ) async {
    final scheduleId = event.scheduleId ?? state.scheduleId;
    final desiredDestination = event.destination ?? state.destination;

    if (scheduleId != null) {
      final updatedDestination = desiredDestination ?? state.destination;

      emit(
        state.copyWith(
          isLoading: true,
          error: null,
          scheduleId: scheduleId,
          destination: updatedDestination,
        ),
      );

      await _trackingSubscription?.cancel();
      _trackingSubscription = _trackingService
          .watchTrackingBySchedule(scheduleId)
          .listen(
            (items) {
              add(
                TrackingHistoryUpdated(
                  scheduleId: scheduleId,
                  items: items,
                  destination: updatedDestination,
                ),
              );
            },
            onError: (error, stackTrace) {
              print('Error streaming tracking history: $error');
              add(
                TrackingHistoryFailed(
                  scheduleId: scheduleId,
                  message: 'Gagal memuat data pelacakan',
                ),
              );
            },
          );

      return;
    }

    emit(state.copyWith(isLoading: true, error: null));

    // Generate cache key based on start and end points
    final cacheKey =
        '${state.truckPosition.latitude},${state.truckPosition.longitude}|${state.destination.latitude},${state.destination.longitude}';

    // Check if route is already cached
    if (_routeCache.containsKey(cacheKey)) {
      print('Using cached route data');
      emit(
        state.copyWith(routePoints: _routeCache[cacheKey]!, isLoading: false),
      );
      return;
    }

    final apiKey = dotenv.env['ORS_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      emit(
        state.copyWith(isLoading: false, error: 'ORS_API_KEY tidak ditemukan'),
      );
      return;
    }

    final url =
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${state.truckPosition.longitude},${state.truckPosition.latitude}&end=${state.destination.longitude},${state.destination.latitude}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        try {
          final coordinates =
              data['features'][0]['geometry']['coordinates'] as List;

          // Limit number of route points to prevent memory issues
          List<dynamic> limitedCoords;
          if (coordinates.length > 150) {
            // Take subset of points (every nth point)
            int step = (coordinates.length / 150).ceil();
            limitedCoords = [];
            for (int i = 0; i < coordinates.length; i += step) {
              if (i < coordinates.length) limitedCoords.add(coordinates[i]);
            }
            // Always include first and last point
            if (!limitedCoords.contains(coordinates.first)) {
              limitedCoords.insert(0, coordinates.first);
            }
            if (!limitedCoords.contains(coordinates.last)) {
              limitedCoords.add(coordinates.last);
            }
          } else {
            limitedCoords = coordinates;
          }

          final route = limitedCoords
              .map((coord) => LatLng(coord[1], coord[0]))
              .toList();

          // Store in cache for future use
          _routeCache[cacheKey] = route;

          double bearing = 0.0;
          if (route.length >= 2) {
            bearing = calculateBearing(route[0], route[1]);
          }

          emit(
            state.copyWith(
              routePoints: route,
              truckBearing: bearing,
              isLoading: false,
            ),
          );
        } catch (e) {
          print('Error parsing route data: $e');
          emit(
            state.copyWith(
              isLoading: false,
              error: 'Format data rute tidak valid',
            ),
          );
        }
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        emit(
          state.copyWith(
            isLoading: false,
            error: 'Gagal ambil rute (${response.statusCode})',
          ),
        );
      }
    } catch (e) {
      print('Network error: $e');
      emit(
        state.copyWith(isLoading: false, error: 'Koneksi jaringan bermasalah'),
      );
    }
  }

  double calculateBearing(LatLng start, LatLng end) {
    try {
      final lat1 = start.latitude * (math.pi / 180);
      final lon1 = start.longitude * (math.pi / 180);
      final lat2 = end.latitude * (math.pi / 180);
      final lon2 = end.longitude * (math.pi / 180);

      final dLon = lon2 - lon1;

      final y = math.sin(dLon) * math.cos(lat2);
      final x =
          math.cos(lat1) * math.sin(lat2) -
          math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

      final bearing = math.atan2(y, x);
      return (bearing * (180 / math.pi) + 360) % 360;
    } catch (e) {
      print('Error calculating bearing: $e');
      return 0.0; // Default bearing
    }
  }

  @override
  Future<void> close() async {
    // Clear cache when bloc is closed
    _routeCache.clear();
    await _trackingSubscription?.cancel();
    return super.close();
  }

  void _onHistoryUpdated(
    TrackingHistoryUpdated event,
    Emitter<TrackingState> emit,
  ) {
    if (state.scheduleId != event.scheduleId) {
      return;
    }

    final desiredDestination = event.destination ?? state.destination;

    if (event.items.isEmpty) {
      final hasRoute = state.routePoints.isNotEmpty;
      emit(
        state.copyWith(
          isLoading: false,
          error: null,
          scheduleId: event.scheduleId,
          destination: desiredDestination,
          resetLastUpdated: !hasRoute,
        ),
      );
      return;
    }

    final sorted = List<Tracking>.from(event.items)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final historyPoints = sorted
        .map((e) => LatLng(e.latitude, e.longitude))
        .toList();

    final latest = historyPoints.last;
    final truckBearing = historyPoints.length >= 2
        ? calculateBearing(historyPoints[historyPoints.length - 2], latest)
        : state.truckBearing;

    emit(
      state.copyWith(
        routePoints: historyPoints,
        truckPosition: latest,
        destination: desiredDestination,
        truckBearing: truckBearing,
        isLoading: false,
        error: null,
        scheduleId: event.scheduleId,
        lastUpdated: sorted.last.timestamp,
      ),
    );
  }

  void _onHistoryFailed(
    TrackingHistoryFailed event,
    Emitter<TrackingState> emit,
  ) {
    if (state.scheduleId != event.scheduleId) {
      return;
    }

    emit(
      state.copyWith(
        isLoading: false,
        error: event.message,
        scheduleId: event.scheduleId,
      ),
    );
  }
}
