import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:delivery_tracker/services/location_service.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  late GoogleMapController mapController;
  Set<Marker> markers = {};
  CameraPosition? initialPosition;

  @override
  void initState() {
    super.initState();
    _loadLocation();
    _startLocationUpdates();
  }

  Future<void> _loadLocation() async {
    final pos = await LocationService.getCurrentLocation();
    if (pos != null) {
      initialPosition = CameraPosition(target: LatLng(pos.latitude, pos.longitude), zoom: 15);
      setState(() {
        markers.add(
          Marker(
            markerId: const MarkerId("current"),
            position: LatLng(pos.latitude, pos.longitude),
            infoWindow: const InfoWindow(title: "Tu ubicación"),
          ),
        );
      });
    }
  }

  void _startLocationUpdates() {
    Future.delayed(const Duration(seconds: 0), () async {
      while (mounted) {
        await LocationService.updateDriverLocation("driver-123");
        await Future.delayed(const Duration(seconds: 30));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seguimiento en Tiempo Real"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              SupabaseService.client.auth.signOut();
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: initialPosition != null
          ? GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: initialPosition!,
              onMapCreated: (controller) => mapController = controller,
              markers: markers,
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}