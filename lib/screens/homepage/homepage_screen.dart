import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi/controller/location_controller.dart';
import 'package:taxi/repositories/online_record_repository.dart';

import 'package:taxi/screens/homepage/controller/booking_controller.dart';
import 'package:taxi/controller/online_record_controller.dart';
import 'package:taxi/screens/homepage/electronic_signature_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'controller/homepage_controller.dart';
import 'finish_order_screen.dart';

class HomepageScreen extends GetView<HomepageController> {
  HomepageScreen({Key? key}) : super(key: key);

  final LocationController _locationController = Get.find();

  final BookingController _bookingController = Get.find();
  final OnlineRecordController _onlineRecordController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() => _locationController.currentLocation.latitude == 0
        ? Center(child: CircularProgressIndicator())
        : Obx(() => Column(children: [
              // SelectableText(controller.token),
              Expanded(
                  child: GoogleMap(
                initialCameraPosition: CameraPosition(
                    target: _locationController.currentLocation, zoom: 15.0),
                onMapCreated: _locationController.onMapCreated,
                onCameraMove: _locationController.onCameraMove,
                zoomGesturesEnabled: true,
                markers: Set<Marker>.of(_locationController.markers.values),
                polylines:
                    Set<Polyline>.of(_locationController.polylines.values),
              )),
              controller.receivingOrder ? haveOrder() : noOrder(),
            ])));
  }

  Padding noOrder() {
    return Padding(
        padding: EdgeInsets.fromLTRB(15, 10, 15, 5),
        child: Column(children: [
          controller.isLoadingDriverStatus
              ? Container(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: null,
                      style: ButtonStyle(
                          fixedSize: (MaterialStateProperty.all(Size(100, 80))),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.yellow[800])),
                      child: Center(
                        child: CircularProgressIndicator(),
                      )))
              : controller.status == 0
                  ? Container(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed:
                              _locationController.currentLocation.latitude == 0
                                  ? null
                                  : () async {
                                      await controller.setDriverStatus(1);
                                      _onlineRecordController
                                          .setStartOnlineTime();
                                      controller.listenOrder();

                                      _bookingController.getBookingListOrder();
                                      // controller.setTimer();
                                    },
                          style: ButtonStyle(
                              fixedSize:
                                  (MaterialStateProperty.all(Size(100, 80))),
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.yellow[800])),
                          child: _locationController.currentLocation.latitude == 0
                              ? CircularProgressIndicator()
                              : Text("??????",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 18))))
                  : Container(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () async {
                            // _createOnlineRecord.createOnlineRecord(controller.id, startTime, endTime)
                            await _onlineRecordController.setEndOnlineTime();
                            _onlineRecordController.createOnlineRecord();
                            controller.setDriverStatus(0);
                          },
                          style: ButtonStyle(
                              fixedSize:
                                  (MaterialStateProperty.all(Size(100, 80))),
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.yellow[800])),
                          child: Text("??????",
                              style: TextStyle(color: Colors.black, fontSize: 18)))),
        ]));
  }

  Padding haveOrder() {
    return Padding(
        padding: EdgeInsets.fromLTRB(15, 10, 15, 5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // TextButton(
          //     onPressed: () => Get.toNamed(ElectronicSignatureScreen.routeName),
          //     child: Text("Add Data")),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text("????????????:${controller.nowOrder["startLocation"]}",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              TextButton(
                  onPressed: () => {
                        launch(
                            'http://maps.google.com/maps?saddr=${_locationController.currentLocation.latitude.toString()},${_locationController.currentLocation.longitude.toString()}&daddr=${controller.nowOrder["startLat"]},${controller.nowOrder["startLnt"]}&mode=driving')
                      },
                  child: Text('??????'))
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text("????????????:${controller.nowOrder["endLocation"]}",
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w600))),
              Obx(() => Text("\$ ${controller.totalPrice}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Text(
                  "????????????: ${_locationController.calculatePolylineDistane(_locationController.billingCoordinates).toStringAsFixed(1)} km",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)))
            ],
          ),
          SizedBox(height: 10),
          Text("${controller.nowOrder["description"]}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              controller.nowOrder["endLocation"] != ""
                  ? Text(" ${_locationController.durationTime} ??????",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
                  : Text(""),
              Text(_locationController.distance,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                    ElevatedButton(
                        onPressed: () {
                          controller
                              .makePhoneCall(controller.nowOrder["phone"]);
                        },
                        style: ButtonStyle(
                            fixedSize:
                                (MaterialStateProperty.all(Size(150, 50))),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.yellow[800])),
                        child: Text("??????",
                            style:
                                TextStyle(color: Colors.black, fontSize: 18))),
                    SizedBox(height: 10),
                    controller.status == 2
                        ? ElevatedButton(
                            onPressed: () async {
                              if (!controller.isLoadingStartOrder.value) {
                                controller.isLoadingStartOrder.value = true;
                                await controller.fixedPointBilling();

                                Get.snackbar(
                                  "????????????",
                                  "??????????????????",
                                  backgroundColor: Colors.yellow[600],
                                );

                                controller.isLoadingStartOrder.value = false;
                              }
                            },
                            style: ButtonStyle(
                                fixedSize:
                                    (MaterialStateProperty.all(Size(150, 50))),
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.yellow[800])),
                            child: controller.isLoadingStartOrder.value
                                ? CircularProgressIndicator()
                                : Text("????????????",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 18)))
                        : SizedBox()
                  ])),
              ElevatedButton(
                  onPressed: () async {
                    if (controller.isLoadingStartOrder.value) {
                      return null;
                    } else if (controller.status != 2) {
                      _locationController.resetPolyline();
                      controller.isLoadingStartOrder.value = true;
                      await controller.startBilling();

                      await controller.calPrice();
                      Future.delayed(Duration(seconds: 2), () {
                        controller.isLoadingStartOrder.value = false;
                      });

                      // controller.calPriceTimer5s();

                    } else {
                      controller.isLoadingStartOrder.value = true;
                      await controller.fixedPointBilling();
                      controller.stopHalfway();
                      await controller.calPrice();

                      Future<void> future = Get.bottomSheet(
                        Container(
                            padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
                            color: Colors.white,
                            height: 350,
                            child: Column(
                              children: [
                                Text("??????",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600)),
                                SizedBox(height: 6),
                                Text("????????????: \$ ${controller.startPrice}",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600)),
                                SizedBox(height: 6),
                                Text(
                                    "???????????????:  ${controller.totalDistance.toStringAsFixed(1)} ??????",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600)),
                                SizedBox(height: 6),
                                Text("??????: \$ ${controller.totalPrice}",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600)),
                                SizedBox(height: 10),
                                Text("????????????",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                                SizedBox(height: 10),
                                SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                        onPressed: () {
                                          if (!controller
                                              .isLoadingFinishOrder) {
                                            controller.finishOrder(2);
                                          }
                                        },
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.yellow[800])),
                                        child: Text("??????",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18)))),
                                SizedBox(height: 10),
                                SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                        onPressed: () {
                                          Get.offNamed(ElectronicSignatureScreen
                                              .routeName);
                                        },
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.yellow[800])),
                                        child: Text("????????????",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18)))),
                              ],
                            )),
                        enableDrag: false,
                      );

                      future.then((void value) =>
                          Future.delayed(Duration(seconds: 2), () {
                            controller.isLoadingStartOrder.value = false;
                          }));

                      // controller.setDriverStatus(1);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      shape: CircleBorder(), primary: Colors.yellow[800]),
                  child: Container(
                      width: 120,
                      height: 120,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: controller.isLoadingStartOrder.value
                          ? CircularProgressIndicator()
                          : controller.status == 2
                              ? Text(
                                  '????????????',
                                  style: TextStyle(fontSize: 24),
                                )
                              : Text(
                                  '????????????',
                                  style: TextStyle(fontSize: 24),
                                )))
            ],
          ),
        ]));
  }
}
