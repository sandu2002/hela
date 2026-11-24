import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hela/pages/active_journey_page.dart';
import 'package:hela/services/route_map_service.dart';
import 'package:hela/theme/hela_colors.dart';
import 'package:latlong2/latlong.dart';

bool get _isFlutterWidgetTest => WidgetsBinding.instance.runtimeType
    .toString()
    .contains('TestWidgetsFlutterBinding');

TileLayer buildTestSafeOsmTileLayer() {
  return TileLayer(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    userAgentPackageName: 'com.hela.travel',
    maxNativeZoom: 19,
    tileProvider: _isFlutterWidgetTest ? _TestBlankTileProvider() : null,
  );
}

TileLayer _buildOsmTileLayer() => buildTestSafeOsmTileLayer();

/// Returns a 1x1 transparent PNG in widget test environments so `flutter test`
/// does not fail on blocked outbound tile HTTP requests.
class _TestBlankTileProvider extends TileProvider {
  static final Uint8List _transparentPng = Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
    0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
    0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
    0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
    0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
    0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
    0x42, 0x60, 0x82,
  ]);

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return MemoryImage(_transparentPng);
  }
}

/// Compact interactive OpenStreetMap route overview with real-time device GPS
/// live location tracking, embedded inside the Itinerary Details Route Overview card.
class LiveRouteOverviewMap extends StatefulWidget {
  final int dayNumber;
  final String routeSummary;
  final List<RouteMapStop> stops;
  final int stopsCount;
  final double height;
  final VoidCallback? onExpandTap;

  /// Optional seed location & stream (useful for tests or pre-resolved GPS).
  final LatLng? initialUserLocation;
  final Stream<LatLng>? locationStreamOverride;
  final bool enableDeviceLocation;

  const LiveRouteOverviewMap({
    super.key,
    required this.dayNumber,
    required this.routeSummary,
    required this.stops,
    required this.stopsCount,
    this.height = 190,
    this.onExpandTap,
    this.initialUserLocation,
    this.locationStreamOverride,
    this.enableDeviceLocation = true,
  });

  @override
  State<LiveRouteOverviewMap> createState() => _LiveRouteOverviewMapState();
}

class _LiveRouteOverviewMapState extends State<LiveRouteOverviewMap> {
  final MapController _mapController = MapController();
  bool _mapReady = false;

  LatLng? _liveUserLocation;
  double? _accuracyMeters;
  LiveGpsStatus _gpsStatus = LiveGpsStatus.locating;
  RouteMapStop? _selectedStop;

  StreamSubscription<Position>? _positionSub;
  StreamSubscription<LatLng>? _overrideSub;

  @override
  void initState() {
    super.initState();
    _liveUserLocation = widget.initialUserLocation;
    if (_liveUserLocation != null) {
      _gpsStatus = LiveGpsStatus.active;
    }

    if (widget.locationStreamOverride != null) {
      _overrideSub = widget.locationStreamOverride!.listen((pos) {
        if (!mounted) return;
        setState(() {
          _liveUserLocation = pos;
          _gpsStatus = LiveGpsStatus.active;
        });
      });
    } else if (widget.enableDeviceLocation) {
      _initLiveGps(requestPermission: true);
    } else {
      _gpsStatus = _liveUserLocation != null
          ? LiveGpsStatus.active
          : LiveGpsStatus.unavailable;
    }
  }

  @override
  void didUpdateWidget(covariant LiveRouteOverviewMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dayNumber != widget.dayNumber ||
        oldWidget.stops.length != widget.stops.length ||
        oldWidget.routeSummary != widget.routeSummary) {
      _selectedStop = null;
      if (_mapReady) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _fitRouteBounds();
        });
      }
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _overrideSub?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initLiveGps({required bool requestPermission}) async {
    if (mounted) {
      setState(() {
        if (_liveUserLocation == null) {
          _gpsStatus = LiveGpsStatus.locating;
        }
      });
    }

    final result = await RouteMapService.fetchCurrentGpsPosition(
      requestPermission: requestPermission,
    );
    if (!mounted) return;

    setState(() {
      if (result.position != null) {
        _liveUserLocation = result.position;
        _accuracyMeters = result.accuracy;
      }
      _gpsStatus = result.status;
    });

    if (result.status == LiveGpsStatus.active && _positionSub == null) {
      _startPositionStream();
    }
  }

  void _startPositionStream() {
    try {
      _positionSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 15,
        ),
      ).listen(
        (pos) {
          if (!mounted) return;
          setState(() {
            _liveUserLocation = LatLng(pos.latitude, pos.longitude);
            _accuracyMeters = pos.accuracy;
            _gpsStatus = LiveGpsStatus.active;
          });
        },
        onError: (_) {
          // Keep last known position if stream encounters a transient error.
        },
      );
    } catch (_) {
      // Ignore if platform plugin is unavailable (e.g. headless test environment).
    }
  }

  void _fitRouteBounds() {
    if (!_mapReady || widget.stops.isEmpty) return;

    final points = widget.stops.map((s) => s.coordinates).toList();
    if (_liveUserLocation != null &&
        _isNearRoute(_liveUserLocation!, points)) {
      points.add(_liveUserLocation!);
    }

    if (points.length == 1) {
      _mapController.move(points.first, 11.5);
      return;
    }

    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.fromLTRB(34, 44, 44, 46),
        maxZoom: 13.5,
      ),
    );
  }

  bool _isNearRoute(LatLng userPos, List<LatLng> routePoints) {
    if (routePoints.isEmpty) return false;
    return RouteMapService.distanceKm(userPos, routePoints.first) <= 350;
  }

  Future<void> _onMyLocationPressed() async {
    if (_liveUserLocation != null) {
      if (_mapReady) {
        _mapController.move(_liveUserLocation!, 13.5);
      }
      return;
    }

    if (_gpsStatus == LiveGpsStatus.serviceDisabled) {
      try {
        await Geolocator.openLocationSettings();
      } catch (_) {}
      return;
    }

    await _initLiveGps(requestPermission: true);
    if (_liveUserLocation != null && _mapReady) {
      _mapController.move(_liveUserLocation!, 13.5);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enable device location permissions to center on your live GPS position.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  LatLng get _initialCenter {
    if (widget.stops.isNotEmpty) {
      return widget.stops.first.coordinates;
    }
    return _liveUserLocation ?? RouteMapService.sriLankaCenter;
  }

  String _liveStatusText() {
    switch (_gpsStatus) {
      case LiveGpsStatus.active:
        if (_liveUserLocation != null && widget.stops.isNotEmpty) {
          final target = _selectedStop ?? widget.stops.first;
          final km = RouteMapService.distanceKm(
            _liveUserLocation!,
            target.coordinates,
          );
          if (km <= 500) {
            final dist = RouteMapService.formatDistance(
              _liveUserLocation!,
              target.coordinates,
            );
            return 'Live GPS • $dist to ${target.isOrigin ? 'start' : 'stop ${target.badgeText}'}';
          }
        }
        return 'Live GPS';
      case LiveGpsStatus.locating:
        return 'Locating GPS...';
      case LiveGpsStatus.permissionDenied:
        return 'Enable Live GPS';
      case LiveGpsStatus.serviceDisabled:
        return 'GPS Off • Tap to enable';
      case LiveGpsStatus.unavailable:
        return 'Tap for Live GPS';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = HelaColors.of(context);
    final polylinePoints = widget.stops.map((s) => s.coordinates).toList();
    final showConnectorFromUser = _liveUserLocation != null &&
        polylinePoints.isNotEmpty &&
        _isNearRoute(_liveUserLocation!, polylinePoints);

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Live Interactive OpenStreetMap
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _initialCenter,
                initialZoom: 8.2,
                minZoom: 5.0,
                maxZoom: 17.5,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
                onMapReady: () {
                  _mapReady = true;
                  _fitRouteBounds();
                },
                onTap: (_, _) {
                  if (_selectedStop != null) {
                    setState(() => _selectedStop = null);
                  }
                },
              ),
              children: [
                _buildOsmTileLayer(),
                // Route Polylines
                if (polylinePoints.length >= 2)
                  PolylineLayer(
                    polylines: [
                      // Crisp white halo underneath for legibility
                      Polyline(
                        points: polylinePoints,
                        strokeWidth: 6.0,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      // Primary HELA emerald route line
                      Polyline(
                        points: polylinePoints,
                        strokeWidth: 3.5,
                        color: colors.primary,
                      ),
                    ],
                  ),
                // Dashed live connector from user's GPS to Day's starting point
                if (showConnectorFromUser)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [_liveUserLocation!, polylinePoints.first],
                        strokeWidth: 2.5,
                        color: const Color(0xFF2563EB).withValues(alpha: 0.75),
                        pattern: StrokePattern.dashed(segments: const [6, 5]),
                      ),
                    ],
                  ),
                // GPS Accuracy Ring when live position is active
                if (_liveUserLocation != null && (_accuracyMeters ?? 0) > 0)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: _liveUserLocation!,
                        radius: (_accuracyMeters!.clamp(20.0, 250.0)),
                        useRadiusInMeter: true,
                        color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                        borderColor:
                            const Color(0xFF2563EB).withValues(alpha: 0.35),
                        borderStrokeWidth: 1.5,
                      ),
                    ],
                  ),
                // Route Stop Markers + Live GPS Marker
                MarkerLayer(
                  markers: [
                    ...widget.stops.map((stop) {
                      final isSelected = _selectedStop?.index == stop.index;
                      final bgColor = stop.isOrigin
                          ? const Color(0xFF047857)
                          : (isSelected ? colors.tertiary : colors.primary);
                      return Marker(
                        point: stop.coordinates,
                        width: isSelected ? 34 : 28,
                        height: isSelected ? 34 : 28,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedStop = isSelected ? null : stop;
                            });
                            if (_mapReady) {
                              _mapController.move(stop.coordinates, 11.5);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: bgColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.28),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: stop.isOrigin
                                  ? const Icon(
                                      Icons.flight_takeoff_rounded,
                                      size: 13,
                                      color: Colors.white,
                                    )
                                  : Text(
                                      stop.badgeText,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      );
                    }),
                    if (_liveUserLocation != null)
                      Marker(
                        point: _liveUserLocation!,
                        width: 36,
                        height: 36,
                        child: _LiveGpsPuck(),
                      ),
                  ],
                ),
              ],
            ),

            // 2. Bottom Gradient & Route Summary Strip
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                ignoring: widget.onExpandTap == null,
                child: GestureDetector(
                  onTap: widget.onExpandTap,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 18, 10, 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          colors.primary.withValues(alpha: 0.9),
                          colors.primary.withValues(alpha: 0.52),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.near_me_rounded,
                                size: 15,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  widget.routeSummary,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${widget.stopsCount} stops',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 3. Top-Left Live GPS Status Pill
            Positioned(
              top: 8,
              left: 8,
              child: GestureDetector(
                onTap: _onMyLocationPressed,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: _gpsStatus == LiveGpsStatus.active
                              ? const Color(0xFF10B981)
                              : (_gpsStatus == LiveGpsStatus.locating
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFFF59E0B)),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _liveStatusText(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Selected Stop Tooltip Chip
            if (_selectedStop != null)
              Positioned(
                top: 36,
                left: 8,
                right: 54,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedStop!.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _liveUserLocation != null
                                  ? '${_selectedStop!.subtitle} • ${RouteMapService.formatDistance(_liveUserLocation!, _selectedStop!.coordinates)} from you'
                                  : _selectedStop!.subtitle,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 9.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _selectedStop = null),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 5. Top-Right My Location & Fit Route Controls
            Positioned(
              top: 8,
              right: 8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MapControlButton(
                    icon: _gpsStatus == LiveGpsStatus.active
                        ? Icons.my_location_rounded
                        : Icons.location_searching_rounded,
                    tooltip: 'Center on my live location',
                    iconColor: _gpsStatus == LiveGpsStatus.active
                        ? const Color(0xFF2563EB)
                        : colors.primary,
                    onTap: _onMyLocationPressed,
                  ),
                  const SizedBox(height: 6),
                  _MapControlButton(
                    icon: Icons.center_focus_strong_rounded,
                    tooltip: 'Fit Day ${widget.dayNumber} route',
                    iconColor: colors.primary,
                    onTap: _fitRouteBounds,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen expanded live route map opened when tapping "Expand" on the
/// Day Route Overview card.
class LiveRouteMapPage extends StatefulWidget {
  final int dayNumber;
  final String dateText;
  final String routeTitle;
  final String origin;
  final String destination;
  final List<RouteMapStop> stops;
  final LatLng? initialUserLocation;
  final Stream<LatLng>? locationStreamOverride;
  final bool enableDeviceLocation;

  const LiveRouteMapPage({
    super.key,
    required this.dayNumber,
    required this.dateText,
    required this.routeTitle,
    required this.origin,
    required this.destination,
    required this.stops,
    this.initialUserLocation,
    this.locationStreamOverride,
    this.enableDeviceLocation = true,
  });

  @override
  State<LiveRouteMapPage> createState() => _LiveRouteMapPageState();
}

class _LiveRouteMapPageState extends State<LiveRouteMapPage> {
  final MapController _mapController = MapController();
  bool _mapReady = false;
  bool _followLiveLocation = false;
  int _selectedStopIndex = 0;

  LatLng? _liveUserLocation;
  double? _accuracyMeters;
  LiveGpsStatus _gpsStatus = LiveGpsStatus.locating;

  StreamSubscription<Position>? _positionSub;
  StreamSubscription<LatLng>? _overrideSub;

  @override
  void initState() {
    super.initState();
    _liveUserLocation = widget.initialUserLocation;
    if (_liveUserLocation != null) {
      _gpsStatus = LiveGpsStatus.active;
    }

    if (widget.locationStreamOverride != null) {
      _overrideSub = widget.locationStreamOverride!.listen((pos) {
        if (!mounted) return;
        setState(() {
          _liveUserLocation = pos;
          _gpsStatus = LiveGpsStatus.active;
        });
        if (_followLiveLocation && _mapReady) {
          _mapController.move(pos, _mapController.camera.zoom);
        }
      });
    } else if (widget.enableDeviceLocation) {
      _initLiveGps();
    } else {
      _gpsStatus = _liveUserLocation != null
          ? LiveGpsStatus.active
          : LiveGpsStatus.unavailable;
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _overrideSub?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initLiveGps() async {
    final res = await RouteMapService.fetchCurrentGpsPosition(
      requestPermission: true,
    );
    if (!mounted) return;
    setState(() {
      if (res.position != null) {
        _liveUserLocation = res.position;
        _accuracyMeters = res.accuracy;
      }
      _gpsStatus = res.status;
    });

    if (res.status == LiveGpsStatus.active && _positionSub == null) {
      try {
        _positionSub = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen(
          (pos) {
            if (!mounted) return;
            final next = LatLng(pos.latitude, pos.longitude);
            setState(() {
              _liveUserLocation = next;
              _accuracyMeters = pos.accuracy;
              _gpsStatus = LiveGpsStatus.active;
            });
            if (_followLiveLocation && _mapReady) {
              _mapController.move(next, _mapController.camera.zoom);
            }
          },
          onError: (_) {},
        );
      } catch (_) {}
    }
  }

  void _fitRouteBounds() {
    if (!_mapReady || widget.stops.isEmpty) return;
    setState(() => _followLiveLocation = false);
    final points = widget.stops.map((s) => s.coordinates).toList();
    if (_liveUserLocation != null &&
        RouteMapService.distanceKm(_liveUserLocation!, points.first) <= 350) {
      points.add(_liveUserLocation!);
    }
    if (points.length == 1) {
      _mapController.move(points.first, 12.0);
      return;
    }
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: const EdgeInsets.fromLTRB(48, 70, 48, 220),
        maxZoom: 14.0,
      ),
    );
  }

  Future<void> _centerOnUser() async {
    if (_liveUserLocation != null) {
      setState(() => _followLiveLocation = !_followLiveLocation);
      if (_mapReady) {
        _mapController.move(_liveUserLocation!, 14.5);
      }
      return;
    }

    if (_gpsStatus == LiveGpsStatus.serviceDisabled) {
      try {
        await Geolocator.openLocationSettings();
      } catch (_) {}
      return;
    }

    await _initLiveGps();
    if (_liveUserLocation != null && _mapReady) {
      setState(() => _followLiveLocation = true);
      _mapController.move(_liveUserLocation!, 14.5);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permission is needed to show your live GPS position.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = HelaColors.of(context);
    final polylinePoints = widget.stops.map((s) => s.coordinates).toList();
    final initialCenter = widget.stops.isNotEmpty
        ? widget.stops.first.coordinates
        : (_liveUserLocation ?? RouteMapService.sriLankaCenter);

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Day ${widget.dayNumber} Live Route Map',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: (_gpsStatus == LiveGpsStatus.active
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B))
                        .withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _gpsStatus == LiveGpsStatus.active ? 'GPS LIVE' : 'ROUTE MAP',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: _gpsStatus == LiveGpsStatus.active
                          ? const Color(0xFF047857)
                          : const Color(0xFFB45309),
                    ),
                  ),
                ),
              ],
            ),
            Text(
              widget.dateText,
              style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.center_focus_strong_rounded, color: colors.primary),
            tooltip: 'Fit Full Route',
            onPressed: _fitRouteBounds,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 8.5,
              minZoom: 5.0,
              maxZoom: 18.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              onMapReady: () {
                _mapReady = true;
                _fitRouteBounds();
              },
            ),
            children: [
              _buildOsmTileLayer(),
              if (polylinePoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: polylinePoints,
                      strokeWidth: 7.0,
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                    Polyline(
                      points: polylinePoints,
                      strokeWidth: 4.0,
                      color: colors.primary,
                    ),
                  ],
                ),
              if (_liveUserLocation != null &&
                  polylinePoints.isNotEmpty &&
                  RouteMapService.distanceKm(
                        _liveUserLocation!,
                        polylinePoints.first,
                      ) <=
                      350)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [_liveUserLocation!, polylinePoints.first],
                      strokeWidth: 3.0,
                      color: const Color(0xFF2563EB).withValues(alpha: 0.8),
                      pattern: StrokePattern.dashed(segments: const [8, 6]),
                    ),
                  ],
                ),
              if (_liveUserLocation != null && (_accuracyMeters ?? 0) > 0)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _liveUserLocation!,
                      radius: _accuracyMeters!.clamp(20.0, 300.0),
                      useRadiusInMeter: true,
                      color: const Color(0xFF2563EB).withValues(alpha: 0.14),
                      borderColor:
                          const Color(0xFF2563EB).withValues(alpha: 0.4),
                      borderStrokeWidth: 1.5,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  ...List.generate(widget.stops.length, (i) {
                    final stop = widget.stops[i];
                    final isSelected = _selectedStopIndex == i;
                    return Marker(
                      point: stop.coordinates,
                      width: isSelected ? 40 : 32,
                      height: isSelected ? 40 : 32,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedStopIndex = i;
                            _followLiveLocation = false;
                          });
                          if (_mapReady) {
                            _mapController.move(stop.coordinates, 12.5);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: stop.isOrigin
                                ? const Color(0xFF047857)
                                : (isSelected ? colors.tertiary : colors.primary),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.28),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: stop.isOrigin
                                ? const Icon(
                                    Icons.flight_takeoff_rounded,
                                    size: 15,
                                    color: Colors.white,
                                  )
                                : Text(
                                    stop.badgeText,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    );
                  }),
                  if (_liveUserLocation != null)
                    Marker(
                      point: _liveUserLocation!,
                      width: 40,
                      height: 40,
                      child: _LiveGpsPuck(),
                    ),
                ],
              ),
            ],
          ),

          // Right Floating Map Controls
          Positioned(
            top: 14,
            right: 14,
            child: Column(
              children: [
                _MapControlButton(
                  icon: _followLiveLocation
                      ? Icons.gps_fixed_rounded
                      : Icons.my_location_rounded,
                  tooltip: 'My Live Location',
                  iconColor: _gpsStatus == LiveGpsStatus.active
                      ? const Color(0xFF2563EB)
                      : colors.primary,
                  onTap: _centerOnUser,
                ),
                const SizedBox(height: 8),
                _MapControlButton(
                  icon: Icons.add_rounded,
                  tooltip: 'Zoom in',
                  iconColor: colors.primary,
                  onTap: () {
                    if (_mapReady) {
                      _mapController.move(
                        _mapController.camera.center,
                        (_mapController.camera.zoom + 1).clamp(5.0, 18.0),
                      );
                    }
                  },
                ),
                const SizedBox(height: 6),
                _MapControlButton(
                  icon: Icons.remove_rounded,
                  tooltip: 'Zoom out',
                  iconColor: colors.primary,
                  onTap: () {
                    if (_mapReady) {
                      _mapController.move(
                        _mapController.camera.center,
                        (_mapController.camera.zoom - 1).clamp(5.0, 18.0),
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          // Bottom Stop Carousel + Start Journey CTA
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: 0.96),
                border: Border(
                  top: BorderSide(color: colors.architecturalBorder),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 82,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.stops.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, idx) {
                          final stop = widget.stops[idx];
                          final isSelected = idx == _selectedStopIndex;
                          final distLabel = _liveUserLocation != null
                              ? '${RouteMapService.formatDistance(_liveUserLocation!, stop.coordinates)} away'
                              : stop.subtitle;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedStopIndex = idx;
                                _followLiveLocation = false;
                              });
                              if (_mapReady) {
                                _mapController.move(stop.coordinates, 12.5);
                              }
                            },
                            child: Container(
                              width: 215,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colors.primary.withValues(alpha: 0.08)
                                    : colors.cardBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? colors.primary
                                      : colors.architecturalBorder,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: stop.isOrigin
                                          ? const Color(0xFF047857)
                                          : colors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        stop.badgeText,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          stop.title,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: colors.onSurface,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          distLabel,
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            color: colors.onSurfaceVariant,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ActiveJourneyPage(
                                dayNumber: widget.dayNumber,
                                dateText: widget.dateText,
                                routeTitle: widget.routeTitle,
                                origin: widget.origin,
                                destination: widget.destination,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.navigation_rounded, size: 18),
                        label: const Text(
                          'Start Live Turn-by-Turn Journey',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveGpsPuck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withValues(alpha: 0.22),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 11,
              height: 11,
              decoration: const BoxDecoration(
                color: Color(0xFF2563EB),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color iconColor;
  final VoidCallback onTap;

  const _MapControlButton({
    required this.icon,
    required this.tooltip,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.94),
      shape: const CircleBorder(),
      elevation: 2,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(6.5),
            child: Icon(icon, size: 17, color: iconColor),
          ),
        ),
      ),
    );
  }
}
