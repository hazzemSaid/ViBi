import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> initialize() async {
    // Request permission for iOS/Android 13+
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permission');
      }

      // Save OneSignal ID
      await _saveOneSignalId();

      // Listen to OneSignal subscription changes
      OneSignal.User.pushSubscription.addObserver((state) async {
        final subscriptionId = state.current.id;
        if (kDebugMode) {
          debugPrint('OneSignal subscription changed: $subscriptionId');
        }
        if (subscriptionId != null) {
          await _saveSubscriptionId(subscriptionId);
        }
      });
    } else {
      if (kDebugMode) {
        print('User declined or has not accepted permission');
      }
    }

    // Listen to auth state changes to update OneSignal when user logs in
    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.initialSession) {
        _saveOneSignalId();
      }
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');
      }

      if (message.notification != null) {
        if (kDebugMode) {
          print(
            'Message also contained a notification: ${message.notification}',
          );
        }
      }
    });
  }

  Future<void> _saveOneSignalId() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        // Wait a moment for OneSignal to fully initialize if needed
        await Future.delayed(const Duration(milliseconds: 500));

        final playerId = await OneSignal.User.getOnesignalId();
        if (playerId != null) {
          await _supabase
              .from('profiles')
              .update({'onesignal_id': playerId})
              .eq('id', user.id);

          if (kDebugMode) {
            print('OneSignal ID updated in Supabase for user: ${user.id}');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error updating OneSignal ID in Supabase: $e');
        }
      }
    }
  }

  Future<void> _saveSubscriptionId(String subscriptionId) async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _supabase
            .from('profiles')
            .update({'onesignal_subscription_id': subscriptionId})
            .eq('id', user.id);

        if (kDebugMode) {
          print(
            'OneSignal subscription ID updated in Supabase for user: ${user.id}',
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error updating OneSignal subscription ID in Supabase: $e');
        }
      }
    }
  }
}

// Global background handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
  }
}
