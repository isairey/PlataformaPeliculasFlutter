import 'package:adblock_detecter/adblock_detecter.dart';

Future<bool> checkAdblockerStatus() async {
  return await AdBlockDetecter().detectAnyAdblocker;
}
