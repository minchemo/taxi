import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:taxi/methods/methods.dart';
import 'package:taxi/repositories/order_repository.dart';

class DispatchRecordController extends GetxController
    with SingleGetTickerProviderMixin {
  late TabController dateTabController;

  late TabController dateController;

  final RxString _beforeMonthDate = "".obs;
  String get beforeMonthDate => _beforeMonthDate.value;

  final RxString _currentMonthDate = "".obs;
  String get currentMonthDate => _currentMonthDate.value;

  final RxString _lastMonthDate = "".obs;
  String get lastMonthDate => _lastMonthDate.value;

  final RxString _filterDate = "".obs;
  String get filterDate => _filterDate.value;

  var dio = Dio();

  final RxBool _loading = false.obs;
  bool get loading => _loading.value;

  final RxList _recordList = [].obs;
  List get recordList => _recordList;

  final OrderRepository _orderRepository = OrderRepository();
  final GetStorage storageBox = GetStorage();

  @override
  void onInit() async {
    debugPrint("DispatchRecordController");
    getCurrentTime();
    dateTabController = TabController(length: 3, vsync: this);
    dateController = TabController(length: 3, vsync: this);

    // _recordList.value = await getRecord();
    print("recordList");
    // print(recordList[0]["userName"]);
    super.onInit();
  }

  void getRecord() async {
    _loading.value = true;
    print("getRecord");
    GetStorage storageBox = GetStorage();
    String _id = storageBox.read("user")["id"];
    String? apiUrl =
        dotenv.env['APP_SERVER_URL'].toString() + '/getAllOrderByDriverId';
    print(apiUrl);

    final json = {"driverId": _id, "creationTime": 0};
    print(json);
    final res = await dio.post(apiUrl, data: json).catchError((error) {
      _loading.value = false;
      print(error);
    });

    for (int i = 0; i < res.data["data"].length; i++) {
      res.data["data"][i]["date"] = DateFormat('yyyy/MM/dd kk:mm').format(
          DateTime.fromMillisecondsSinceEpoch(
              res.data["data"][i]["creationTime"] * 1000));
    }

    print(res.data["data"]);
    _loading.value = false;

    _recordList.value = res.data["data"];
  }

  void getThisMonthData() async {
    print("======== getThisMonthData ======= ");
    _loading.value = true;

    Map<String, dynamic> time = Methods().getThisMonth();

    String id = storageBox.read("user")["id"];

    List res = await _orderRepository.getAllDoneOrderByTimeAndDriverId(
        id, time["startDayOfMonthTimestamp"], time["lastDayOfMonthTimestamp"]);

    for (int i = 0; i < res.length; i++) {
      res[i]["date"] = DateFormat('yyyy/MM/dd kk:mm').format(
          DateTime.fromMillisecondsSinceEpoch(res[i]["creationTime"] * 1000));
    }

    print(res);

    _recordList.value = res;

    _loading.value = false;
  }

  void getBeforeMonthData() async {
    print("======== getBeforeMonthData ======= ");
    _loading.value = true;

    Map<String, dynamic> time = Methods().getBeforeMonth();

    String id = storageBox.read("user")["id"];

    List res = await _orderRepository.getAllDoneOrderByTimeAndDriverId(
        id, time["startDayOfMonthTimestamp"], time["lastDayOfMonthTimestamp"]);

    for (int i = 0; i < res.length; i++) {
      res[i]["date"] = DateFormat('yyyy/MM/dd kk:mm').format(
          DateTime.fromMillisecondsSinceEpoch(res[i]["creationTime"] * 1000));
    }

    print(res);

    _recordList.value = res;

    _loading.value = false;
  }

  void getMonthData(
      int startDayOfMonthTimestamp, int lastDayOfMonthTimestamp) async {
    print("======== getMonthData ======= ");
    _loading.value = true;

    String id = storageBox.read("user")["id"];

    List res = await _orderRepository.getAllDoneOrderByTimeAndDriverId(
        id, startDayOfMonthTimestamp, lastDayOfMonthTimestamp);

    for (int i = 0; i < res.length; i++) {
      res[i]["date"] = DateFormat('yyyy/MM/dd kk:mm').format(
          DateTime.fromMillisecondsSinceEpoch(res[i]["creationTime"] * 1000));
    }

    print(res);

    _recordList.value = res;

    _loading.value = false;
  }

  void selectDate(BuildContext context) async {
    DatePicker.showDatePicker(context,
        showTitleActions: true,
        minTime: DateTime(2021, 1),
        maxTime: DateTime.now(),
        theme: DatePickerTheme(
            headerColor: Colors.white,
            backgroundColor: Colors.white,
            itemStyle: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
            doneStyle: TextStyle(color: Colors.black, fontSize: 16)),
        onConfirm: (date) {
      _filterDate.value = DateFormat('yyyy-MM-dd').format(date);
      DateTime dateTime = DateTime.parse(filterDate);
      Timestamp timestamp = Timestamp.fromDate(dateTime);
      // print(DateTime.parse(myTimeStamp.toDate().toString()));
      int startTimestamp = timestamp.seconds;
      getMonthData(startTimestamp, startTimestamp + 2629743);
      Get.back();
    }, currentTime: DateTime.now(), locale: LocaleType.zh);
  }

  void getCurrentTime() {
    var date = DateTime.now().toString();
    DateTime currentDate = DateTime.parse(date);

    DateTime lastDayOfMonth;
    if (currentDate.month + 1 == 13) {
      lastDayOfMonth = DateTime(currentDate.year + 1, 1, 0);
    } else {
      lastDayOfMonth = DateTime(currentDate.year, currentDate.month + 1, 0);
    }

    if (currentDate.month - 1 != 0) {
      _beforeMonthDate.value = currentDate.year.toString() +
          "/" +
          (currentDate.month - 1).toString() +
          "/1";
      _currentMonthDate.value = currentDate.year.toString() +
          "/" +
          currentDate.month.toString() +
          "/1";
    } else {
      _beforeMonthDate.value =
          (currentDate.year - 1).toString() + "/" + "12" + "/1";
      _currentMonthDate.value = currentDate.year.toString() +
          "/" +
          currentDate.month.toString() +
          "/1";
    }

    _lastMonthDate.value = currentDate.year.toString() +
        "/" +
        currentDate.month.toString() +
        "/" +
        lastDayOfMonth.day.toString();
  }

  @override
  void onClose() {
    debugPrint("業績Close");
    super.onClose();
  }
}
