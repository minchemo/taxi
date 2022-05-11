import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:taxi/screens/homepage/controller/booking_controller.dart';
import 'package:taxi/screens/homepage/controller/homepage_controller.dart';
import 'package:taxi/controller/online_record_controller.dart';
import 'package:taxi/screens/messages/controller/messages_controller.dart';
import 'package:taxi/screens/performance/controller/dispatch_record_controller.dart';
import 'package:taxi/screens/performance/controller/performance_controller.dart';

class HomeController extends GetxController {
  final RxInt _bottomNavbarCurrentIndex = 0.obs;
  int get bottomNavbarCurrentIndex => _bottomNavbarCurrentIndex.value;
  final RxString _appbarTitle = "首頁".obs;
  String get appbarTitle => _appbarTitle.value;

  final MessagesController _messagesController = Get.find();
  final PerformanceController _performanceController = Get.find();
  final DispatchRecordController _dispatchRecordController = Get.find();
  final BookingController _bookingController = Get.find();
  final HomepageController _homepageController = Get.find();

  @override
  void onInit() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');

    super.onInit();
  }

  void alert(BuildContext context, String title, String body) {
    AlertDialog dialog = AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      title: Row(children: const [
        Icon(
          Icons.notifications,
          size: 30,
        ),
        Padding(padding: EdgeInsets.only(right: 10)),
        Text(
          "公司訊息",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
      ]),
      content: Text("$title\n$body", style: TextStyle(fontSize: 16)),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            if (title == "預約通知")
              _bookingController.isNotifyOrder.value = false;
            else if (title == "預約提醒")
              _homepageController.isExistBookingOrder.value = false;
            Navigator.pop(context, true);
          },
          child: Text(
            "確定",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => dialog,
    );

    //print("in alert()");
  }

  void changeBottomNavbar(value) {
    _bottomNavbarCurrentIndex.value = value;
    if (_bottomNavbarCurrentIndex.value == 0) {
      _appbarTitle.value = "首頁";
    } else if (_bottomNavbarCurrentIndex.value == 1) {
      _appbarTitle.value = "訊息";
      _dispatchRecordController.getRecord();
      _messagesController.getCompanyMessage();
    } else if (_bottomNavbarCurrentIndex.value == 2) {
      _appbarTitle.value = "業績查詢";

      _performanceController.getPerformanceData();
    } else if (_bottomNavbarCurrentIndex.value == 3) {
      _appbarTitle.value = "設定";
    }
  }
}
