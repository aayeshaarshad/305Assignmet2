import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPage extends StatelessWidget {
  final void Function(GoogleMapController) onMapCreated;
  final LatLng _initialPosition = LatLng(37.42796133580664, -122.085749655962);

  LocationPage(this.onMapCreated);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: <Widget>[
        GoogleMap(
          initialCameraPosition:
              CameraPosition(target: _initialPosition, zoom: 10),
          mapType: MapType.normal,
          onMapCreated: onMapCreated,
          myLocationEnabled: true,
        )
      ]),
    );
  }
}

// class _LocationPageState extends State<LocationPage> {
//   final LatLng _initialPosition = LatLng(37.42796133580664, -122.085749655962);
//   Function _onMapCreated;
//   _LocationPageState(this._onMapCreated);
//   // late GoogleMapController _googleMapController;
//   // Location _location = Location();

//   // void _onMapCreated(GoogleMapController controller) {
//   //   _googleMapController = controller;
//   //   _location.onLocationChanged.listen((currentLocation) {
//   //     _googleMapController.animateCamera(
//   //       CameraUpdate.newCameraPosition(
//   //         CameraPosition(
//   //           target:
//   //               LatLng(currentLocation.latitude!, currentLocation.longitude!),
//   //           zoom: 15,
//   //         ),
//   //       ),
//   //     );
//   //   });
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(children: <Widget>[
//         GoogleMap(
//           initialCameraPosition:
//               CameraPosition(target: _initialPosition, zoom: 10),
//           mapType: MapType.normal,
//           onMapCreated: _onMapCreated,
//           myLocationEnabled: true,
//         )
//       ]),
//     );
//   }
// }
