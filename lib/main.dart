import 'package:flutter/material.dart';
import 'core/db/database.dart';
import 'core/notifications/notification_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.db;
  await NotificationService.instance.initialize();
  runApp(const TrackerApp());
}