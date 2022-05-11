import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:taxi/screens/homepage/controller/homepage_controller.dart';

class BookingController extends GetxController {
  final RxList _bookingList = [].obs;
  List get bookingList => _bookingList;
  final RxList _notifyBookingList = [].obs;
  List get notifyBookingList => _notifyBookingList;

  Map<String, dynamic> notifyOrder = {};
  final HomepageController _homepageController = Get.find();
  final RxBool _loading = false.obs;
  bool get loading => _loading.value;

  final RxBool isNotifyOrder = false.obs;

  String _id = "";

  @override
  void onInit() {
    print("booking");
    GetStorage storageBox = GetStorage();
    _id = storageBox.read("user")["id"];
    getBookingListOrder();

    super.onInit();
  }

  void orderTimer() async {
    String currentTimeStr = DateTime.now().millisecondsSinceEpoch.toString();
    int currentTimeInt =
        int.parse(currentTimeStr.substring(0, currentTimeStr.length - 3));
    print(currentTimeInt);

    for (int i = 0; i < bookingList.length; i++) {
      if (currentTimeInt > bookingList[i]["orderDate"]) {
        remove(bookingList[i]["id"]);
        bookingList.removeWhere((item) => item["id"] == bookingList[i]["id"]);
      } else {
        _notifyBookingList.add(bookingList[i]);
        print(bookingList[i]["orderDate"]);
        print("==============orderDate");
        print(bookingList[i]["orderDate"] - currentTimeInt - 600);
        print("==============currentTimeInt");
        print(currentTimeInt - 600);
        if (bookingList[i]["orderDate"] - currentTimeInt - 600 < 0) {
          Timer(Duration(milliseconds: 0), () {
            print(notifyBookingList);
            notifyOrder = bookingList[i];
            // notifyBookingList.removeWhere(
            //     (item) => item["id"] == bookingList[i]["id"]);
            print("=================");
            isNotifyOrder.value = true;
          });
        } else {
          print(bookingList[i]["orderDate"] - currentTimeInt);
          Timer(Duration(seconds: bookingList[i]["orderDate"] - currentTimeInt),
              () {
            notifyOrder = bookingList[i];
            notifyBookingList
                .removeWhere((item) => item["id"] == bookingList[i]["id"]);
            isNotifyOrder.value = true;
          });
        }

        print("預約訂單計時");
      }
    }
  }

  void showNotifyOrder(BuildContext context, targetOrder) {
    showDialog(
        context: context,
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
                        // Align(
                        //     alignment: Alignment.centerRight,
                        //     child: GestureDetector(
                        //         onTap: () {
                        //           closeBookingOrder();
                        //         },
                        //         child: Icon(Icons.close))),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Text("推播訊息",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ))),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Text(targetOrder["date"],
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ))),
                            Text("\$ ${targetOrder["price"]}")
                          ],
                        ),
                        Text("${targetOrder["userName"]}"),
                        SizedBox(height: 10),
                        Text("上車:",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            )),
                        Text("${targetOrder["startLocation"]}",
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
                        Text("${targetOrder["endLocation"]}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            )),
                        SizedBox(height: 10),
                        Text("${targetOrder["description"]}",
                            style: TextStyle(
                              fontSize: 16,
                            )),
                        SizedBox(height: 10),
                        SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                                onPressed: () async {
                                  // setBookingOrder(bookingOrder["id"]);
                                  // // _receivingOrder.value = true;
                                  isNotifyOrder.value = false;
                                  Get.back();
                                },
                                style: ButtonStyle(
                                    fixedSize: (MaterialStateProperty.all(
                                        Size(double.infinity, 80))),
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.yellow[800])),
                                child: Text("確定",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 18))))
                      ])));
        }).then((exit) {
      if (exit == null) {
        isNotifyOrder.value = false;
        // Get.back();
      }
    });
  }

  void setBookingOrder(orderID) async {
    await _homepageController.setNowOrder(orderID);
    _homepageController.setNowOrderStatus(orderID);
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("driver/$_id/order/now");
    ref.update({"id": orderID});

    remove(orderID);

    _bookingList.removeWhere((item) => item["id"] == orderID);
    Get.back();
  }

  void remove(orderID) async {
    print("removeBooking");
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("driver/$_id/order/booking/$orderID");
    await ref.remove();
  }

  Future<void> getBookingListOrder() async {
    print("=======getBookingListOrder===========");
    _bookingList.value = [];
    _loading.value = true;
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("driver/$_id/order/booking");
    print(ref.path);

    DatabaseEvent event = await ref.once();
    final data = jsonEncode(event.snapshot.value);
    final res = jsonDecode(data);

    print("================booking===============");

    print(res);
    // print(res.toList());

    if (res != null) {
      List resList = [];
      res.forEach((k, v) => resList.add(k));

      List tmpBookingList = [];
      for (int i = 0; i < resList.length; i++) {
        DateTime tmpTime;

        final res = await _homepageController.getOrderByID(resList[i]);
        print(res);

        if (res["message"] == "Unfound Order") {
          remove(resList[i]);
        } else {
          tmpBookingList.add(res["data"]);
          tmpTime = DateTime.fromMillisecondsSinceEpoch(
              tmpBookingList[i]["orderDate"] * 1000);

          tmpBookingList[i]["date"] =
              DateFormat('yyyy/MM/dd kk:mm').format(tmpTime);
        }
      }

      tmpBookingList.sort((a, b) => a["orderDate"].compareTo(b["orderDate"]));
      _bookingList.value = tmpBookingList;
      orderTimer();
      print("sort");
      print(bookingList);

      // print(bookingList);
    }

    _loading.value = false;
  }
}
