import 'package:geolocator/geolocator.dart';
import 'package:hela/models/destination.dart';
import 'package:hela/models/tour_plan.dart';
import 'package:latlong2/latlong.dart';

/// Represents a single stop or origin point rendered on the day route map.
class RouteMapStop {
  final int index;
  final String badgeText;
  final String title;
  final String subtitle;
  final LatLng coordinates;
  final bool isOrigin;

  const RouteMapStop({
    required this.index,
    required this.badgeText,
    required this.title,
    required this.subtitle,
    required this.coordinates,
    this.isOrigin = false,
  });
}

/// Live GPS tracking state for map widgets.
enum LiveGpsStatus {
  locating,
  active,
  permissionDenied,
  serviceDisabled,
  unavailable,
}

/// Resolves Sri Lankan destinations/activities to map coordinates and provides
/// safe live GPS helpers for route maps.
class RouteMapService {
  RouteMapService._();

  static const LatLng sriLankaCenter = LatLng(7.8731, 80.7718);
  static const Distance _distanceCalc = Distance();

  /// Ordered from most specific landmarks/attractions to broader towns/cities
  /// so "Temple of the Sacred Tooth Relic" or "Nine Arch Bridge" matches
  /// accurately before generic city names.
  static const List<MapEntry<String, LatLng>> _knownSriLankaLocations = [
    MapEntry('bandaranaike', LatLng(7.1808, 79.8841)),
    MapEntry('katunayake', LatLng(7.1808, 79.8841)),
    MapEntry('cmb', LatLng(7.1808, 79.8841)),
    MapEntry('airport', LatLng(7.1808, 79.8841)),
    MapEntry('mattala', LatLng(6.2845, 81.1241)),
    MapEntry('temple of the sacred tooth', LatLng(7.2936, 80.6413)),
    MapEntry('dalada maligawa', LatLng(7.2936, 80.6413)),
    MapEntry('peradeniya', LatLng(7.2699, 80.5966)),
    MapEntry('botanical', LatLng(7.2699, 80.5966)),
    MapEntry('nine arch', LatLng(6.8768, 81.0608)),
    MapEntry('demodara', LatLng(6.8768, 81.0608)),
    MapEntry('little adam', LatLng(6.8669, 81.0603)),
    MapEntry('ravana falls', LatLng(6.8410, 81.0545)),
    MapEntry('coconut tree hill', LatLng(5.9447, 80.4660)),
    MapEntry('pigeon island', LatLng(8.7219, 81.2039)),
    MapEntry('horton plains', LatLng(6.8096, 80.8024)),
    MapEntry('world\'s end', LatLng(6.7982, 80.7933)),
    MapEntry('adam\'s peak', LatLng(6.8096, 80.4994)),
    MapEntry('sri pada', LatLng(6.8096, 80.4994)),
    MapEntry('galle fort', LatLng(6.0270, 80.2170)),
    MapEntry('galle lighthouse', LatLng(6.0247, 80.2194)),
    MapEntry('colombo fort', LatLng(6.9336, 79.8500)),
    MapEntry('galle face', LatLng(6.9234, 79.8449)),
    MapEntry('pinnawala', LatLng(7.3007, 80.3872)),
    MapEntry('sigiriya', LatLng(7.9570, 80.7603)),
    MapEntry('pidurangala', LatLng(7.9665, 80.7617)),
    MapEntry('dambulla', LatLng(7.8567, 80.6492)),
    MapEntry('habarana', LatLng(8.0378, 80.7503)),
    MapEntry('minneriya', LatLng(8.0190, 80.8400)),
    MapEntry('kandalama', LatLng(7.8686, 80.7081)),
    MapEntry('polonnaruwa', LatLng(7.9403, 81.0188)),
    MapEntry('anuradhapura', LatLng(8.3114, 80.4037)),
    MapEntry('mihintale', LatLng(8.3504, 80.5034)),
    MapEntry('wilpattu', LatLng(8.4581, 80.0241)),
    MapEntry('kurunegala', LatLng(7.4863, 80.3623)),
    MapEntry('negombo', LatLng(7.2008, 79.8737)),
    MapEntry('colombo', LatLng(6.9271, 79.8612)),
    MapEntry('kandy', LatLng(7.2906, 80.6337)),
    MapEntry('matale', LatLng(7.4675, 80.6234)),
    MapEntry('nuwara eliya', LatLng(6.9497, 80.7891)),
    MapEntry('nanu oya', LatLng(6.9415, 80.7429)),
    MapEntry('hatton', LatLng(6.8916, 80.5955)),
    MapEntry('kitulgala', LatLng(6.9892, 80.4182)),
    MapEntry('ella', LatLng(6.8667, 81.0466)),
    MapEntry('haputale', LatLng(6.7689, 80.9597)),
    MapEntry('bandarawela', LatLng(6.8329, 80.9860)),
    MapEntry('badulla', LatLng(6.9934, 81.0550)),
    MapEntry('yala', LatLng(6.3685, 81.5218)),
    MapEntry('tissamaharama', LatLng(6.2797, 81.2877)),
    MapEntry('udawalawe', LatLng(6.4384, 80.8920)),
    MapEntry('arugam bay', LatLng(6.8404, 81.8369)),
    MapEntry('tangalle', LatLng(6.0244, 80.7941)),
    MapEntry('mirissa', LatLng(5.9483, 80.4578)),
    MapEntry('weligama', LatLng(5.9739, 80.4297)),
    MapEntry('unawatuna', LatLng(6.0108, 80.2486)),
    MapEntry('galle', LatLng(6.0535, 80.2210)),
    MapEntry('hikkaduwa', LatLng(6.1395, 80.1063)),
    MapEntry('bentota', LatLng(6.4212, 79.9989)),
    MapEntry('kosgoda', LatLng(6.3389, 80.0252)),
    MapEntry('beruwala', LatLng(6.4735, 79.9844)),
    MapEntry('kalutara', LatLng(6.5854, 79.9607)),
    MapEntry('matara', LatLng(5.9549, 80.5550)),
    MapEntry('sinharaja', LatLng(6.4050, 80.4600)),
    MapEntry('ratnapura', LatLng(6.7056, 80.3847)),
    MapEntry('trincomalee', LatLng(8.5874, 81.2152)),
    MapEntry('nilaveli', LatLng(8.6989, 81.1904)),
    MapEntry('pasikudah', LatLng(7.9295, 81.5613)),
    MapEntry('batticaloa', LatLng(7.7310, 81.6747)),
    MapEntry('kalpitiya', LatLng(8.2345, 79.7664)),
    MapEntry('mannar', LatLng(8.9810, 79.9044)),
    MapEntry('jaffna', LatLng(9.6615, 80.0255)),
  ];

  /// Attempts to resolve a place string or [Destination] to a Sri Lankan [LatLng].
  static LatLng? resolveKnownCoordinates(
    String text, {
    Destination? destination,
  }) {
    if (destination != null &&
        destination.latitude != 0.0 &&
        destination.longitude != 0.0) {
      return LatLng(destination.latitude, destination.longitude);
    }

    final lower = text.toLowerCase();
    for (final entry in _knownSriLankaLocations) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  /// Builds an ordered list of [RouteMapStop]s for a single itinerary day.
  static List<RouteMapStop> buildDayRouteStops({
    required String originLabel,
    required String destinationLabel,
    ItineraryDay? day,
  }) {
    final stops = <RouteMapStop>[];

    final originCoords =
        resolveKnownCoordinates(originLabel) ?? const LatLng(7.1808, 79.8841);

    stops.add(
      RouteMapStop(
        index: 0,
        badgeText: 'S',
        title: originLabel,
        subtitle: 'Day Starting Point',
        coordinates: originCoords,
        isOrigin: true,
      ),
    );

    final fallbackDestCoords = resolveKnownCoordinates(destinationLabel) ??
        resolveKnownCoordinates(day?.overnightStay ?? '') ??
        resolveKnownCoordinates(day?.title ?? '') ??
        const LatLng(7.9570, 80.7603); // Sigiriya highlights fallback

    if (day != null && day.activities.isNotEmpty) {
      LatLng lastKnown = originCoords;

      for (var i = 0; i < day.activities.length; i++) {
        final act = day.activities[i];
        final resolved = resolveKnownCoordinates(
              '${act.title} ${act.description}',
              destination: act.destination,
            ) ??
            _interpolateAlongRoute(
              lastKnown,
              fallbackDestCoords,
              (i + 1) / (day.activities.length + 1),
              i,
            );

        lastKnown = resolved;
        stops.add(
          RouteMapStop(
            index: i + 1,
            badgeText: '${i + 1}',
            title: act.title,
            subtitle: act.startTime.isNotEmpty
                ? '${act.startTime}${act.category.isNotEmpty ? ' • ${act.category}' : ''}'
                : (act.category.isNotEmpty ? act.category : 'Itinerary Stop'),
            coordinates: resolved,
          ),
        );
      }

      final overnight = day.overnightStay?.trim();
      if (overnight != null && overnight.isNotEmpty) {
        final stayCoords = resolveKnownCoordinates(overnight);
        if (stayCoords != null &&
            distanceKm(stops.last.coordinates, stayCoords) > 3.0) {
          stops.add(
            RouteMapStop(
              index: stops.length,
              badgeText: 'H',
              title: overnight,
              subtitle: 'Overnight Stay',
              coordinates: stayCoords,
            ),
          );
        }
      }
    } else {
      // Fallback stops matching the default Day 1 expedition overview
      stops.add(
        const RouteMapStop(
          index: 1,
          badgeText: '1',
          title: 'Kurunegala Heritage Rest',
          subtitle: '12:30 PM • Traditional Lunch',
          coordinates: LatLng(7.4863, 80.3623),
        ),
      );
      stops.add(
        RouteMapStop(
          index: 2,
          badgeText: '2',
          title: destinationLabel == 'Sri Lanka Highlights'
              ? 'Sigiriya Lion Rock Citadel'
              : destinationLabel,
          subtitle: '03:30 PM • Highlight Stop',
          coordinates: fallbackDestCoords,
        ),
      );
    }

    return stops;
  }

  static LatLng _interpolateAlongRoute(
    LatLng from,
    LatLng to,
    double fraction,
    int seedIndex,
  ) {
    final t = fraction.clamp(0.15, 0.9);
    // Tiny alternating offset avoids overlapping identical markers when
    // multiple stops are in the same town.
    final jitter = ((seedIndex % 2 == 0) ? 1 : -1) * 0.008;
    return LatLng(
      from.latitude + (to.latitude - from.latitude) * t + jitter,
      from.longitude + (to.longitude - from.longitude) * t - jitter,
    );
  }

  /// Distance in kilometers between two [LatLng] points.
  static double distanceKm(LatLng a, LatLng b) {
    return _distanceCalc.as(LengthUnit.Kilometer, a, b);
  }

  /// Formats distance cleanly for map badges and stop cards.
  static String formatDistance(LatLng a, LatLng b) {
    final km = distanceKm(a, b);
    if (km < 1.0) {
      final meters = (km * 1000).round();
      return '$meters m';
    }
    if (km < 100) {
      return '${km.toStringAsFixed(1)} km';
    }
    return '${km.round()} km';
  }

  /// Safely checks/requests location permission and reads the current GPS fix.
  static Future<({LatLng? position, double? accuracy, LiveGpsStatus status})>
      fetchCurrentGpsPosition({bool requestPermission = true}) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) {
          return (
            position: LatLng(last.latitude, last.longitude),
            accuracy: last.accuracy,
            status: LiveGpsStatus.active,
          );
        }
        return (
          position: null,
          accuracy: null,
          status: LiveGpsStatus.serviceDisabled,
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && requestPermission) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return (
          position: null,
          accuracy: null,
          status: LiveGpsStatus.permissionDenied,
        );
      }

      try {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 8),
          ),
        );
        return (
          position: LatLng(pos.latitude, pos.longitude),
          accuracy: pos.accuracy,
          status: LiveGpsStatus.active,
        );
      } catch (_) {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) {
          return (
            position: LatLng(last.latitude, last.longitude),
            accuracy: last.accuracy,
            status: LiveGpsStatus.active,
          );
        }
        return (
          position: null,
          accuracy: null,
          status: LiveGpsStatus.unavailable,
        );
      }
    } catch (_) {
      return (
        position: null,
        accuracy: null,
        status: LiveGpsStatus.unavailable,
      );
    }
  }
}
