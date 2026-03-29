import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:gyzyleller/core/services/api.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';

class CustomFlutterMap extends StatefulWidget {
  final double? width;
  final double? height;
  final double? radius;
  final LatLng? center;
  final double? zoom;
  final double? aspectRatio;
  final double? markerSize;
  final VoidCallback? onTap;
  final void Function(TapPosition, LatLng)? onMapTap;
  final List<LatLng> locations;
  final List<LatLng>? polylines;
  final List<IconData>? markerIcons;
  final List<String?>? markerImages;
  final List<Color>? markerColors;
  final List<double>? markerSizes;
  final Color? polylineColor;
  final StrokeCap? strokeCap;
  final StrokeJoin? strokeJoin;
  final bool interactive;

  const CustomFlutterMap({
    super.key,
    this.width,
    this.height,
    this.radius,
    this.center,
    this.zoom,
    this.aspectRatio,
    this.markerSize,
    this.locations = const [],
    this.polylines,
    this.markerIcons,
    this.markerImages,
    this.markerColors,
    this.markerSizes,
    this.polylineColor,
    this.strokeCap,
    this.strokeJoin,
    this.onTap,
    this.onMapTap,
    this.interactive = true,
  });

  @override
  State<CustomFlutterMap> createState() => _CustomFlutterMapState();
}

class _CustomFlutterMapState extends State<CustomFlutterMap> {
  final mapController = MapController();

  @override
  void didUpdateWidget(covariant CustomFlutterMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.center == widget.center && oldWidget.zoom == widget.zoom) {
      return;
    }

    if (widget.center != null) {
      mapController.move(widget.center!, widget.zoom ?? 13.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget map = FlutterMap(
      mapController: mapController,
      options: MapOptions(
        onTap: widget.onMapTap,
        initialCenter: widget.center ?? const LatLng(37.95, 58.38),
        initialZoom: widget.zoom ?? 13.0,
        interactionOptions: InteractionOptions(
          flags: widget.interactive ? InteractiveFlag.all : InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: Api().mapApi,
          userAgentPackageName: 'com.gyzyleller.app',
        ),
        if (widget.polylines != null && widget.polylines!.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: widget.polylines!,
                strokeWidth: 4,
                color: widget.polylineColor ?? ColorConstants.blue,
                strokeCap: widget.strokeCap ?? StrokeCap.round,
                strokeJoin: widget.strokeJoin ?? StrokeJoin.round,
              ),
            ],
          ),
        MarkerLayer(
          markers: List.generate(widget.locations.length, (index) {
            final location = widget.locations[index];
            final icon =
                widget.markerIcons != null && widget.markerIcons!.length > index
                    ? widget.markerIcons![index]
                    : Icons.location_on;
            final color = widget.markerColors != null &&
                    widget.markerColors!.length > index
                ? widget.markerColors![index]
                : Colors.red;
            final size =
                widget.markerSizes != null && widget.markerSizes!.length > index
                    ? widget.markerSizes![index]
                    : (widget.markerSize ?? 30);

            final imagePath = widget.markerImages != null &&
                    widget.markerImages!.length > index
                ? widget.markerImages![index]
                : null;

            return Marker(
              width: size,
              height: size,
              rotate: true,
              point: location,
              child: imagePath != null
                  ? Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                    )
                  : Icon(
                      icon,
                      color: color,
                      size: size,
                    ),
            );
          }),
        ),
      ],
    );

    if (widget.height != null || widget.width != null) {
      map = SizedBox(height: widget.height, width: widget.width, child: map);
    }
    if (widget.aspectRatio != null) {
      map = AspectRatio(aspectRatio: widget.aspectRatio!, child: map);
    }
    if (widget.onTap != null && widget.locations.isNotEmpty) {
      map = Stack(
        children: [
          map,
          Positioned.fill(
            child: GestureDetector(
              onTap: widget.onTap,
              child: const Material(color: Colors.transparent),
            ),
          ),
        ],
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius ?? 10.0),
      child: map,
    );
  }
}
