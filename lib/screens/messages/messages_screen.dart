import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taxi/screens/messages/controller/messages_controller.dart';
import 'package:taxi/screens/performance/controller/dispatch_record_controller.dart';

class MessagesScreen extends GetView<MessagesController> {
  MessagesScreen({Key? key}) : super(key: key);

  final DispatchRecordController _dispatchRecordController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 10),
        TabBar(
          unselectedLabelColor: Colors.black,
          labelColor: Colors.blue,
          controller: controller.messageTabbar,
          tabs: const [
            Text(
              "派遣訊息",
              style: TextStyle(fontSize: 18),
            ),
            Text("公司訊息", style: TextStyle(fontSize: 18))
          ],
        ),
        Expanded(
            child: TabBarView(controller: controller.messageTabbar, children: [
          Obx(() => !_dispatchRecordController.loading
              ? Obx(() => ListView.separated(
                  itemBuilder: (_, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                          top: 5, bottom: 5, left: 10, right: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                _dispatchRecordController.recordList[index]
                                                ["status"] !=
                                            2 &&
                                        _dispatchRecordController
                                                .recordList[index]["status"] !=
                                            1
                                    ? Text(
                                        "\$${_dispatchRecordController.recordList[index]["price"].toString()}",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      )
                                    : SizedBox(),
                                _dispatchRecordController.recordList[index]
                                                ["status"] ==
                                            2 ||
                                        _dispatchRecordController
                                                .recordList[index]["status"] ==
                                            1
                                    ? Text("進行中",
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600))
                                    : SizedBox()
                              ]),
                              Text(
                                  _dispatchRecordController.recordList[index]
                                      ["date"],
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600))
                            ],
                          ),
                          SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _dispatchRecordController.recordList[index]
                                    ["userName"],
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              _dispatchRecordController.recordList[index]
                                              ["status"] ==
                                          2 ||
                                      _dispatchRecordController
                                              .recordList[index]["status"] ==
                                          1
                                  ? SizedBox()
                                  : _dispatchRecordController.recordList[index]
                                              ["payType"] ==
                                          1
                                      ? Text("電子簽帳",
                                          style: TextStyle(fontSize: 18))
                                      : Text("現金",
                                          style: TextStyle(fontSize: 18))
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(
                            "上車",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 6),
                          Text(
                            _dispatchRecordController.recordList[index]
                                ["startLocation"],
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "目的地",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 6),
                          Text(
                            _dispatchRecordController.recordList[index]
                                ["endLocation"],
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 6),
                          _dispatchRecordController.recordList[index]
                                          ["status"] !=
                                      2 &&
                                  _dispatchRecordController.recordList[index]
                                          ["status"] !=
                                      1
                              ? Text(
                                  "${_dispatchRecordController.recordList[index]["totalDistance"].toStringAsFixed(1)}里程數",
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                )
                              : SizedBox(),
                          SizedBox(height: 6),
                          Text(
                            _dispatchRecordController.recordList[index]
                                ["description"],
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (_, __) {
                    return Divider();
                  },
                  itemCount: _dispatchRecordController.recordList.length))
              : Center(child: CircularProgressIndicator())),
          Obx(
            () => !controller.loading
                ? ListView.separated(
                    itemBuilder: (_, index) {
                      return Padding(
                        padding: EdgeInsets.only(
                            top: 5, bottom: 5, left: 10, right: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              controller.companyMessage[index]["title"],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text(controller.companyMessage[index]["content"]),
                            SizedBox(height: 10),
                            Text(controller.companyMessage[index]["date"]
                                .toString()),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (_, __) {
                      return Divider();
                    },
                    itemCount: controller.companyMessage.length)
                : Center(child: CircularProgressIndicator()),
          )
        ]))
      ],
    );
  }
}
