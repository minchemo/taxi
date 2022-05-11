import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:taxi/screens/performance/controller/dispatch_record_controller.dart';
import 'package:taxi/screens/performance/widgets/statistical_data.dart';
import 'controller/performance_controller.dart';
import 'dispatch_record_screen.dart';

class PerformanceScreen extends GetView<PerformanceController> {
  PerformanceScreen({Key? key}) : super(key: key);
  final DispatchRecordController _dispatchRecordController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 30),
        Align(
            alignment: Alignment.center,
            child: Container(
              height: 240,
              width: 240,
              decoration: BoxDecoration(
                  color: Colors.yellow[600],
                  borderRadius: BorderRadius.all(Radius.circular(1000))),
              child: Obx(() => Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Text(
                          "我的收益",
                          style: TextStyle(
                              fontSize: 26, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 20),
                        controller.currentTabBarIndex == 0 &&
                                controller.oneMonthData["totalSharingPrice"] !=
                                    null
                            ? Text(
                                controller.oneMonthData["totalSharingPrice"]
                                    .toString(),
                                style: TextStyle(
                                    fontSize: 26, fontWeight: FontWeight.w600),
                              )
                            : controller.currentTabBarIndex == 1 &&
                                    controller
                                            .oneWeekData["totalSharingPrice"] !=
                                        null
                                ? Text(
                                    controller.oneWeekData["totalSharingPrice"]
                                        .toString(),
                                    style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w600),
                                  )
                                : controller.currentTabBarIndex == 2 &&
                                        controller.oneDayData[
                                                "totalSharingPrice"] !=
                                            null
                                    ? Text(
                                        controller
                                            .oneDayData["totalSharingPrice"]
                                            .toString(),
                                        style: TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w600),
                                      )
                                    : Text(
                                        "0",
                                        style: TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w600),
                                      ),
                        SizedBox(height: 20),
                        controller.currentTabBarIndex == 0 &&
                                controller.oneMonthData["totalPrice"] != null
                            ? Text(
                                "總訂單金額${controller.oneMonthData["totalPrice"]}",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              )
                            : controller.currentTabBarIndex == 1 &&
                                    controller.oneWeekData["totalPrice"] != null
                                ? Text(
                                    "總訂單金額${controller.oneWeekData["totalPrice"]}",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  )
                                : controller.currentTabBarIndex == 2 &&
                                        controller.oneDayData["totalPrice"] !=
                                            null
                                    ? Text(
                                        "總訂單金額${controller.oneDayData["totalPrice"]}",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      )
                                    : Text(
                                        "總訂單金額 0",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                        controller.currentTabBarIndex == 0 &&
                                controller.oneMonthData["amountpay"] != null
                            ? Text(
                                "上繳金額 " +
                                    controller.oneMonthData["amountpay"]
                                        .toString(),
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              )
                            : controller.currentTabBarIndex == 1 &&
                                    controller.oneWeekData["amountpay"] != null
                                ? Text(
                                    "上繳金額 " +
                                        controller.oneWeekData["amountpay"]
                                            .toString(),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500))
                                : controller.currentTabBarIndex == 2 &&
                                        controller.oneDayData["amountpay"] !=
                                            null
                                    ? Text(
                                        "上繳金額 " +
                                            controller.oneDayData["amountpay"]
                                                .toString(),
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500))
                                    : Text("0"),
                      ]))),
            )),
        TabBar(
            unselectedLabelColor: Colors.black,
            labelColor: Colors.blueAccent,
            padding: EdgeInsets.all(10),
            controller: controller.dateTabController,
            tabs: [
              Text(
                "月",
                style: TextStyle(fontSize: 16),
              ),
              Text("週", style: TextStyle(fontSize: 16)),
              Text("日", style: TextStyle(fontSize: 16)),
            ]),
        Obx(() => Expanded(
                child: TabBarView(
                    controller: controller.dateTabController,
                    children: [
                  controller.oneMonthData["onlineTime"] != null &&
                          controller.oneMonthData["totalDistance"] != null &&
                          controller.oneMonthData["performaceCount"] != null
                      ? StatisticalData(
                          countTitle: "月",
                          curretDate: controller.oneMonthData["startDate"],
                          lastDate: controller.oneMonthData["lastDate"],
                          data: controller.oneMonthData)
                      : Center(child: CircularProgressIndicator()),
                  controller.oneWeekData["onlineTime"] != null &&
                          controller.oneWeekData["totalDistance"] != null &&
                          controller.oneWeekData["performaceCount"] != null
                      ? StatisticalData(
                          countTitle: "週",
                          curretDate: controller.oneWeekData["startDate"],
                          lastDate: controller.oneWeekData["lastDate"],
                          data: controller.oneWeekData)
                      : Center(child: CircularProgressIndicator()),
                  controller.oneDayData["onlineTime"] != null &&
                          controller.oneDayData["totalDistance"] != null &&
                          controller.oneDayData["performaceCount"] != null
                      ? StatisticalData(
                          countTitle: "日",
                          curretDate: controller.oneDayData["startDate"],
                          lastDate: controller.oneDayData["lastDate"],
                          data: controller.oneDayData)
                      : Center(child: CircularProgressIndicator()),
                ]))),
        Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.yellow[700])),
              onPressed: () {
                _dispatchRecordController.getRecord();
                Get.toNamed(DispatchRecordScreen.routeName);
              },
              child: Text("派遣記錄", style: TextStyle(color: Colors.black)),
            )),
      ],
    );
  }
}
