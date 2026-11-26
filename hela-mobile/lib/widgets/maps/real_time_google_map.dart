import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hela/pages/home/home_page.dart';

/// Available map layer styles
enum MapStyleType {
  standard,
  satellite,
  terrain,
}

/// Real-Time Interactive Google Map Widget
///
/// Features:
/// - Authentic Google Maps styling (standard navigation, satellite imagery, topographic terrain)
/// - Interactive gestures: Drag to pan, pinch to zoom, double tap to zoom in
/// - Live zoom in (+) and zoom out (–) controls
/// - Recenter / My Location button to reset view to the active route
/// - Map layer switcher (Standard / Satellite / Terrain)
/// - Live traffic layer toggle (congestion indicators along B113)
/// - Real-time vehicle tracking simulation along the Ella - Ravana Falls road
/// - Vehicle icon reflects active vehicle selection (Tuk-Tuk, Sedan Car, Safari Van)
/// - Authentic Google logo watermark
/// - Interactive pickup and destination Google Maps pins with InfoWindow tooltips
/// - Turn-by-turn navigation badge with live ETA and distance
class RealTimeGoogleMap extends StatefulWidget {
  final String pickupLocation;
  final String dropoffLocation;
  final String durationText;
  final String distanceText;
  final String vehicleType;
  final double height;
  final VoidCallback? onSwapLocations;
  final VoidCallback? onRecenter;

  const RealTimeGoogleMap({
    super.key,
    this.pickupLocation = '98 Acres Resort & Spa, Ella',
    this.dropoffLocation = 'Ravana Falls & Rock Sanctuary',
    this.durationText = '18 mins',
    this.distanceText = '8.4 km via B113',
    this.vehicleType = 'Tuk-Tuk',
    this.height = 315,
    this.onSwapLocations,
    this.onRecenter,
  });

  @override
  State<RealTimeGoogleMap> createState() => _RealTimeGoogleMapState();
}

class _RealTimeGoogleMapState extends State<RealTimeGoogleMap>
    with TickerProviderStateMixin {
  // Gesture & Camera State
  Offset _panOffset = Offset.zero;
  double _scale = 1.0;
  Offset _basePanOffset = Offset.zero;
  double _baseScale = 1.0;

  // Map Modes
  MapStyleType _currentMapStyle = MapStyleType.standard;
  bool _showTraffic = true;
  String? _selectedMarkerId;

  // Animation Controllers
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _vehicleTravelController;
  late Animation<double> _vehicleProgressAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for pickup radar
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.4).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Live driver vehicle travel animation along the road (loops continuously)
    _vehicleTravelController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _vehicleProgressAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(
        parent: _vehicleTravelController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _vehicleTravelController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    setState(() {
      _scale = (_scale * 1.25).clamp(0.7, 2.6);
    });
  }

  void _zoomOut() {
    setState(() {
      _scale = (_scale / 1.25).clamp(0.7, 2.6);
    });
  }

  void _recenterMap() {
    setState(() {
      _panOffset = Offset.zero;
      _scale = 1.0;
      _selectedMarkerId = null;
    });
    widget.onRecenter?.call();
  }

  void _cycleMapStyle() {
    setState(() {
      switch (_currentMapStyle) {
        case MapStyleType.standard:
          _currentMapStyle = MapStyleType.satellite;
          break;
        case MapStyleType.satellite:
          _currentMapStyle = MapStyleType.terrain;
          break;
        case MapStyleType.terrain:
          _currentMapStyle = MapStyleType.standard;
          break;
      }
    });
  }

  IconData get _vehicleIcon {
    final lower = widget.vehicleType.toLowerCase();
    if (lower.contains('tuk') || lower.contains('rickshaw')) {
      return Icons.electric_rickshaw_rounded;
    } else if (lower.contains('van') || lower.contains('safari')) {
      return Icons.airport_shuttle_rounded;
    } else {
      return Icons.directions_car_rounded;
    }
  }

  /// Calculates a point along the cubic route spline at normalized parameter t in [0, 1]
  Offset _getRoutePoint(double t) {
    // Control points for Ella - Ravana Falls road route in 400x310 canvas space
    const p0 = Offset(105, 138);
    const p1 = Offset(140, 105);
    const p2 = Offset(215, 140);
    const p3 = Offset(295, 185);

    final u = 1 - t;
    final tt = t * t;
    final uu = u * u;
    final uuu = uu * u;
    final ttt = tt * t;

    final x = uuu * p0.dx + 3 * uu * t * p1.dx + 3 * u * tt * p2.dx + ttt * p3.dx;
    final y = uuu * p0.dy + 3 * uu * t * p1.dy + 3 * u * tt * p2.dy + ttt * p3.dy;
    return Offset(x, y);
  }

  /// Calculates the rotation tangent angle (heading) along the route at parameter t
  double _getRouteHeading(double t) {
    const delta = 0.01;
    final tPrev = (t - delta).clamp(0.0, 1.0);
    final tNext = (t + delta).clamp(0.0, 1.0);
    final pPrev = _getRoutePoint(tPrev);
    final pNext = _getRoutePoint(tNext);
    return math.atan2(pNext.dy - pPrev.dy, pNext.dx - pPrev.dx);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Pan/Zoom Interactive Map Surface
          Positioned.fill(
            child: ClipRect(
              child: GestureDetector(
                onScaleStart: (details) {
                  _basePanOffset = _panOffset;
                  _baseScale = _scale;
                },
                onScaleUpdate: (details) {
                  setState(() {
                    _scale = (_baseScale * details.scale).clamp(0.75, 2.5);
                    _panOffset = _basePanOffset + details.focalPointDelta;
                  });
                },
                onDoubleTap: _zoomIn,
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _pulseAnimation,
                    _vehicleProgressAnimation,
                  ]),
                  builder: (context, child) {
                    final vehicleT = _vehicleProgressAnimation.value;
                    final vehiclePos = _getRoutePoint(vehicleT);
                    final vehicleHeading = _getRouteHeading(vehicleT);

                    return CustomPaint(
                      painter: _GoogleMapCanvasPainter(
                        panOffset: _panOffset,
                        scale: _scale,
                        mapStyle: _currentMapStyle,
                        showTraffic: _showTraffic,
                        pulseScale: _pulseAnimation.value,
                        vehiclePosition: vehiclePos,
                        vehicleHeading: vehicleHeading,
                        vehicleIcon: _vehicleIcon,
                        vehicleType: widget.vehicleType,
                      ),
                      size: Size.infinite,
                    );
                  },
                ),
              ),
            ),
          ),

          // 2. Interactive Pickup Marker Overlay
          _buildInteractiveMarker(
            id: 'pickup',
            basePosition: const Offset(105, 138),
            label: widget.pickupLocation,
            subLabel: 'Pickup · 98 Acres Hilltop',
            icon: Icons.my_location_rounded,
            pinColor: HelaColors.secondary,
          ),

          // 3. Interactive Destination Marker Overlay
          _buildInteractiveMarker(
            id: 'destination',
            basePosition: const Offset(295, 185),
            label: widget.dropoffLocation,
            subLabel: 'Drop-off · Scenic Falls',
            icon: Icons.waterfall_chart_rounded,
            pinColor: const Color(0xFFEA4335), // Google Red
          ),

          // 4. Floating Pickup & Dropoff Address Input Card (Top)
          Positioned(
            top: 10,
            left: 14,
            right: 14,
            child: _buildLocationInputCard(),
          ),

          // 5. Google Maps Watermark Logo (Bottom Left)
          Positioned(
            bottom: 48,
            left: 16,
            child: _buildGoogleWatermark(),
          ),

          // 6. Map Type & Traffic Layer Buttons (Top Right beneath card)
          Positioned(
            top: 98,
            right: 14,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Layer Switcher Button
                _buildFloatingCircleButton(
                  icon: Icons.layers_rounded,
                  tooltip: 'Style: ${_currentMapStyle.name.toUpperCase()}',
                  onTap: _cycleMapStyle,
                ),
                const SizedBox(height: 8),

                // Traffic Overlay Button
                _buildFloatingCircleButton(
                  icon: _showTraffic
                      ? Icons.traffic_rounded
                      : Icons.traffic_outlined,
                  color: _showTraffic
                      ? HelaColors.secondary
                      : HelaColors.onSurfaceVariant,
                  tooltip: _showTraffic ? 'Traffic ON' : 'Traffic OFF',
                  onTap: () {
                    setState(() {
                      _showTraffic = !_showTraffic;
                    });
                  },
                ),
              ],
            ),
          ),

          // 7. Zoom In & Zoom Out Pill Controls (Right Center)
          Positioned(
            top: 194,
            right: 14,
            child: _buildZoomControls(),
          ),

          // 8. Bottom Navigation Strip (ETA, Route Info & Recenter Button)
          Positioned(
            bottom: 10,
            left: 14,
            right: 14,
            child: _buildBottomRouteBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveMarker({
    required String id,
    required Offset basePosition,
    required String label,
    required String subLabel,
    required IconData icon,
    required Color pinColor,
  }) {
    // Apply pan & scale transformation to match map canvas
    final transformed = Offset(
      (basePosition.dx * _scale) + _panOffset.dx,
      (basePosition.dy * _scale) + _panOffset.dy,
    );

    final isSelected = _selectedMarkerId == id;

    return Positioned(
      left: transformed.dx - 45,
      top: transformed.dy - (isSelected ? 62 : 36),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedMarkerId = isSelected ? null : id;
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: HelaColors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subLabel,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: pinColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInputCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HelaColors.surfaceContainerLowest.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: HelaColors.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F2E24).withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Connector Dots
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: HelaColors.secondary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: HelaColors.secondaryContainer,
                    width: 2,
                  ),
                ),
              ),
              Container(
                width: 1.5,
                height: 22,
                color: HelaColors.outlineVariant,
              ),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFFEA4335),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Text Addresses
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.pickupLocation,
                        style: const TextStyle(
                          color: HelaColors.onSurface,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: HelaColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Now',
                        style: TextStyle(
                          color: HelaColors.onSurfaceVariant,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 12, color: HelaColors.surfaceContainer),
                Text(
                  widget.dropoffLocation,
                  style: const TextStyle(
                    color: HelaColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Swap Locations Button
          Material(
            color: HelaColors.surfaceContainerLow,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: widget.onSwapLocations,
              child: const Padding(
                padding: EdgeInsets.all(7.0),
                child: Icon(
                  Icons.swap_vert_rounded,
                  color: HelaColors.primary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleWatermark() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
          ),
        ],
      ),
      child: RichText(
        text: const TextSpan(
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            fontFamily: 'sans-serif',
            letterSpacing: -0.4,
          ),
          children: [
            TextSpan(text: 'G', style: TextStyle(color: Color(0xFF4285F4))),
            TextSpan(text: 'o', style: TextStyle(color: Color(0xFFEA4335))),
            TextSpan(text: 'o', style: TextStyle(color: Color(0xFFFBBC05))),
            TextSpan(text: 'g', style: TextStyle(color: Color(0xFF4285F4))),
            TextSpan(text: 'l', style: TextStyle(color: Color(0xFF34A853))),
            TextSpan(text: 'e', style: TextStyle(color: Color(0xFFEA4335))),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingCircleButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Material(
      color: HelaColors.surfaceContainerLowest.withValues(alpha: 0.94),
      shape: const CircleBorder(),
      elevation: 2,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(7.0),
            child: Icon(
              icon,
              size: 19,
              color: color ?? HelaColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZoomControls() {
    return Container(
      decoration: BoxDecoration(
        color: HelaColors.surfaceContainerLowest.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            onTap: _zoomIn,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 7, vertical: 6),
              child: Icon(
                Icons.add_rounded,
                size: 19,
                color: HelaColors.primary,
              ),
            ),
          ),
          Container(
            height: 1,
            width: 20,
            color: HelaColors.surfaceContainer,
          ),
          InkWell(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(16)),
            onTap: _zoomOut,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 7, vertical: 6),
              child: Icon(
                Icons.remove_rounded,
                size: 19,
                color: HelaColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomRouteBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Route Duration & Distance Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: HelaColors.primaryContainer.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.navigation_rounded,
                size: 15,
                color: HelaColors.tertiaryFixed,
              ),
              const SizedBox(width: 6),
              Text(
                widget.durationText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                ' • ',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              Text(
                widget.distanceText,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        // Recenter Button
        Material(
          color: HelaColors.surfaceContainerLowest.withValues(alpha: 0.95),
          shape: const CircleBorder(),
          elevation: 3,
          child: Tooltip(
            message: 'Recenter Map',
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _recenterMap,
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(
                  Icons.my_location_rounded,
                  color: HelaColors.primary,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Canvas painter rendering authentic Google Maps visual layers
class _GoogleMapCanvasPainter extends CustomPainter {
  final Offset panOffset;
  final double scale;
  final MapStyleType mapStyle;
  final bool showTraffic;
  final double pulseScale;
  final Offset vehiclePosition;
  final double vehicleHeading;
  final IconData vehicleIcon;
  final String vehicleType;

  _GoogleMapCanvasPainter({
    required this.panOffset,
    required this.scale,
    required this.mapStyle,
    required this.showTraffic,
    required this.pulseScale,
    required this.vehiclePosition,
    required this.vehicleHeading,
    required this.vehicleIcon,
    required this.vehicleType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(panOffset.dx, panOffset.dy);
    canvas.scale(scale);

    // 1. Base Map Background
    Color bgColor;
    Color parkColor;
    Color waterColor;
    Color roadColor;
    Color highwayColor;

    switch (mapStyle) {
      case MapStyleType.satellite:
        bgColor = const Color(0xFF1B2A1E);
        parkColor = const Color(0xFF142416);
        waterColor = const Color(0xFF0D2530);
        roadColor = const Color(0xFF334638);
        highwayColor = const Color(0xFF47604E);
        break;
      case MapStyleType.terrain:
        bgColor = const Color(0xFFE5ECE4);
        parkColor = const Color(0xFFD4E6D2);
        waterColor = const Color(0xFFA5C7DC);
        roadColor = const Color(0xFFFFFFFF);
        highwayColor = const Color(0xFFF7C873);
        break;
      case MapStyleType.standard:
        bgColor = const Color(0xFFF4F3F0);
        parkColor = const Color(0xFFDCEAD4);
        waterColor = const Color(0xFFAADAFF);
        roadColor = const Color(0xFFFFFFFF);
        highwayColor = const Color(0xFFFED876);
        break;
    }

    final bgPaint = Paint()..color = bgColor;
    canvas.drawRect(
      Rect.fromLTWH(-200, -200, size.width + 400, size.height + 400),
      bgPaint,
    );

    // 2. Green Tea Valley & National Sanctuary Polygons
    final parkPaint = Paint()
      ..color = parkColor
      ..style = PaintingStyle.fill;

    final teaEstate1 = Path()
      ..moveTo(230, 20)
      ..cubicTo(310, 10, 360, 60, 380, 120)
      ..cubicTo(340, 150, 280, 130, 240, 70)
      ..close();
    canvas.drawPath(teaEstate1, parkPaint);

    final teaEstate2 = Path()
      ..moveTo(10, 160)
      ..cubicTo(60, 140, 80, 200, 70, 260)
      ..cubicTo(30, 290, -10, 250, 0, 190)
      ..close();
    canvas.drawPath(teaEstate2, parkPaint);

    // 3. Ravana Waterfall Stream (Blue Water Feature)
    final riverPaint = Paint()
      ..color = waterColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final riverPath = Path()
      ..moveTo(360, 240)
      ..cubicTo(320, 220, 300, 260, 280, 290)
      ..cubicTo(260, 320, 250, 350, 240, 380);
    canvas.drawPath(riverPath, riverPaint);

    // 4. Scenic Ella Highland Railway Line (Hatched Track)
    final railBedPaint = Paint()
      ..color = const Color(0xFF888888)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final railPath = Path()
      ..moveTo(30, 60)
      ..cubicTo(100, 90, 160, 50, 220, 80)
      ..cubicTo(280, 110, 340, 80, 410, 120);
    canvas.drawPath(railPath, railBedPaint);

    // 5. Local Roads & Highways
    final localRoadBorder = Paint()
      ..color = const Color(0xFFD6D3CD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final localRoadInner = Paint()
      ..color = roadColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final crossRoad1 = Path()
      ..moveTo(50, 20)
      ..cubicTo(90, 80, 110, 150, 130, 210);
    canvas.drawPath(crossRoad1, localRoadBorder);
    canvas.drawPath(crossRoad1, localRoadInner);

    final crossRoad2 = Path()
      ..moveTo(190, 240)
      ..cubicTo(240, 220, 310, 290, 370, 300);
    canvas.drawPath(crossRoad2, localRoadBorder);
    canvas.drawPath(crossRoad2, localRoadInner);

    // 6. B113 Highway Corridor
    final b113Border = Paint()
      ..color = const Color(0xFFD3B670)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;

    final b113Fill = Paint()
      ..color = highwayColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    final highwayPath = Path()
      ..moveTo(80, 120)
      ..cubicTo(140, 95, 175, 145, 215, 130)
      ..cubicTo(255, 110, 270, 170, 330, 205);
    canvas.drawPath(highwayPath, b113Border);
    canvas.drawPath(highwayPath, b113Fill);

    // 7. Active Navigation Route Line (Google Blue with Route Shadow)
    final routePath = Path()
      ..moveTo(105, 138)
      ..cubicTo(140, 105, 215, 140, 295, 185);

    // Outer shadow
    final routeShadow = Paint()
      ..color = const Color(0x334285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(routePath, routeShadow);

    // Route Main Path (Google Maps Navigation Blue #4285F4)
    final routeMain = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(routePath, routeMain);

    // 8. Live Traffic Indicators (Green/Orange Segments along the route)
    if (showTraffic) {
      // Normal flow (Green) along first half
      final trafficGreen = Paint()
        ..color = const Color(0xFF34A853)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      final trafficPathGreen = Path()
        ..moveTo(105, 138)
        ..cubicTo(125, 120, 160, 122, 190, 132);
      canvas.drawPath(trafficPathGreen, trafficGreen);

      // Moderate hill curve traffic (Orange) near Ravana descent
      final trafficOrange = Paint()
        ..color = const Color(0xFFFB8C00)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      final trafficPathOrange = Path()
        ..moveTo(220, 138)
        ..cubicTo(250, 155, 275, 172, 295, 185);
      canvas.drawPath(trafficPathOrange, trafficOrange);
    }

    // 9. Real-Time Moving Vehicle on Route
    _drawLiveVehicle(
      canvas,
      vehiclePosition,
      vehicleHeading,
      vehicleIcon,
      pulseScale,
    );

    canvas.restore();
  }

  void _drawLiveVehicle(
    Canvas canvas,
    Offset position,
    double heading,
    IconData icon,
    double pulse,
  ) {
    canvas.save();
    canvas.translate(position.dx, position.dy);

    // Pulsing radar glow behind vehicle
    final radarPaint = Paint()
      ..color = const Color(0xFF34A853).withValues(
        alpha: (1.4 - pulse).clamp(0.0, 0.35),
      )
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 18 * pulse, radarPaint);

    // White vehicle pill base with drop shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(const Offset(0, 2), 12, shadowPaint);

    final vehicleBasePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 12, vehicleBasePaint);

    final vehicleBorderPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(Offset.zero, 12, vehicleBorderPaint);

    // Draw vehicle icon oriented along the route tangent
    canvas.rotate(heading);
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 15,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: const Color(0xFF1E2E24),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GoogleMapCanvasPainter oldDelegate) {
    return oldDelegate.panOffset != panOffset ||
        oldDelegate.scale != scale ||
        oldDelegate.mapStyle != mapStyle ||
        oldDelegate.showTraffic != showTraffic ||
        oldDelegate.pulseScale != pulseScale ||
        oldDelegate.vehiclePosition != vehiclePosition ||
        oldDelegate.vehicleHeading != vehicleHeading ||
        oldDelegate.vehicleIcon != vehicleIcon;
  }
}
