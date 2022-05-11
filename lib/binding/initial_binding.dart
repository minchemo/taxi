import 'package:get/instance_manager.dart';
import 'package:taxi/controller/location_controller.dart';
import 'package:taxi/screens/homepage/controller/booking_controller.dart';
import 'package:taxi/screens/homepage/controller/homepage_controller.dart';
import 'package:taxi/controller/online_record_controller.dart';
import 'package:taxi/screens/messages/controller/messages_controller.dart';
import 'package:taxi/screens/performance/controller/dispatch_record_controller.dart';
import 'package:taxi/screens/performance/controller/performance_controller.dart';
import 'package:taxi/screens/setting/controller/setting_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    //  Get.lazyPut<BookingController>((() => BookingController()));
    Get.lazyPut<LocationController>(() => LocationController());
    Get.lazyPut<BookingController>(() => BookingController());
    Get.lazyPut<HomepageController>((() => HomepageController()));
    Get.lazyPut<OnlineRecordController>((() => OnlineRecordController()));
    Get.lazyPut<PerformanceController>((() => PerformanceController()));
    Get.lazyPut<MessagesController>((() => MessagesController()));
    Get.lazyPut<SettingController>((() => SettingController()));
    Get.lazyPut<DispatchRecordController>((() => DispatchRecordController()));
    
    
    //  Get.put<LocationController>(LocationController());
    //  Get.put<BookingController>(BookingController());
  }
}
