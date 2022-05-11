import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';

class LocationController extends GetxController {
  var dio = Dio();

  var billingTimer;

  final RxDouble _totalDistance = 0.0.obs;
  double get totalDistance => _totalDistance.value;

  final RxString _durationTime = "".obs;
  String get durationTime => _durationTime.value;

  final RxString _distance = "".obs;
  String get distance => _distance.value;

  final Rx<LatLng> _currentLocation = LatLng(0, 0).obs;
  LatLng get currentLocation => _currentLocation.value;

  final Rx<LatLng> _destination = LatLng(0.0, 0.0).obs;
  LatLng get destination => _destination.value;

  final _markers = RxMap<MarkerId, Marker>();
  Map<MarkerId, Marker> get markers => _markers;

  PolylinePoints polylinePoints = PolylinePoints();
  final _polylines = RxMap<PolylineId, Polyline>();
  Map<PolylineId, Polyline> get polylines => _polylines;
  RxList<LatLng> polylineCoordinates = [LatLng(0.0, 0.0)].obs;

  late Position position;
  late LatLng lastMapPosition;
  Completer<GoogleMapController> gmapController = Completer();
  bool _isGooglmeMapCompleter = false;

  final GetStorage storageBox = GetStorage();

  @override
  Future<void> onInit() async {
    print("location");

    super.onInit();
  }

  @override
  void dispose() async {
    _disposeController();
    super.dispose();
  }

  void initPoline() => _polylines.value = {};

  Future<void> _disposeController() async {
    print("dispose");
    final GoogleMapController controller = await gmapController.future;
    controller.dispose();
  }

  @override
  void onClose() {
    // TODO: implement onClose

    super.onClose();
  }

  void addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    _markers[markerId] = marker;
    print(_markers[markerId]);
  }

  void removeMarker(String id) {
    MarkerId markerId = MarkerId(id);
    print("removeMarker $id");

    _markers.remove(markerId);
  }

  void setMapCamera(LatLng startPosition, LatLng desPosition) async {
    print("===============  setMapCamera ================");

    print(startPosition);
    print(desPosition);
    final GoogleMapController controller = await gmapController.future;
    // controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
    //   target: startPosition,
    //   zoom: 12,
    // )));

    var nLat, nLon, sLat, sLon;

    if (startPosition.latitude <= desPosition.latitude) {
      sLat = startPosition.latitude;
      nLat = desPosition.latitude;
    } else {
      sLat = desPosition.latitude;
      nLat = startPosition.latitude;
    }
    if (startPosition.longitude <= desPosition.longitude) {
      sLon = startPosition.longitude;
      nLon = desPosition.longitude;
    } else {
      sLon = desPosition.longitude;
      nLon = startPosition.longitude;
    }

    controller.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast: LatLng(nLat, nLon),
          southwest: LatLng(sLat, sLon),
        ),
        25));

    // Future.delayed(Duration(milliseconds: 100), () {});
  }

  void getStopPolyline(start, destination, id) async {
    polylineCoordinates.value = [];

    print("getStopPolyline");

    print(start);
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyABBPDCxrOR-FesGUKaskcaw10PRizIB7o",
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.driving,
    );

    print("===result.points===");
    print(result.points);

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        addPolyLine(polylineCoordinates, id);
      }
    } else {
      print(result.errorMessage);
    }
  }

  void getPolyline(start, destination, type) async {
    polylineCoordinates.value = [];
    print("PolyLine");

    print(destination.latitude);

    if (destination.latitude != 0 &&
        destination.longitude != 0 &&
        start.latitude != 0 &&
        start.longitude != 0) {
      String? apiUrl =
          'https://maps.googleapis.com/maps/api/directions/json?origin=' +
              start.latitude.toString() +
              "," +
              start.longitude.toString() +
              '&destination=' +
              destination.latitude.toString() +
              ',' +
              destination.longitude.toString() +
              '&key=AIzaSyABBPDCxrOR-FesGUKaskcaw10PRizIB7o&language=zh-TW';
      print(apiUrl);
      final res = await dio.get(apiUrl).catchError((error) {
        print(error);
      });

      _durationTime.value =
          res.data["routes"][0]["legs"][0]["duration"]["text"];
      _distance.value = res.data["routes"][0]["legs"][0]["distance"]["text"];

      print(res.data);
    }

    // for (var point in res.data["routes"][0]["legs"][0]["steps"]) {
    //   print(point["start_location"]);
    //   polylineCoordinates.add(LatLng(
    //       point["start_location"]["lat"], point["start_location"]["lng"]));
    //   polylineCoordinates.add(
    //       LatLng(point["end_location"]["lat"], point["end_location"]["lng"]));
    //   addPolyLine(polylineCoordinates);
    //   print(point.last);
    // }

    // int stepsLength = res.data["routes"][0]["legs"][0]["steps"].length;
    // polylineCoordinates.add(LatLng(
    //     res.data["routes"][0]["legs"][0]["steps"][stepsLength - 1]
    //         ["end_location"]["lat"],
    //     res.data["routes"][0]["legs"][0]["steps"][stepsLength - 1]
    //         ["end_location"]["lng"]));
    // addPolyLine(polylineCoordinates);

    // print(res.data["routes"][0]["legs"][0]);
    print("Type" + type + "========================");
    if (type == "start") {
      print("start location ==");
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyABBPDCxrOR-FesGUKaskcaw10PRizIB7o",
        PointLatLng(currentLocation.latitude, currentLocation.longitude),
        PointLatLng(start.latitude, start.longitude),
        travelMode: TravelMode.driving,
      );
      print(result.points);

      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          addPolyLine(polylineCoordinates, 1);
        }
      } else {
        print(result.errorMessage);
      }
    } else if (type == "billing") {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyABBPDCxrOR-FesGUKaskcaw10PRizIB7o",
        PointLatLng(currentLocation.latitude, currentLocation.longitude),
        PointLatLng(destination.latitude, destination.longitude),
        travelMode: TravelMode.driving,
      );
      print(result.points);

      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          addPolyLine(polylineCoordinates, 1);
        }
      } else {
        print(result.errorMessage);
      }
    } else {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyABBPDCxrOR-FesGUKaskcaw10PRizIB7o",
        PointLatLng(currentLocation.latitude, currentLocation.longitude),
        PointLatLng(destination.latitude, destination.longitude),
        travelMode: TravelMode.driving,
      );
      print(result.points);

      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          addPolyLine(polylineCoordinates, 1);
        }
      } else {
        print(result.errorMessage);
      }
    }
  }

  void resetPolyline() async {
    polylineCoordinates.value = [];
  }

  void addBillingRoutePolyline(Position point) async {
    print("****** setBillingRoutePolyline *****");
    polylineCoordinates.remove(LatLng(0.0, 0.0));
    polylineCoordinates.add(LatLng(point.latitude, point.longitude));

    addColorPolyLine(polylineCoordinates, 1, Colors.greenAccent);

    storageBox.write('billingRoute', polylineCoordinates);
  }

  void loadBillingRoute() async {
    final route = storageBox.read('billingRoute');

    if (route != null) {
      List routes = new List.from(route);

      routes.forEach((element) {
        LatLng point = LatLng(element[0], element[1]);
        polylineCoordinates.add(point);
      });

      addColorPolyLine(polylineCoordinates, 1, Colors.greenAccent);
    }
  }

  void clearBillingRoute() async {
    resetPolyline();
    storageBox.remove('billingRoute');
  }

  addColorPolyLine(List<LatLng> polylineCoordinates, ployID, color) {
    PolylineId id = PolylineId("poly" + ployID.toString());
    Polyline polyline = Polyline(
      polylineId: id,
      color: color,
      points: polylineCoordinates,
      width: 8,
    );
    _polylines[id] = polyline;
  }

  addPolyLine(List<LatLng> polylineCoordinates, ployID) {
    PolylineId id = PolylineId("poly" + ployID.toString());
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: polylineCoordinates,
      width: 8,
    );
    _polylines[id] = polyline;
  }

  Future<void> setCurrentLocation() async {
    position = await getCurrentLocation();

    _currentLocation.value = LatLng(position.latitude, position.longitude);
    // _currentLocation.value = LatLng(24.9573827,121.2407764);

    print(currentLocation);

    await _goToTheLake();

    var icon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(8, 8)), 'assets/car.png');

    addMarker(currentLocation, "init", icon);
  }

  void setLocationSec() async {
    // String? apiUrl = dotenv.env['APP_SERVER_URL'].toString() + "/getPrice";
    // print(apiUrl);
    // final res = await dio.get(apiUrl).catchError((error) {
    //   print(error);
    // });

    // var totalPrice = res.data["start"];

    GetStorage storageBox = GetStorage();

    if (storageBox.read("totalDistance") != null) {
      _totalDistance.value = storageBox.read("totalDistance");
    }

    billingTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      // double latBefore = position.latitude;
      // double lngBefore = position.longitude;
      // print("== latBefore ==");
      // print(latBefore);
      // print("== lngBefore ==");
      // print(lngBefore);
      // position = await getCurrentLocation();
      _currentLocation.value = LatLng(position.latitude, position.longitude);

      var icon = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(size: Size(24, 24)), 'assets/car.png');

      addMarker(currentLocation, "init", icon);
      // _goToTheLake();
      // var tempDistance = getDistance(
      //     latBefore, lngBefore, position.latitude, position.longitude);
      // print("== tempDistance ==");
      // print(tempDistance);

      // if (tempDistance / 500 < 0.33) {
      //   _totalDistance.value += (tempDistance / 500);
      // }
      // // _totalDistance.value += tempDistance / 1000;
      // // _totalDistance.value += (tempDistance / 500).truncateToDouble();

      // // _totalDistance.value = _totalDistance.value.truncateToDouble();

      // storageBox.write("totalDistance", totalDistance);
      // print("== totalDistance ==");
      // print(totalDistance);
      // print(currentLocation);
    });
  }

  void cancelBillingTimer() {
    if (billingTimer != null) billingTimer.cancel();
  }

  void initTotalDistance() => _totalDistance.value = 0.0;

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await gmapController.future;

    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: currentLocation,
      zoom: 16.4746,
    )));
  }

  getDistance(double lat1, double lng1, double lat2, double lng2) {
    double def = 6378137.0;
    double radLat1 = _rad(lat1);
    double radLat2 = _rad(lat2);
    double a = radLat1 - radLat2;
    double b = _rad(lng1) - _rad(lng2);
    double s = 2 *
        asin(sqrt(pow(sin(a / 2), 2) +
            cos(radLat1) * cos(radLat2) * pow(sin(b / 2), 2)));
    return (s * def).roundToDouble();
  }

  double _rad(double d) {
    return d * pi / 180.0;
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
  }

  void onCameraMove(CameraPosition position) {
    lastMapPosition = position.target;
  }

  void onMapCreated(GoogleMapController controller) {
    if (!gmapController.isCompleted) {
      gmapController.complete(controller);
      // _isGooglmeMapCompleter = true;
    }
  }

  double calculatePolylineDistane(List<LatLng> polyline) {
    double totalDistance = 0;
    for (int i = 0; i < polyline.length; i++) {
      if (i < polyline.length - 1) {
        // skip the last index
        totalDistance += getStraightLineDistance(
            polyline[i + 1].latitude,
            polyline[i + 1].longitude,
            polyline[i].latitude,
            polyline[i].longitude);
      }
    }
    return totalDistance;
  }

  double getStraightLineDistance(lat1, lon1, lat2, lon2) {
    var R = 6371; // Radius of the earth in km
    var dLat = deg2rad(lat2 - lat1);
    var dLon = deg2rad(lon2 - lon1);
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var d = R * c; // Distance in km
    return d; //in m
  }

  dynamic deg2rad(deg) {
    return deg * (pi / 180);
  }
}
