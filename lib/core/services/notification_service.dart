import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../app/config/router.dart';
import 'supabase_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  debugPrint('Handling background message: ${message.messageId}');
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'curhat_notifications',
    'Notifikasi Curhat Finder',
    description:
        'Channel ini digunakan untuk pemberitahuan pesan chat dan antrean konseling.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  static String? _cachedFcmToken;
  static bool _isInitialized = false;

  /// Inisialisasi Firebase Messaging & Notifikasi Lokal
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Registrasi Background Message Handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 2. Minta izin notifikasi
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint('FCM Authorization Status: ${settings.authorizationStatus}');

      // 3. Konfigurasi flutter_local_notifications untuk Android & iOS
      const initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettingsDarwin = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _localNotifications.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (response.payload != null && response.payload!.isNotEmpty) {
            try {
              final data = jsonDecode(response.payload!) as Map<String, dynamic>;
              _handlePayloadNavigation(data);
            } catch (e) {
              debugPrint('Error parsing notification response payload: $e');
            }
          }
        },
      );

      // 4. Buat Notification Channel prioritas tinggi di Android
      final androidPlatform = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlatform != null) {
        await androidPlatform.createNotificationChannel(_channel);
        await androidPlatform.createNotificationChannel(
          const AndroidNotificationChannel(
            'high_importance_channel',
            'Notifikasi Prioritas Tinggi',
            description: 'Channel prioritas tinggi untuk notifikasi pesan masuk.',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
          ),
        );
      }

      // 5. Konfigurasi foreground presentation
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 6. Dengarkan pesan saat aplikasi sedang terbuka (Foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showLocalNotification(message);
      });

      // 7. Dengarkan saat notifikasi diketuk saat aplikasi di background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handlePayloadNavigation(message.data);
      });

      // 8. Cek pesan awal saat aplikasi dibuka dari keadaan mati (Terminated)
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handlePayloadNavigation(initialMessage.data);
      }

      // 9. Ambil FCM Token dan pasang listener perbaruan token
      _messaging.onRegistered.listen((token) {
        _cachedFcmToken = token;
        debugPrint('FCM Device Token: $_cachedFcmToken');
        syncTokenToSupabase();
      });

      await _messaging.register();

      // 10. Sinkronkan token jika user sudah login
      await syncTokenToSupabase();

      _isInitialized = true;
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  /// Menampilkan popup notifikasi lokal saat aplikasi aktif di layar (Foreground)
  static void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      _localNotifications.show(
        id: notification.hashCode,
        title: notification.title ?? 'Curhat Finder',
        body: notification.body ?? '',
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: _channel.importance,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  /// Navigasi langsung (Deep Link) saat notifikasi diketuk
  static void _handlePayloadNavigation(Map<String, dynamic> data) {
    if (data.isEmpty) return;
    try {
      final type = data['type'] as String?;
      final sessionId = data['session_id'] as String? ?? '';

      if (sessionId.isEmpty) return;

      if (type == 'counseling_student_chat' || type == 'counseling_session') {
        final counselorName = data['counselor_name'] as String? ?? 'Konselor Sebaya';
        router.push(ChatRoomRoute(
          sessionId: sessionId,
          counselorName: counselorName,
          isOnline: true,
        ).location);
      } else if (type == 'counseling_counselor_chat' ||
          type == 'counseling_new_queue') {
        final studentTitle =
            data['student_title'] as String? ?? 'Mahasiswa - FILKOM';
        router.push(CounselorChatRoomRoute(
          sessionId: sessionId,
          studentTitle: studentTitle,
        ).location);
      } else if (type == 'anon_chat') {
        final mode = data['mode'] as String? ?? 'Cuma mau didengar';
        router.push(ChatAnonRoomRoute(
          sessionId: sessionId,
          mode: mode,
        ).location);
      }
    } catch (e) {
      debugPrint('Failed to navigate from notification payload: $e');
    }
  }

  /// Mengambil FCM Device Token saat ini
  static Future<String?> getToken() async {
    try {
      if (_cachedFcmToken != null) {
        return _cachedFcmToken;
      }
      final tokenFuture = _messaging.onRegistered.first.timeout(
        const Duration(seconds: 5),
        onTimeout: () => '',
      );
      await _messaging.register();
      final token = await tokenFuture;
      if (token.isNotEmpty) {
        _cachedFcmToken = token;
      }
      return _cachedFcmToken;
    } catch (_) {
      return _cachedFcmToken;
    }
  }

  /// Menyimpan / memperbarui FCM Token ke tabel profiles di Supabase dengan proteksi kolisi akun
  static Future<void> syncTokenToSupabase([String? explicitUserId]) async {
    try {
      final userId = explicitUserId ?? SupabaseService.currentUserId;
      if (userId == null || userId.isEmpty) return;

      final token = await getToken();
      if (token == null || token.isEmpty) return;

      // 1. Lepaskan token ini dari profil lain yang pernah menggunakannya pada HP ini
      // Mencegah akun lama menerima notifikasi yang tidak seharusnya
      try {
        await SupabaseService.client
            .from('profiles')
            .update({'fcm_token': null})
            .eq('fcm_token', token)
            .neq('id', userId);
      } catch (_) {}

      // 2. Kaitkan token secara eksklusif ke user aktif saat ini
      await SupabaseService.client.from('profiles').update({
        'fcm_token': token,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      debugPrint('FCM Token successfully synchronized to Supabase for user: $userId');
    } catch (e) {
      debugPrint('Error syncing FCM Token to Supabase: $e');
    }
  }

  /// Menghapus asosiasi FCM Token saat user logout dari perangkat
  static Future<void> clearToken([String? explicitUserId]) async {
    try {
      final userId = explicitUserId ?? SupabaseService.currentUserId;
      if (userId != null && userId.isNotEmpty) {
        await SupabaseService.client.from('profiles').update({
          'fcm_token': null,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);
        debugPrint('FCM Token successfully cleared from Supabase for user: $userId');
      }
    } catch (e) {
      debugPrint('Error clearing FCM Token from Supabase: $e');
    }
  }
}
