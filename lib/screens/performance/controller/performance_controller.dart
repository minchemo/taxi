import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:taxi/methods/methods.dart';
import 'package:taxi/repositories/online_record_repository.dart';
import 'package:taxi/controller/online_record_controller.dart';
import 'package:taxi/repositories/order_repository.dart';

class PerformanceController extends GetxController
    with SingleGetTickerProviderMixin {
  late TabController dateTabController;
  late TabController dateController;

  final _oneMonthData = RxMap<String, dynamic>();
  Map<String, dynamic> get oneMonthData => _oneMonthData;

  final _oneWeekData = RxMap<String, dynamic>();
  Map<String, dynamic> get oneWeekData => _oneWeekData;

  final _oneDayData = RxMap<String, dynamic>();
  Map<String, dynamic> get oneDayData => _oneDayData;

  final GetStorage storageBox = GetStorage();
  final OrderRepository _orderRepository = OrderRepository();

  final OnlineRecordController _onlineRecordController = Get.find();
  final RxString _amountpay = "".obs;
  String get amountpay => _amountpay.value;

  final RxInt _currentTabBarIndex = 0.obs;
  int get currentTabBarIndex => _currentTabBarIndex.value;

  @override
  void onInit() {
    debugPrint("業績init");
    // getCurrentTime();
    dateTabController = TabController(length: 3, vsync: this);
    dateTabController.addListener(onChangeTab);
    dateController = TabController(length: 3, vsync: this);
    super.onInit();
  }

  void getPerformanceData() async {
    // await getUnpayCash();
    getMonthData();
    getWeekData();
    getDayData();
  }

  // Future<void> getUnpayCash() async {
  //   String id = storageBox.read("user")["id"];
  //   List res = await _orderRepository.getUnpayDriverOrder(id);
  //   if (res.isNotEmpty) {
  //     for (int i = 0; i < res.length; i++) {
  //       unPayCash += res[i]["price"];
  //     }

  //     _amountpay.value = unPayCash.toStringAsFixed(1);
  //   } else {
  //     _amountpay.value = "暫無資料";
  //   }

  //   print(amountpay);
  // }

  void onChangeTab() => _currentTabBarIndex.value = dateTabController.index;

  void getDayData() async {
    print("===== getDayData =====");
    Map<String, dynamic> res = Methods().getThisDay();
    _oneDayData["startDate"] = DateFormat('yyyy/MM/dd').format(
        DateTime.fromMillisecondsSinceEpoch(
            res["startDayOfDayTimestamp"] * 1000));
    _oneDayData["lastDate"] = DateFormat('yyyy/MM/dd').format(
        DateTime.fromMillisecondsSinceEpoch(
            res["lastDayOfDayTimestamp"] * 1000));

    String id = storageBox.read("user")["id"];
    List doneOrderList =
        await _orderRepository.getAllDoneOrderByTimeAndDriverId(
            id, res["startDayOfDayTimestamp"], res["lastDayOfDayTimestamp"]);
    double unGetSign = 0.0;
    double unPayCash = 0.0;

    for (int i = 0; i < doneOrderList.length; i++) {
      if (doneOrderList[i]["status"] == 3) {
        if (!doneOrderList[i]["driverHandled"]) {
          if (doneOrderList[i]["payType"] == 1) {
            unGetSign += doneOrderList[i]["price"];
          } else {
            unPayCash += doneOrderList[i]["price"];
          }
        }
      }
    }
    _oneDayData["amountpay"] =
        (unGetSign + unPayCash) * (storageBox.read("user")["sharing"] / 100) -
            unGetSign;
    print(oneWeekData["startDate"]);
    getOnlineTimeInOneDay();
    getMileageAndAchievementInDay();
  }

  void getMonthData() async {
    print("===== getMonthData =====");
    Map<String, dynamic> res = Methods().getThisMonth();

    _oneMonthData["startDate"] = DateFormat('yyyy/MM/dd').format(
        DateTime.fromMillisecondsSinceEpoch(
            res["startDayOfMonthTimestamp"] * 1000));
    _oneMonthData["lastDate"] = DateFormat('yyyy/MM/dd').format(
        DateTime.fromMillisecondsSinceEpoch(
            res["lastDayOfMonthTimestamp"] * 1000));

    String id = storageBox.read("user")["id"];

    List doneOrderList =
        await _orderRepository.getAllDoneOrderByTimeAndDriverId(id,
            res["startDayOfMonthTimestamp"], res["lastDayOfMonthTimestamp"]);
    double unGetSign = 0.0;
    double unPayCash = 0.0;

    for (int i = 0; i < doneOrderList.length; i++) {
      if (doneOrderList[i]["status"] == 3) {
        if (!doneOrderList[i]["driverHandled"]) {
          if (doneOrderList[i]["payType"] == 1) {
            unGetSign += doneOrderList[i]["price"];
          } else {
            unPayCash += doneOrderList[i]["price"];
          }
        }
      }
    }

    _oneMonthData["amountpay"] =
        (unGetSign + unPayCash) * (storageBox.read("user")["sharing"] / 100) -
            unGetSign;

    getOnlineTimeInOneMonth();
    getMileageAndAchievementInMonth();
  }

  void getWeekData() async {
    print("===== getWeekData =====");
    Map<String, dynamic> res = Methods().getThisWeek();
    _oneWeekData["startDate"] = DateFormat('yyyy/MM/dd').format(
        DateTime.fromMillisecondsSinceEpoch(
            res["startDayOfWeekTimestamp"] * 1000));
    _oneWeekData["lastDate"] = DateFormat('yyyy/MM/dd').format(
        DateTime.fromMillisecondsSinceEpoch(
            res["lastDayOfWeekTimestamp"] * 1000));

    String id = storageBox.read("user")["id"];
    List doneOrderList =
        await _orderRepository.getAllDoneOrderByTimeAndDriverId(
            id, res["startDayOfWeekTimestamp"], res["lastDayOfWeekTimestamp"]);
    double unGetSign = 0.0;
    double unPayCash = 0.0;

    for (int i = 0; i < doneOrderList.length; i++) {
      if (doneOrderList[i]["status"] == 3) {
        if (!doneOrderList[i]["driverHandled"]) {
          if (doneOrderList[i]["payType"] == 1) {
            unGetSign += doneOrderList[i]["price"];
          } else {
            unPayCash += doneOrderList[i]["price"];
          }
        }
      }
    }
    _oneWeekData["amountpay"] =
        (unGetSign + unPayCash) * (storageBox.read("user")["sharing"] / 100) -
            unGetSign;
    print(oneWeekData["amountpay"]);
    getOnlineTimeInOneWeek();
    getMileageAndAchievementInWeek();
  }

  void getOnlineTimeInOneMonth() async => _oneMonthData["onlineTime"] =
      await _onlineRecordController.getOnlineTimeInOneMonth();

  void getOnlineTimeInOneWeek() async => _oneWeekData["onlineTime"] =
      await _onlineRecordController.getOnlineTimeInOneWeek();

  void getOnlineTimeInOneDay() async => _oneDayData["onlineTime"] =
      await _onlineRecordController.getOnlineTimeInOneDay();

  void getMileageAndAchievementInMonth() async {
    print("======== getMileageAndAchievementInMonth ========");
    String id = storageBox.read("user")["id"];
    Map<String, dynamic> time = Methods().getThisMonth();
    List res = await _orderRepository.getAllDoneOrderByTimeAndDriverId(
        id, time["startDayOfMonthTimestamp"], time["lastDayOfMonthTimestamp"]);

    if (res.isEmpty) {
      _oneMonthData["totalDistance"] = "暫無資料";
      _oneMonthData["performaceCount"] = "暫無資料";
    } else {
      double totalDistance = 0;
      double totalPrice = 0.0;
      for (int i = 0; i < res.length; i++) {
        totalPrice += res[i]["price"];
        totalDistance += res[i]["totalDistance"];
      }

      _oneMonthData["totalSharingPrice"] =
          totalPrice * ((100 - storageBox.read("user")["sharing"]) / 100);

      if (_oneMonthData["totalSharingPrice"] > 1000) {
        _oneMonthData["totalSharingPrice"] = NumberFormat("0,000").format(
            totalPrice * ((100 - storageBox.read("user")["sharing"]) / 100));
      } else {
        _oneMonthData["totalSharingPrice"] =
            (totalPrice * ((100 - storageBox.read("user")["sharing"]) / 100))
                .toStringAsFixed(2);
      }

      if (totalPrice > 1000) {
        _oneMonthData["totalPrice"] = NumberFormat("0,000").format(totalPrice);
      } else {
        _oneMonthData["totalPrice"] = totalPrice;
      }

      _oneMonthData["totalDistance"] = totalDistance;
      _oneMonthData["performaceCount"] = res.length;
    }
    print(res.length);
  }

  void getMileageAndAchievementInWeek() async {
    print("======== getMileageAndAchievementInWeek ========");
    String id = storageBox.read("user")["id"];
    Map<String, dynamic> time = Methods().getThisWeek();
    List res = await _orderRepository.getAllDoneOrderByTimeAndDriverId(
        id, time["startDayOfWeekTimestamp"], time["lastDayOfWeekTimestamp"]);
    if (res.isEmpty) {
      _oneWeekData["totalDistance"] = "暫無資料";
      _oneWeekData["performaceCount"] = "暫無資料";
    } else {
      double totalDistance = 0;
      double totalPrice = 0.0;
      for (int i = 0; i < res.length; i++) {
        totalPrice += res[i]["price"];
        totalDistance += res[i]["totalDistance"];
      }

      _oneWeekData["totalSharingPrice"] =
          totalPrice * ((100 - storageBox.read("user")["sharing"]) / 100);

      if (_oneWeekData["totalSharingPrice"] > 1000) {
        _oneWeekData["totalSharingPrice"] = NumberFormat("0,000").format(
            totalPrice * ((100 - storageBox.read("user")["sharing"]) / 100));
      } else {
        _oneWeekData["totalSharingPrice"] =
            (totalPrice * ((100 - storageBox.read("user")["sharing"]) / 100))
                .toStringAsFixed(2);
      }

      if (totalPrice > 1000) {
        _oneWeekData["totalPrice"] = NumberFormat("0,000").format(totalPrice);
      } else {
        _oneWeekData["totalPrice"] = totalPrice;
      }

      _oneWeekData["totalDistance"] = totalDistance;
      _oneWeekData["performaceCount"] = res.length;
    }
    print(res.length);
  }

  void getMileageAndAchievementInDay() async {
    print("======== getMileageAndAchievementInDay ========");
    String id = storageBox.read("user")["id"];
    Map<String, dynamic> time = Methods().getThisDay();
    List res = await _orderRepository.getAllDoneOrderByTimeAndDriverId(
        id, time["startDayOfDayTimestamp"], time["lastDayOfDayTimestamp"]);

    if (res.isEmpty) {
      _oneDayData["totalDistance"] = "暫無資料";
      _oneDayData["performaceCount"] = "暫無資料";
    } else {
      double totalDistance = 0;
      double totalPrice = 0.0;
      for (int i = 0; i < res.length; i++) {
        totalPrice += res[i]["price"];
        totalDistance += res[i]["totalDistance"];
      }

      _oneDayData["totalSharingPrice"] =
          totalPrice * ((100 - storageBox.read("user")["sharing"]) / 100);

      if (_oneDayData["totalSharingPrice"] > 1000) {
        _oneDayData["totalSharingPrice"] = NumberFormat("0,000").format(
            totalPrice * ((100 - storageBox.read("user")["sharing"]) / 100));
      } else {
        _oneDayData["totalSharingPrice"] =
            (totalPrice * ((100 - storageBox.read("user")["sharing"]) / 100))
                .toStringAsFixed(2);
      }

      if (totalPrice > 1000) {
        _oneDayData["totalPrice"] = NumberFormat("0,000").format(totalPrice);
      } else {
        _oneDayData["totalPrice"] = totalPrice;
      }

      _oneDayData["totalDistance"] = totalDistance;
      _oneDayData["performaceCount"] = res.length;
    }
    print(res.length);
  }

  @override
  void onClose() {
    debugPrint("業績Close");
    super.onClose();
  }
}
