import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:taxi/screens/home/widgets/bottom_navbar.dart';
import 'package:taxi/screens/homepage/booking_screen.dart';
import 'package:taxi/screens/homepage/controller/booking_controller.dart';
import 'package:taxi/screens/homepage/controller/homepage_controller.dart';

import 'package:taxi/screens/homepage/homepage_screen.dart';
import 'package:taxi/screens/messages/messages_screen.dart';
import 'package:taxi/screens/performance/performance_screen.dart';
import 'package:taxi/screens/setting/setting_screen.dart';

import 'controller/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  static const routeName = "/homeScreen";
  static final pages = [
    HomepageScreen(),
    MessagesScreen(),
    PerformanceScreen(),
    SettingScreen()
  ];

  final HomepageController _homepageController = Get.find();
  // final BookingController _bookingController = Get.put(BookingController());
  final BookingController _bookingController = Get.find();
  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _homepageController.isNowOrder.listen((val) {
      if (val) {
        _homepageController.show(context);
      }
    });

    _homepageController.isBookingOrder.listen((val) {
      if (val) {
        _homepageController.showBookingOrder(context);
      }
    });

    _homepageController.isCancelOrder.listen((val) {
      if (val) {
        controller.alert(context, "派遣取消通知", "派遣已被取消!");
      }
    });

    _bookingController.isNotifyOrder.listen((val) {
      if (val) {
        controller.alert(context, "預約通知", "預約列表中有10分鐘內要執行的訂單。");
        // _bookingController.showNotifyOrder(
        //     context, _bookingController.notifyOrder);
      }
    });

    _homepageController.isExistBookingOrder.listen((val) {
      if (val) {
        controller.alert(context, "預約提醒", "預約列表內尚有訂單，請確認。");
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.messageId}');

      if (message.notification != null) {
        if (message.notification!.title != "你有一張派遣訂單,請立即查看") {
          controller.alert(context, message.notification!.title!,
              message.notification!.body!);
        }
        print(
            'Message also contained a notification: ${message.notification!.title}');
      }
    });

    return Obx(() => Scaffold(
          appBar: AppBar(
            title: controller.bottomNavbarCurrentIndex == 0
                ? _homepageController.status == 0
                    ? Center(
                        child: Text(
                        controller.appbarTitle,
                        style: TextStyle(color: Colors.black),
                      ))
                    : Text("")
                : Center(
                    child: Text(
                    controller.appbarTitle,
                    style: TextStyle(color: Colors.black),
                  )),
            backgroundColor: Colors.yellow[600],
            actions: [
              controller.bottomNavbarCurrentIndex == 0
                  ? _homepageController.status != 0
                      ? TextButton(
                          onPressed: () {
                            Get.toNamed(BookingScreen.routeName);
                            _bookingController.getBookingListOrder();
                          },
                          child: Text("預約列表"))
                      : SizedBox()
                  : SizedBox()
            ],
          ),
          body: pages[controller.bottomNavbarCurrentIndex],
          bottomNavigationBar: BottomNavbar(),
        ));
  }
}
