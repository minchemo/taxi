import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller/dispatch_record_controller.dart';

class DispatchRecordScreen extends GetView<DispatchRecordController> {
  const DispatchRecordScreen({Key? key}) : super(key: key);
  static String routeName = "/dispatchRecordScreen";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          backgroundColor: Colors.yellow[600],
          title: Text(
            "派遣記錄",
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () => {
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
                          height: 300,
                          padding: EdgeInsets.only(
                              left: 10, top: 10, right: 10, bottom: 10),
                          margin: EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black,
                                    offset: Offset(0, 10),
                                    blurRadius: 10),
                              ]),
                          child: Column(
                            children: <Widget>[
                              TabBar(
                                  labelColor: Colors.blue,
                                  unselectedLabelColor: Colors.black,
                                  controller: controller.dateController,
                                  tabs: [
                                    Text(
                                      "當月",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    Text(
                                      "上月",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    Text(
                                      "區間",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ]),
                              Expanded(
                                  child: TabBarView(
                                      controller: controller.dateController,
                                      children: [
                                    Center(
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                          Text(controller.currentMonthDate,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w500)),
                                          SizedBox(height: 20),
                                          ElevatedButton(
                                              onPressed: () {
                                                controller.getThisMonthData();
                                                Get.back();
                                              },
                                              style: ButtonStyle(
                                                  fixedSize:
                                                      (MaterialStateProperty
                                                          .all(Size(100, 50))),
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          Colors.yellow[800])),
                                              child: Text("確定",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18))),
                                        ])),
                                    Center(
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                          Text(controller.beforeMonthDate,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w500)),
                                          SizedBox(height: 20),
                                          ElevatedButton(
                                              onPressed: () {
                                                controller.getBeforeMonthData();
                                                Get.back();
                                              },
                                              style: ButtonStyle(
                                                  fixedSize:
                                                      (MaterialStateProperty
                                                          .all(Size(100, 50))),
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          Colors.yellow[800])),
                                              child: Text("確定",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18))),
                                        ])),
                                    Center(
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                          GestureDetector(
                                              onTap: () => controller
                                                  .selectDate(context),
                                              child: controller.filterDate == ""
                                                  ? Text("請選擇日期",
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.w500))
                                                  : Text(controller.filterDate,
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight
                                                              .w500))),
                                          SizedBox(height: 20),
                                          Text("一個月內的訂單",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.red))

                                          // ElevatedButton(
                                          //     onPressed: () {
                                          //       controller.getBeforeMonthData();
                                          //       Get.back();
                                          //     },
                                          //     style: ButtonStyle(
                                          //         fixedSize:
                                          //             (MaterialStateProperty
                                          //                 .all(Size(100, 50))),
                                          //         backgroundColor:
                                          //             MaterialStateProperty.all(
                                          //                 Colors.yellow[800])),
                                          //     child: Text("確定",
                                          //         style: TextStyle(
                                          //             color: Colors.black,
                                          //             fontSize: 18))),
                                        ])),
                                  ]))
                            ],
                          ),
                        ),
                      );
                    })
              },
              child: Text(
                "搜尋",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            )
          ],
        ),
        body: Obx(
          () => !controller.loading
              ? ListView.separated(
                  itemBuilder: (_, int index) {
                    return DataList(
                      index: index,
                    );
                  },
                  itemCount: controller.recordList.length,
                  separatorBuilder: (_, __) {
                    return Divider();
                  },
                )
              : Center(child: CircularProgressIndicator()),
        ));
  }
}

class DataList extends GetView<DispatchRecordController> {
  DataList({Key? key, required this.index}) : super(key: key);
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "\$${controller.recordList[index]["price"].toString()}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Text(controller.recordList[index]["date"],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))
              ],
            ),
            SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.recordList[index]["userName"],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                controller.recordList[index]["payType"] == 1
                    ? Text("電子簽帳", style: TextStyle(fontSize: 18))
                    : Text("現金", style: TextStyle(fontSize: 18))
              ],
            ),
            SizedBox(height: 6),
            Text(
              "上車",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            Text(
              controller.recordList[index]["startLocation"],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            Text(
              "目的地",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            Text(
              controller.recordList[index]["endLocation"],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            Text(
              "${controller.recordList[index]["totalDistance"].toStringAsFixed(1)}里程數",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(height: 6),
            Text(
              controller.recordList[index]["description"],
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ));
  }
}
