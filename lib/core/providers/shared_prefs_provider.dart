import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibi/core/di/service_locator.dart';

SharedPreferences get sharedPrefs => getIt<SharedPreferences>();
