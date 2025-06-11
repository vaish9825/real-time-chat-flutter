// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:rtc_app/widgets/chat_messages.dart';
import 'package:rtc_app/widgets/new_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _supabase = Supabase.instance.client;

  // Future<void> _setFCMToken(var token) async {
  //   await _supabase
  //       .from('users')
  //       .update({'fcm_token': token})
  //       .eq('id', _supabase.auth.currentUser!.id);
  // }

  // void setupPushNotifications() async {
  //   final fcm = FirebaseMessaging.instance;

  //   await fcm.requestPermission();
  //   final token = await fcm.getToken();
  //   if (token != null) {
  //     await _setFCMToken(token);
  //   }

  //   fcm.onTokenRefresh.listen((newToken) async {
  //     await _setFCMToken(newToken);
  //   });

  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     if (message.notification != null) {
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(message.notification!.title ?? ''),
  //             duration: const Duration(seconds: 2),
  //           ),
  //         );
  //       }
  //     }
  //   });
  // }

  @override
  void initState() {
    super.initState();
    // setupPushNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 20,
          child: Image.network(
            _supabase.storage
                .from('avatars')
                .getPublicUrl(
                  'user_avatars/${_supabase.auth.currentUser!.id}.jpeg',
                ),
            fit: BoxFit.cover,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () async {
              await _supabase.auth.signOut();
            },
          ),
        ],
      ),
      body: Column(children: [Expanded(child: ChatMessages()), NewMessage()]),
    );
  }
}
