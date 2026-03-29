import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localNotificationServiceProvider = Provider<LocalNotificationService>((
  ref,
) {
  return LocalNotificationService.disabled();
});

enum LocalNotificationSendStatus { sent, permissionDenied, unsupported, failed }

class LocalNotificationService {
  LocalNotificationService._({
    required FlutterLocalNotificationsPlugin? plugin,
    required bool isSupported,
  }) : _plugin = plugin,
       _isSupported = isSupported;

  factory LocalNotificationService.disabled() {
    return LocalNotificationService._(plugin: null, isSupported: false);
  }

  static const String _androidChannelId = 'zerdestudy_general';
  static const String _androidChannelName = 'ZerdeStudy alerts';
  static const String _androidChannelDescription =
      'Local reminders and test alerts for ZerdeStudy.';
  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        _androidChannelId,
        _androidChannelName,
        description: _androidChannelDescription,
        importance: Importance.high,
      );

  final FlutterLocalNotificationsPlugin? _plugin;
  final bool _isSupported;

  bool get isSupported => _isSupported;

  static Future<LocalNotificationService> create() async {
    if (!_supportsNotificationsOnCurrentPlatform) {
      return LocalNotificationService.disabled();
    }

    final plugin = FlutterLocalNotificationsPlugin();

    try {
      const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        macOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        linux: LinuxInitializationSettings(
          defaultActionName: 'Open notification',
        ),
        windows: WindowsInitializationSettings(
          appName: 'ZerdeStudy',
          appUserModelId: 'com.zerdestudy.frontendflutter',
          guid: 'd49b0314-ee7a-4626-bf79-97cdb8a991bb',
        ),
      );

      await plugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint(
            'Notification tapped with payload: ${response.payload ?? 'empty'}',
          );
        },
      );

      final service = LocalNotificationService._(
        plugin: plugin,
        isSupported: true,
      );
      await service._configureChannels();
      return service;
    } catch (error, stackTrace) {
      debugPrint('Local notifications failed to initialize: $error');
      debugPrintStack(stackTrace: stackTrace);
      return LocalNotificationService.disabled();
    }
  }

  Future<LocalNotificationSendStatus> sendTestNotification({
    required String title,
    required String body,
  }) async {
    if (!_isSupported || _plugin == null) {
      return LocalNotificationSendStatus.unsupported;
    }

    final permissionsGranted = await _ensurePermissions();
    if (!permissionsGranted) {
      return LocalNotificationSendStatus.permissionDenied;
    }

    try {
      await _plugin.show(
        id: 4201,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannelId,
            _androidChannelName,
            channelDescription: _androidChannelDescription,
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
          macOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
          linux: LinuxNotificationDetails(),
          windows: WindowsNotificationDetails(),
        ),
        payload: 'settings:test_notification',
      );
      return LocalNotificationSendStatus.sent;
    } catch (error, stackTrace) {
      debugPrint('Sending local notification failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return LocalNotificationSendStatus.failed;
    }
  }

  Future<void> _configureChannels() async {
    final androidImplementation = _plugin
        ?.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImplementation?.createNotificationChannel(_androidChannel);
  }

  Future<bool> _ensurePermissions() async {
    final plugin = _plugin;
    if (plugin == null) {
      return false;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await androidImplementation?.requestNotificationsPermission() ??
          true;
    }

    var granted = true;

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosImplementation = plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      granted =
          granted &&
          (await iosImplementation?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
              false);
    }

    if (defaultTargetPlatform == TargetPlatform.macOS) {
      final macImplementation = plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >();
      granted =
          granted &&
          (await macImplementation?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
              false);
    }

    return granted;
  }

  static bool get _supportsNotificationsOnCurrentPlatform {
    if (kIsWeb) {
      return false;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => true,
      TargetPlatform.iOS => true,
      TargetPlatform.macOS => true,
      TargetPlatform.linux => true,
      TargetPlatform.windows => true,
      TargetPlatform.fuchsia => false,
    };
  }
}
