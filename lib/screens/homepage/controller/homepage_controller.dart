import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math';
import 'package:background_location/background_location.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';

import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:signature/signature.dart';
import 'package:taxi/config/routes.dart';
import 'package:taxi/controller/location_controller.dart';
import 'package:taxi/repositories/order_repository.dart';
import 'package:taxi/screens/home/controller/home_controller.dart';
import 'package:taxi/screens/home/home_screen.dart';
import 'package:taxi/screens/homepage/controller/booking_controller.dart';

import 'package:taxi/screens/homepage/finish_order_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HomepageController extends GetxController {
  var dio = Dio();
  final RxString _token = "".obs;
  String get token => _token.value;
  final RxBool isNowOrder = true.obs;
  String orderDate = "";
  String nowOrderID = "";
  final RxBool isBookingOrder = true.obs;

  final RxBool _receivingOrder = false.obs;
  bool get receivingOrder => _receivingOrder.value;

  final RxBool _isStopover = false.obs;
  bool get isStopover => _isStopover.value;
  var stopoverTimer = null;
  int tempStopoverTime = 0;
  int stopoverTime = 0;

  final _nowOrder = RxMap<String, dynamic>().obs;
  Map<String, dynamic> get nowOrder => _nowOrder.value;

  final _bookingOrder = RxMap<String, dynamic>().obs;
  Map<String, dynamic> get bookingOrder => _bookingOrder.value;

  late FirebaseMessaging messaging;

  final LocationController _locationController = Get.find();

  final RxBool isCancelOrder = false.obs;
  final RxBool isExistBookingOrder = false.obs;

  final RxInt _status = 0.obs;
  int get status => _status.value;

  String id = "";

  final RxInt _totalPrice = 0.obs;
  int get totalPrice => _totalPrice.value;
  final RxInt _startPrice = 0.obs;
  int get startPrice => _startPrice.value;
  var calPriceTimer = null;

  final GetStorage storageBox = GetStorage();

  OrderRepository _orderRepository = OrderRepository();

  final RxBool _isLoadingDriverStatus = false.obs;
  bool get isLoadingDriverStatus => _isLoadingDriverStatus.value;
  final RxBool isLoadingStartOrder = false.obs;

  final RxBool _isLoadingSetNowOrder = false.obs;
  bool get isLoadingSetNowOrder => _isLoadingSetNowOrder.value;
  final RxBool _isLoadingSetBookingOrder = false.obs;
  bool get isLoadingSetBookingOrder => _isLoadingSetBookingOrder.value;
  final RxBool _isLoadingFinishOrder = false.obs;
  bool get isLoadingFinishOrder => _isLoadingFinishOrder.value;

  final SignatureController signatureController = SignatureController(
    penStrokeWidth: 1,
    penColor: Colors.red,
    exportBackgroundColor: Colors.white,

    // onDrawStart: () => print('onDrawStart called!'),
    // onDrawEnd: () => print('onDrawEnd called!'),
  );

  ConnectivityResult? _connectivityResult;
  late StreamSubscription _connectivitySubscription;

  RxDouble _totalDistance = 0.0.obs;
  double get totalDistance => _totalDistance.value;

  @override
  void onInit() async {
    id = storageBox.read("user")["id"];

    // storageBox.remove("executingOrder");
    await _locationController.setCurrentLocation();

    setCurrentStatus();
    if (_status.value == 2) {
      _locationController.loadBillingRoute();
    }

    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      print('Current connectivity status: $result');
      _connectivityResult = result;
    });

    // StreamSubscription<Position> positionStream = Geolocator.getPositionStream(
    //         desiredAccuracy: LocationAccuracy.bestForNavigation,
    //         distanceFilter: 1)
    //     .listen((Position? position) {
    //   print(position);
    //   //開始計費
    //   if (_status.value == 2) {
    //     _locationController.addBillingRoutePolyline(position!);
    //   }

    //   _locationController.setCurrentLocation();
    // });

    //設置背景通知
    // BackgroundLocation.setAndroidNotification(
    //   title: "Taxi 程式執行中",
    //   message: "定位已啟動...",
    //   icon: "@mipmap/ic_launcher",
    // );
    BackgroundLocation.setAndroidConfiguration(500);
    BackgroundLocation.startLocationService(distanceFilter: 5);
    BackgroundLocation.getLocationUpdates((location) {
      print(location);
      //開始計費
      if (_status.value == 2) {
        _locationController.addBillingRoutePolyline(location);
      }

      _locationController.setCurrentLocation();
    });

    super.onInit();
  }

  void setCurrentStatus() async {
    print(" === setCurrentStatus ===");
    _isLoadingDriverStatus.value = true;
    int driverStatus = await getDriverStatus();

    if (driverStatus == 1) {
      listenOrder();
      _status.value = 1;
    } else if (driverStatus == 2) {
      print("init ======== 2 ======");
      listenOrder();

      String orderID = storageBox.read("executingOrder");
      print(orderID);
      await setNowOrder(orderID);

      if (nowOrder["status"] == 2) {
        _status.value = 2;
        if (nowOrder["lockedPrice"] == -1) {
          _locationController.setLocationSec();
        }
        // startBilling();
        _receivingOrder.value = true;
      } else if (nowOrder["status"] == 1) {
        _status.value = 1;
        _receivingOrder.value = true;
      }

      print(nowOrder);
    }

    _isLoadingDriverStatus.value = false;
  }

  Future<int> getDriverStatus() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("driver/$id");
    DatabaseEvent event = await ref.once();

    final data = jsonEncode(event.snapshot.value);
    final res = jsonDecode(data);
    print("===");

    if (res != null) {
      print("Driver Status ${res["status"]}");
      return res["status"];
    } else {
      return 0;
    }
  }

  Future<String> getNowOrderID() async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("driver/$id/order/now");
    DatabaseEvent event = await ref.once();
    final data = jsonEncode(event.snapshot.value);
    final res = jsonDecode(data);
    print("nowOrderID ${res["id"]}");
    return res["id"];
  }

  Future<void> makePhoneCall(String phoneNum) async {
    print(phoneNum);
    String url = 'tel://%23 31%23$phoneNum';

    launch(url);
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('cant');
      // 錯誤處理 無法撥打
    }
  }

  void listenOrder() {
    DatabaseReference ref = FirebaseDatabase.instance.ref("driver/$id");
    print(ref.path);
    Stream<DatabaseEvent> stream = ref.onValue;
    // final BookingController _bookingController = Get.find();

    stream.listen((DatabaseEvent event) async {
      final data = jsonEncode(event.snapshot.value);
      final res = jsonDecode(data);

      print('進行中訂單');
      print(storageBox.read("executingOrder"));

      if (res["order"] != null) {
        if (res["order"]["now"] != null &&
            res["order"]["now"]["id"] != "" &&
            res["status"] != 2 &&
            storageBox.read("executingOrder") == null) {
          print("now 訂單");
          await setNowOrder(res["order"]["now"]["id"]);
          isNowOrder.value = true;
        } else if (res["order"]["newOrder"] != null &&
            res["order"]["newOrder"]["id"] != "" &&
            res["status"] != 0) {
          print("預約訂單");
          print(res["order"]["newOrder"]["id"]);
          final resOrder = await getOrderByID(res["order"]["newOrder"]["id"]);
          _bookingOrder.value.value = resOrder["data"];

          // final BookingController _bookingController = Get.find();
          // await _bookingController.getBookingListOrder();
          isBookingOrder.value = true;
        } else if (res["order"]["now"] != null &&
            res["order"]["now"]["id"] == "" &&
            res["status"] == 2 &&
            storageBox.read("executingOrder") != null) {
          isCancelOrder.value = true;

          print("取消訂單");
          initStatus();

          isCancelOrder.value = false;
        } else {
          print("沒有任何即時訂單");
        }
      }

      // print("a ${values} ");
      // if (event.snapshot.value == null) print('nothing');
    });
  }

  Future<Map<String, dynamic>> getOrderByID(id) async {
    print("=========== getOrderByID ==========");
    String? apiUrl = dotenv.env['APP_SERVER_URL'].toString() + '/getOneOrder';

    final json = {"id": id};
    print(json);
    final res = await dio.post(apiUrl, data: json).catchError((error) {
      print(error);
    });

    print(res.data["message"]);

    if (res.data["message"] != "Unfound Order") {
      // print(res);
      res.data["data"]["date"] = DateFormat('yyyy/MM/dd kk:mm').format(
          DateTime.fromMillisecondsSinceEpoch(
              res.data["data"]["orderDate"] * 1000));

      if (res.data["data"]["lockedPrice"] != -1) {
        res.data["data"]["price"] = res.data["data"]["lockedPrice"];
      }
    }
    // LatLng position = LatLng(double.parse(res.data["data"]["endLat"]),
    //     double.parse(res.data["data"]["endLnt"]));

    // _locationController.addMarker(
    //     position, "des", BitmapDescriptor.defaultMarkerWithHue(90));
    // _locationController.getPolyline(position);

    return res.data;
    // _nowOrder.value.value = res.data["data"];

    // orderDate = DateFormat('yyyy/MM/dd kk:mm').format(
    //     DateTime.fromMillisecondsSinceEpoch(
    //         res.data["data"]["orderDate"] * 1000));
  }

  Future<void> setNowOrder(id) async {
    final res = await getOrderByID(id);
    _nowOrder.value.value = res["data"];

    orderDate = DateFormat('yyyy/MM/dd kk:mm').format(
        DateTime.fromMillisecondsSinceEpoch(nowOrder["orderDate"] * 1000));
  }

  Future<void> fixedPointBilling() async {
    print("======定點計費======");

    List<dynamic> list = storageBox.read("points");

    print(list);

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);

    LatLng firstPosition =
        LatLng(list[list.length - 1]["lat"]!, list[list.length - 1]["lnt"]!);

    LatLng secondPosition = LatLng(position.latitude, position.longitude);

    if (nowOrder["endLat"] != "" && nowOrder["endLnt"] != "") {
      LatLng desPosition = LatLng(
          double.parse(nowOrder["endLat"]), double.parse(nowOrder["endLnt"]));

      _locationController.getStopPolyline(
          secondPosition, desPosition, "stop" + (list.length - 1).toString());
    }

    // double distance = await _orderRepository.getGoogleMapDistance(
    //     firstPosition, secondPosition);

    double distance = _locationController
        .calculatePolylineDistane(_locationController.billingCoordinates);

    print('距離');
    print(distance);

    double totalDistance = 0.0;

    if (storageBox.read("totalDistance") == null) {
      totalDistance = distance;
      print(totalDistance);
    } else {
      totalDistance = storageBox.read("totalDistance");
      print(totalDistance);
      // totalDistance = totalDistance + distance;
      totalDistance = distance;
      print(totalDistance);
    }

    storageBox.write("totalDistance", totalDistance);

    _locationController.addMarker(
        secondPosition,
        "stop" + list.length.toString(),
        BitmapDescriptor.defaultMarkerWithHue(90));

    list.add({"lat": position.latitude, "lnt": position.longitude});
    storageBox.write("points", list);

    // double.parse(nowOrder["startLat"]);
  }

  Future<void> startBilling() async {
    _status.value = 2;

    print("startBilling");
    String? apiUrl = dotenv.env['APP_SERVER_URL'].toString() + '/executeOrder';

    final json = {"id": nowOrder["id"]};
    print(json);
    final res = await dio.post(apiUrl, data: json).catchError((error) {
      print(error);
    });

    List<Map<String, double>> pointsList = [];
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);

    pointsList.add({"lat": position.latitude, "lnt": position.longitude});

    storageBox.write("points", pointsList);

    if (nowOrder["lockedPrice"] == -1) _locationController.setLocationSec();
    _locationController.removeMarker("start");

    if (nowOrder["endLat"] != "" && nowOrder["endLnt"] != "") {
      LatLng desPosition = LatLng(
          double.parse(nowOrder["endLat"]), double.parse(nowOrder["endLnt"]));
      LatLng startPosition = LatLng(double.parse(nowOrder["startLat"]),
          double.parse(nowOrder["startLnt"]));
      _locationController.addMarker(
          desPosition, "des", BitmapDescriptor.defaultMarkerWithHue(90));
      print("目的地$desPosition");
      _locationController.setMapCamera(
          _locationController.currentLocation, desPosition);
      _locationController.getPolyline(startPosition, desPosition, "billing");
    }
  }

  Future<void> setDriverStatus(value) async {
    print("setDriverStatus!!!");
    _isLoadingDriverStatus.value = true;
    _status.value = value;
    DatabaseReference ref = FirebaseDatabase.instance.ref("driver/" + id);
    print(ref.path);

    await _locationController.setCurrentLocation();
    ref.update({
      'status': value,
      'lat': _locationController.currentLocation.latitude,
      'lng': _locationController.currentLocation.longitude
    });

    print(_locationController.currentLocation.latitude);
    print(_locationController.currentLocation.longitude);

    if (value == 1) {
      await ref.child("order/now").update({"id": ""});
    }
    // await _locationController.setCurrentLocation();
    _isLoadingDriverStatus.value = false;
  }

  Future<void> setNowOrderStatus(orderID) async {
    if (!isLoadingSetNowOrder) {
      print("setNowOrder");
      _isLoadingSetNowOrder.value = true;
      storageBox.write("executingOrder", orderID);

      LatLng startPosition = LatLng(double.parse(nowOrder["startLat"]),
          double.parse(nowOrder["startLnt"]));
      LatLng desPosition = LatLng(0, 0);

      if (nowOrder["endLat"] != "" && nowOrder["endLnt"] != "") {
        desPosition = LatLng(
            double.parse(nowOrder["endLat"]), double.parse(nowOrder["endLnt"]));
      }

      if (nowOrder["startLat"] != "" && nowOrder["startLnt"] != "") {
        _locationController.setMapCamera(
            _locationController.currentLocation, startPosition);

        var icon = await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(24, 24)), 'assets/position.png');

        _locationController.addMarker(startPosition, "start", icon);
      }

      _locationController.getPolyline(startPosition, desPosition, "start");

      String? apiUrl =
          dotenv.env['APP_SERVER_URL'].toString() + '/dispatchOrder';
      print(nowOrder);
      final json = {"id": orderID};
      print(json);
      final res = await dio.post(apiUrl, data: json).catchError((error) {
        print(error);
      });

      _receivingOrder.value = true;

      DatabaseReference ref = FirebaseDatabase.instance.ref("driver/" + id);
      ref.update({
        'status': 2,
        'lat': _locationController.currentLocation.latitude,
        'lng': _locationController.currentLocation.longitude
      });

      _isLoadingSetNowOrder.value = false;

      print(res);
    }
  }

  void initStatus() async {
    print("====== initStatus ======");

    if (calPriceTimer != null) calPriceTimer.cancel();

    _totalPrice.value = 0;
    _receivingOrder.value = false;
    _totalDistance.value = 0.0;
    storageBox.remove("stopoverTime");
    storageBox.remove("totalDistance");

    stopoverTime = 0;

    _locationController.removeMarker("des");
    _locationController.removeMarker("start");
    _locationController.initPoline();

    List pointsList = storageBox.read("points");

    for (int i = 0; i < pointsList.length; i++) {
      _locationController.removeMarker("stop" + i.toString());
    }

    storageBox.remove("points");
    storageBox.remove("executingOrder");

    DatabaseReference ref = FirebaseDatabase.instance.ref("driver/" + id);
    await ref.child("order/now").update({"id": ""});
    setDriverStatus(1);
  }

  void lastFinish() async {
    print("lastFinish");
//  initStatus();
    Get.back();

    // if (await checkExistBookingOrder()) {
    //   print("預約提醒True");
    //   isExistBookingOrder.value = true;
    // }

    // Get.offNamed(HomeScreen.routeName);
  }

  void finishOrder(payType) async {
    _receivingOrder.value = false;
    _isLoadingFinishOrder.value = true;

    print("===============finishOrder===============");
    String? apiUrl = dotenv.env['APP_SERVER_URL'].toString() + '/finishOrder';
    var json = {};

    _totalDistance.value = storageBox.read("totalDistance");
    print(totalDistance);

    int resPrice = 0;

    if (payType == 1) {
      String imageBase64 = await exportSignatrueToBase64();
      if (nowOrder["lockedPrice"] == -1) {
        // Map<String, dynamic> resMap = {};

        print(totalDistance);
        // resMap = await getPrice();

        json = {
          "id": nowOrder["id"],
          "price": totalPrice,
          "totalWaitTime": stopoverTime,
          "totalDistance": totalDistance,
          "payType": payType,
          "sign": imageBase64
        };

        resPrice = totalPrice;
      } else {
        json = {
          "id": nowOrder["id"],
          "price": nowOrder["price"],
          "totalWaitTime": stopoverTime,
          "totalDistance": totalDistance,
          "payType": payType,
          "sign": imageBase64
        };

        resPrice = nowOrder["price"];
      }
      signatureController.clear();
    } else {
      if (nowOrder["lockedPrice"] == -1) {
        json = {
          "id": nowOrder["id"],
          "price": totalPrice,
          "totalWaitTime": stopoverTime,
          "totalDistance": totalDistance,
          "payType": payType,
          "sign": ""
        };

        resPrice = totalPrice;
      } else {
        json = {
          "id": nowOrder["id"],
          "price": nowOrder["price"],
          "totalWaitTime": stopoverTime,
          "totalDistance": totalDistance,
          "payType": payType,
          "sign": ""
        };

        resPrice = nowOrder["price"];
      }
    }

    print(json);
    print(nowOrder["userPhone"]);

    List res = [];
    if (payType == 1) {
      res = await Future.wait([
        dio.post(apiUrl, data: json),
        _orderRepository.patchOrder(
            id, payType, resPrice, nowOrder["userPhone"])
      ]);
    } else {
      res = await Future.wait([
        dio.post(apiUrl, data: json),
        // _orderRepository.payUserOrder(nowOrder["userPhone"], nowOrder["id"]),
        _orderRepository.patchOrder(
            id, payType, resPrice, nowOrder["userPhone"])
      ]);
      if (nowOrder["userPhone"] != "") {
        await _orderRepository.payUserOrder(
            nowOrder["userPhone"], nowOrder["id"]);
      }
    }

    _locationController.clearBillingRoute();
    storageBox.remove("executingOrder");
    Get.back();

    initStatus();
    if (await checkExistBookingOrder()) {
      print("預約提醒True");
      isExistBookingOrder.value = true;
    }

    Future.delayed(
        Duration(seconds: 1), () => _isLoadingFinishOrder.value = false);

    Get.toNamed(FinishOrderScreen.routeName);

    print(res);
  }

  void calPriceTimer5s() {
    calPriceTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      calPrice();
    });
  }

  void stopHalfway() {
    if (stopoverTimer != null) {
      _isStopover.value = false;
      stopoverTimer.cancel();
    }
  }

  Future<void> calPrice() async {
    print("=== calPrice ===");

    Map<String, dynamic> resMap = {};
    double tempTotalDistance = 0.0;
    if (storageBox.read("totalDistance") != null) {
      _totalDistance.value = storageBox.read("totalDistance");

      if (totalDistance <= 3) {
        tempTotalDistance = 0.0;
      } else {
        tempTotalDistance = _totalDistance.value - 3;
      }

      print(totalDistance);
    }

    if (nowOrder["lockedPrice"] == -1) {
      resMap = await getPrice();
      _startPrice.value = resMap["start"];
      _totalPrice.value = (resMap["start"] +
              (resMap["distance"] *
                  double.parse((tempTotalDistance / 0.5).toStringAsFixed(0))))
          .round();

      // _totalPrice.value = int.parse((resMap["start"] +
      //         resMap["distance"] *
      //             double.parse((totalDistance).toStringAsFixed(0)) +
      //         double.parse((stopoverTime / 600).toStringAsFixed(0)) *
      //             resMap["time"])
      //     .toStringAsFixed(0));
    } else {
      resMap = await getPrice();

      _totalPrice.value = (nowOrder["price"]);
    }
  }

  void show(BuildContext context) {
    // Timer(Duration(seconds: 10), () {
    //   isNowOrder.value = false;
    //   Get.back();
    // });

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                  height: 450,
                  padding:
                      EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 10),
                  margin: EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black,
                            offset: Offset(0, 10),
                            blurRadius: 10),
                      ]),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                                onTap: () {
                                  closeNowOrder();
                                },
                                child: Icon(Icons.close))),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Text("派遣通知",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ))),
                            Text("VIP")
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Text(orderDate,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ))),
                            nowOrder["price"] != 0
                                ? Text("\$ ${nowOrder["price"]}")
                                : Text("")
                          ],
                        ),
                        Text("${nowOrder["userName"]}"),
                        SizedBox(height: 10),
                        Text("上車:",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            )),
                        Text("${nowOrder["startLocation"]}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            )),
                        SizedBox(height: 10),
                        Text("目的地:",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            )),
                        Text("${nowOrder["endLocation"]}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            )),
                        SizedBox(height: 10),
                        Text("${nowOrder["description"]}",
                            style: TextStyle(
                              fontSize: 16,
                            )),
                        SizedBox(height: 10),
                        SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                                onPressed: () async {
                                  if (!isLoadingSetNowOrder) {
                                    await setNowOrderStatus(nowOrder["id"]);
                                    isNowOrder.value = false;
                                    Get.back();
                                  }
                                },
                                style: ButtonStyle(
                                    fixedSize: (MaterialStateProperty.all(
                                        Size(double.infinity, 80))),
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.yellow[800])),
                                child: !isLoadingSetNowOrder
                                    ? Text("接單",
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 18))
                                    : CircularProgressIndicator()))
                      ])));
        }).then((exit) {
      if (exit == null) {
        if (!isLoadingSetNowOrder) {
          isNowOrder.value = false;
        }
        // closeNowOrder();
      }
    });
  }

  void showBookingOrder(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                  height: 450,
                  padding:
                      EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 10),
                  margin: EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black,
                            offset: Offset(0, 10),
                            blurRadius: 10),
                      ]),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                                onTap: () {
                                  closeBookingOrder();
                                },
                                child: Icon(Icons.close))),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Expanded(
                                child: Text("派遣通知",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ))),
                            Text("VIP")
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Text(bookingOrder["date"],
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ))),
                            bookingOrder["price"] != 0
                                ? Text("\$ ${bookingOrder["price"]}")
                                : Text("")
                          ],
                        ),
                        Text("${bookingOrder["userName"]}"),
                        SizedBox(height: 10),
                        Text("上車:",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            )),
                        Text("${bookingOrder["startLocation"]}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            )),
                        SizedBox(height: 10),
                        Text("目的地:",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            )),
                        Text("${bookingOrder["endLocation"]}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            )),
                        SizedBox(height: 10),
                        Text("${bookingOrder["description"]}",
                            style: TextStyle(
                              fontSize: 16,
                            )),
                        SizedBox(height: 10),
                        SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                                onPressed: () async {
                                  if (!isLoadingSetBookingOrder) {
                                    _isLoadingSetBookingOrder.value = true;
                                    await setBookingOrder(bookingOrder["id"]);
                                    final BookingController _bookingController =
                                        Get.find();
                                    await _bookingController
                                        .getBookingListOrder();
                                    // _receivingOrder.value = true;
                                    isBookingOrder.value = false;
                                    _isLoadingSetBookingOrder.value = false;
                                    Get.back();
                                  }
                                },
                                style: ButtonStyle(
                                    fixedSize: (MaterialStateProperty.all(
                                        Size(double.infinity, 80))),
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.yellow[800])),
                                child: Text("接單",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 18))))
                      ])));
        }).then((exit) {
      if (exit == null) {
        isBookingOrder.value = false;
        closeBookingOrder();
      }
    });
  }

  Future<void> setBookingOrder(bookingOrderID) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("driver/" + id);
    await ref.child("order/newOrder").update({"id": ""});
    await ref.child("order/booking").update({bookingOrderID: bookingOrderID});

    String? apiUrl = dotenv.env['APP_SERVER_URL'].toString() + '/dispatchOrder';
    final json = {"id": bookingOrderID};
    print(json);
    await dio.post(apiUrl, data: json).catchError((error) {
      print(error);
    });

    isBookingOrder.value = false;
    Get.back();
  }

  void closeBookingOrder() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("driver/" + id);
    await ref.child("order/newOrder").update({"id": ""});
    isBookingOrder.value = false;
    Get.back();
  }

  void closeNowOrder() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("driver/" + id);
    await ref.child("order/now").update({"id": ""});
    isNowOrder.value = false;
    Get.back();
  }

  Future<Map<String, dynamic>> getPrice() async {
    print("========= GetPrice =========");
    String? apiUrl = dotenv.env['APP_SERVER_URL'].toString() + '/getPrice';

    final json = {};
    // print(json);
    final res = await dio.post(apiUrl, data: json).catchError((error) {
      print(error);
    });

    return res.data["data"];
  }

  Future<String> exportSignatrueToBase64() async {
    final exportSignatureController = SignatureController(
        penStrokeWidth: 2,
        penColor: Colors.black,
        exportBackgroundColor: Colors.white,
        points: signatureController.points

        // onDrawStart: () => print('onDrawStart called!'),
        // onDrawEnd: () => print('onDrawEnd called!'),
        );
    debugPrint("exportSignatrueToBase64");

    final imageData = await exportSignatureController.toPngBytes();

    // printLongString(imageData.toString());
    String imageBase64 = base64Encode(imageData!);
    return imageBase64;
  }

  Future<bool> checkExistBookingOrder() async {
    print("======== checkExistBookingOrder ==========");
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("driver/$id/order/booking");
    print(ref.path);

    DatabaseEvent event = await ref.once();
    final data = jsonEncode(event.snapshot.value);
    final res = jsonDecode(data);

    print(res);

    if (res != null) return true;

    return false;
  }
}
