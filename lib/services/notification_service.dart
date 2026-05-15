import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Notificări de retenție: 3 reminder-uri/zi la ~5-6h distanță,
/// în intervale prietenoase (dimineața / după-amiaza / seara la culcare).
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // Ore-țintă (≈5-6h între ele); seara = momentul perfect pentru povești.
  static const List<int> _hours = [9, 15, 20];
  static const List<int> _minutes = [30, 0, 30];

  static const List<(String, String)> _messages = [
    ('📖 O poveste te așteaptă', 'Începe ziua cu un basm românesc citit cu voce.'),
    ('✨ Pauză de poveste', 'Ileana Cosânzeana și Făt-Frumos te cheamă în aplicație.'),
    ('🌙 Povestea de seară', 'Adoarme copilul cu un basm citit cu voce — fără să ai tu glas.'),
  ];

  Future<void> initialize() async {
    if (_initialized) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;

    tzdata.initializeTimeZones();
    // App țintă România; Bucharest = default rezonabil și pt diaspora.
    try {
      tz.setLocalLocation(tz.getLocation('Europe/Bucharest'));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    await _requestPermissions();
    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      await ios?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  /// Programează cele 3 reminder-uri zilnice (se repetă zilnic la aceeași oră).
  Future<void> scheduleDailyReminders() async {
    if (!_initialized) return;

    const androidDetails = AndroidNotificationDetails(
      'povesti_reminders',
      'Reminder povești',
      channelDescription: 'Reminder zilnic să citești o poveste',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    for (var i = 0; i < _hours.length; i++) {
      final (title, body) = _messages[i];
      await _plugin.zonedSchedule(
        100 + i,
        title,
        body,
        _nextInstanceOf(_hours[i], _minutes[i]),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // repetă zilnic
      );
    }
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> cancelAll() => _plugin.cancelAll();
}
