import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class PermissionService {
  Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.status;

    if (status.isGranted) return true;

    status = await Permission.storage.request();

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return status.isGranted;
  }

  Future<bool> requestAudioPermission() async {
    var status = await Permission.audio.status;

    if (status.isGranted) return true;

    status = await Permission.audio.request();

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return status.isGranted;
  }

  Future<bool> requestNeededPermissions() async {
    final storageGranted = await requestStoragePermission();
    final audioGranted = await requestAudioPermission();
if (!Platform.isAndroid) return true;

    // Android 13+
    if (await Permission.audio.request().isGranted) {
      return true;
    }

    // Android <= 12
    if (await Permission.storage.request().isGranted) {
      return true;
    }
    return storageGranted || audioGranted;
  }

  Future<bool> hasPermissions() async {
    final storagePermission = await Permission.storage.isGranted;
    final audioPermission = await Permission.audio.isGranted;
 if (Platform.isAndroid) {
      if (await Permission.audio.isGranted) return true;
      if (await Permission.storage.isGranted) return true;
    }
    return storagePermission || audioPermission;
  }
}