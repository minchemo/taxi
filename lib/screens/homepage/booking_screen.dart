import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:taxi/screens/homepage/controller/booking_controller.dart';

class BookingScreen extends GetView<BookingController> {
  const BookingScreen({Key? key}) : super(key: key);
  static String routeName = "/bookingScreen";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
            backgroundColor: Colors.yellow[600],
            title: Text("預約列表", style: TextStyle(color: Colors.black))),
        body: Obx(() => !controller.loading
            ? Padding(
                padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                child: ListView.separated(
                    itemBuilder: (_, index) {
                      return InkWell(
                          onTap: () {
                            GetStorage storageBox = GetStorage();
                            if (storageBox.read("executingOrder") == null) {
                              controller.setBookingOrder(
                                  controller.bookingList[index]["id"]);
                            } else {
                              Get.snackbar(
                                "訂單執行中",
                                "你正在執行訂單中，無法接取，請完成目前訂單。",
                                backgroundColor: Colors.yellow[600],
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${controller.bookingList[index]["date"]}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  )),
                              Text(
                                  "\$ ${controller.bookingList[index]["price"]}",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  )),
                              Text(
                                  "上車  ${controller.bookingList[index]["startLocation"]}",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  )),
                              Text(
                                  "目的地  ${controller.bookingList[index]["endLocation"]}",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  )),
                              Text("${controller.bookingList[index]["phone"]}",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ],
                          ));
                    },
                    separatorBuilder: (_, __) {
                      return Divider();
                    },
                    itemCount: controller.bookingList.length))
            : Center(child: CircularProgressIndicator())));
  }
}
