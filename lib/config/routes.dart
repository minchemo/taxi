import 'package:get/get.dart';
import 'package:taxi/screens/home/binding/home_binding.dart';
import 'package:taxi/screens/home/home_screen.dart';
import 'package:taxi/screens/homepage/binding/homepage_binding.dart';
import 'package:taxi/screens/homepage/booking_screen.dart';
import 'package:taxi/screens/homepage/electronic_signature_screen.dart';
import 'package:taxi/screens/homepage/finish_order_screen.dart';
import 'package:taxi/screens/performance/binding/performance_binding.dart';
import 'package:taxi/screens/performance/dispatch_record_screen.dart';
import 'package:taxi/screens/setting/binding/profile_binding.dart';
import 'package:taxi/screens/setting/profile_screen.dart';
import 'package:taxi/screens/signup/binding/signup_binding.dart';
import 'package:taxi/screens/signup/signup_screen.dart';

class Routes {
  Routes._();
  static final routes = [
    GetPage(
      name: SignupScreen.routeName,
      page: () => SignupScreen(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: ElectronicSignatureScreen.routeName,
      page: () => ElectronicSignatureScreen(),
      binding: HomepageBinding(),
    ),
    GetPage(
      name: FinishOrderScreen.routeName,
      page: () => FinishOrderScreen(),
      binding: HomepageBinding(),
    ),
    GetPage(
      name: BookingScreen.routeName,
      page: () => BookingScreen(),
      binding: HomepageBinding(),
    ),
    GetPage(
      name: HomeScreen.routeName,
      page: () => HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: DispatchRecordScreen.routeName,
      page: () => DispatchRecordScreen(),
      binding: PerformanceBinding(),
    ),
    GetPage(
      name: ProfileScreen.routeName,
      page: () => ProfileScreen(),
      binding: ProfileBinding(),
    ),
  ];
}
