import 'package:get/get.dart';
import 'package:video_call_app/Views/AuthScreen/sign_in_screen.dart';
import 'package:video_call_app/Views/OnbordingScreen/onbording_screen.dart';
import 'package:video_call_app/Views/home_screen.dart';

class AppRoutes {
  static const String homeScreenRoute = '/home';
  static const String onBordingRoute = '/onbording';
  static const String userselectionRoute = '/userselection';


  static List<GetPage> routes = [
    GetPage(
      name: homeScreenRoute,
      page: () {
        final userId = Get.arguments as String;
        final otherUser = Get.arguments as String;
        return HomeScreen(userId: userId,otherUser:otherUser);
      },
    ),
    
    GetPage(
        name: onBordingRoute,
        page: () => OnboardingScreen()
    ),

    GetPage(
        name: userselectionRoute,
        page: () => UserSelectionView(),
    )
  ];
}
