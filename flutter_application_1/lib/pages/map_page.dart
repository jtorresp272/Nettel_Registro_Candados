import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/enviar_datos_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
//import 'package:permission_handler/permission_handler.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  StreamSubscription<LocationData>?
      _locationSubscription; // Suscripción para poder detener la adquision de ubicación y mejorar el rendimiento de la app
  final Location _locationController = Location();
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  static const LatLng _pGooglePlex =
      LatLng(-2.168456777826358, -79.91654126509425);

  static const LatLng _pHiperMarket =
      LatLng(-2.170786417910632, -79.91667714758492);

  LatLng? _currentP;

  Marker _currentLocationMarker = const Marker(
    markerId: MarkerId("_sourceLocation"),
    icon: BitmapDescriptor.defaultMarker,
    position: _pGooglePlex,
    infoWindow: InfoWindow(
      title: 'Source Location',
      snippet: 'Tap for more info',
    ),
  );

  @override
  void initState() {
    super.initState();
    _getLocationUpdates();
    _showInfoWindow();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentP == null
          ? const Center(
              child: Text("Loading..."),
            )
          : GoogleMap(
              onMapCreated: (GoogleMapController controller) =>
                  _mapController.complete(controller),
              initialCameraPosition:
                  const CameraPosition(target: _pGooglePlex, zoom: 16),
              markers: {
                _currentLocationMarker.copyWith(
                  onTapParam: _onMarkerTap,
                ),
                Marker(
                  markerId: const MarkerId("_currentLocation"),
                  icon: BitmapDescriptor.defaultMarker,
                  infoWindow: const InfoWindow(
                    title: 'Current Location',
                  ),
                  position: _currentP!,
                ),
                const Marker(
                  markerId: MarkerId("_destinationLocation"),
                  icon: BitmapDescriptor.defaultMarker,
                  position: _pHiperMarket,
                ),
              },
            ),
    );
  }

  void _onMarkerTap() {
    setState(() {
      _currentLocationMarker = _currentLocationMarker.copyWith(
        infoWindowParam: InfoWindow(
          title: 'Source Location',
          snippet:
              'This is your current location. Latitude: ${_currentP!.latitude}, Longitude: ${_currentP!.longitude}',
        ),
      );
    });

    _showUpdatedInfoWindow();
  }

  /* Mostrar informacion del marcador */
  Future<void> _showInfoWindow() async {
    final GoogleMapController controller = await _mapController.future;
    controller.showMarkerInfoWindow(const MarkerId('_currentLocation'));
  }

  Future<void> _showUpdatedInfoWindow() async {
    final GoogleMapController controller = await _mapController.future;
    controller.showMarkerInfoWindow(const MarkerId('_sourceLocation'));
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition = CameraPosition(target: pos, zoom: 16);
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(_newCameraPosition),
    );
  }

  /* Función para saber tu ubicación */
  Future<void> _getLocationUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
    } else {
      return;
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Guardar la suscripción para luego poder cancelarla
    _locationSubscription = _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentP =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          _cameraToPosition(_currentP!);
        });
      }
    });
  }

  /* Custom icon
  BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(size: Size(48, 48)),
    'assets/icon.png'); // Asegúrate de que el icono esté en la carpeta 'assets'
   */

  @override
  void dispose() {
    // TODO: implement dispose
    _locationSubscription?.cancel();
    super.dispose();
  }
}