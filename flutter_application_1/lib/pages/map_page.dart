import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

//import 'package:permission_handler/permission_handler.dart';
enum location_t { SOURCE, DESTINATION, CURRENT }

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  StreamSubscription<LocationData>?
      _locationSubscription; // Suscripción para poder detener la adquision de ubicación y mejorar el rendimiento de la app
  //final Location _locationController = Location();
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  static const LatLng _pGooglePlex =
      LatLng(-2.168456777826358, -79.91654126509425);

  static const LatLng _pHiperMarket =
      LatLng(-2.170786417910632, -79.91667714758492);

  //LatLng? _currentP;

  Marker _sourceLocationMarker = const Marker(
    markerId: MarkerId("_sourceLocation"),
    icon: BitmapDescriptor.defaultMarker,
    position: _pGooglePlex,
    infoWindow: InfoWindow(
      title: 'Source Location',
      snippet: 'Tap for more info',
    ),
  );

  final Marker _destinationLocationMarker = const Marker(
    markerId: MarkerId("_destinationLocation"),
    icon: BitmapDescriptor.defaultMarker,
    position: _pHiperMarket,
    infoWindow: InfoWindow(
      title: 'Destination Location',
      snippet: 'Tap for more info',
    ),
  );
  List<Marker> list = [];

  @override
  void initState() {
    list = [_destinationLocationMarker, _sourceLocationMarker];
    super.initState();
    //_getLocationUpdates();
    /*
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showUpdatedInfoWindow();
    });
    */
    //_showUpdatedInfoWindow();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: // _currentP == null
          //? const Center(
          //    child: Text("Loading..."),
          //  )
          //:
          Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) =>
                _mapController.complete(controller),
            initialCameraPosition:
                const CameraPosition(target: _pGooglePlex, zoom: 16),
            markers: Set<Marker>.of(list),
            //{
            //_sourceLocationMarker.copyWith(
            //  onTapParam: _onMarkerTap,
            //),
            /*
                    Marker(
                      markerId: const MarkerId("_currentLocation"),
                      icon: BitmapDescriptor.defaultMarker,
                      infoWindow: const InfoWindow(
                        title: 'Current Location',
                      ),
                      position: _currentP!,
                    ),
                    */
            //_destinationLocationMarker.copyWith(
            //  onTapParam: _onMarkerTap,
            //)
            //},
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 100,
            left: MediaQuery.of(context).size.width / 2 - 150,
            child: Column(
              children: [
                _buildCustomInfoWindow(
                    context, 'Source Location', 'This is the source location'),
                const SizedBox(height: 200),
                _buildCustomInfoWindow(context, 'Destination Location',
                    'This is the destination location'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomInfoWindow(
      BuildContext context, String title, String snippet) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.white,
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(snippet),
        ],
      ),
    );
  }

  // void _onMarkerTap() {
  //   setState(() {
  //     _sourceLocationMarker = _sourceLocationMarker.copyWith(
  //       infoWindowParam: InfoWindow(
  //         title: 'Source Location',
  //         snippet:
  //             'This is your source location. Latitude: ${_pGooglePlex.latitude}, Longitude: ${_pGooglePlex.longitude}',
  //       ),
  //     );
  //   });

  //   _showUpdatedInfoWindow();
  // }

  /* Mostrar informacion del marcador */
  // Future<void> _showInfoWindow() async {
  //   final GoogleMapController controller = await _mapController.future;
  //   controller.showMarkerInfoWindow(const MarkerId('_currentLocation'));
  // }

  // Future<void> _showUpdatedInfoWindow() async {
  //   final GoogleMapController controller = await _mapController.future;
  //   controller.showMarkerInfoWindow(const MarkerId('_destinationLocation'));
  //   controller.showMarkerInfoWindow(const MarkerId('_sourceLocation'));
  // }

  // Future<void> _cameraToPosition(LatLng pos) async {
  //   final GoogleMapController controller = await _mapController.future;
  //   CameraPosition newCameraPosition = CameraPosition(target: pos, zoom: 16);
  //   await controller.animateCamera(
  //     CameraUpdate.newCameraPosition(newCameraPosition),
  //   );
  //   _locationSubscription?.cancel();
  // }

  /* Función para saber tu ubicación */
  // Future<void> _getLocationUpdates() async {
  //   bool serviceEnabled;
  //   PermissionStatus permissionGranted;

  //   serviceEnabled = await _locationController.serviceEnabled();
  //   if (serviceEnabled) {
  //     serviceEnabled = await _locationController.requestService();
  //   } else {
  //     return;
  //   }

  //   permissionGranted = await _locationController.hasPermission();
  //   if (permissionGranted == PermissionStatus.denied) {
  //     permissionGranted = await _locationController.requestPermission();
  //     if (permissionGranted != PermissionStatus.granted) {
  //       return;
  //     }
  //   }

  //   // Guardar la suscripción para luego poder cancelarla
  //   _locationSubscription = _locationController.onLocationChanged
  //       .listen((LocationData currentLocation) {
  //     if (currentLocation.latitude != null &&
  //         currentLocation.longitude != null) {
  //       setState(() {
  //         _currentP =
  //             LatLng(currentLocation.latitude!, currentLocation.longitude!);
  //         _cameraToPosition(_currentP!);
  //       });
  //     }
  //   });
  // }

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
