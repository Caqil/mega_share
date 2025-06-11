import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:injectable/injectable.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Connectivity get connectivity => Connectivity();

  @lazySingleton
  InternetConnectionChecker get internetConnectionChecker =>
      InternetConnectionChecker.createInstance(
        checkTimeout: const Duration(seconds: 3),
        checkInterval: const Duration(seconds: 3),
      );
}
