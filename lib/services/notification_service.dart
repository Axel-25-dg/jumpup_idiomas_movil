import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  
  FirebaseMessaging get _firebaseMessaging => FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> initialize() async {
    // Si Firebase no está inicializado, no podemos continuar con FCM
    if (Firebase.apps.isEmpty) {
      debugPrint('NotificationService: Firebase no inicializado. Abortando.');
      return;
    }

    // Solicitar permisos en iOS
    await _firebaseMessaging.requestPermission();

    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(
<<<<<<< HEAD
      //initializationSettings: initSettings, Error local Ariel
      settings: initSettings, 
=======
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Opcional: manejar cuando el usuario toca la notificación
      },
>>>>>>> main
    );

    // Escuchar mensajes en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showLocalNotification(message.notification!);
      }
    });
  }

  Future<void> _showLocalNotification(RemoteNotification notification) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'main_channel',
      'Main Channel',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);
    
    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: platformDetails,
    );
  }

  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }
}
