import 'package:flutter/material.dart';
import 'package:rtc_app/widgets/msg_bubble.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _supabase = Supabase.instance.client;

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _supabase
          .from('chat')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: true)
          .limit(100),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading messages'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No messages yet'));
        }

        final messages = snapshot.data!;

        return ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isMe = message['user_id'] == _supabase.auth.currentUser?.id;
            final isFirstInSequence =
                index == 0 ||
                messages[index - 1]['user_id'] != message['user_id'];

            return isFirstInSequence
                ? MessageBubble.first(
                  message: message['msg'],
                  isMe: isMe,
                  userImage: message['user_img'],
                  username: message['username'],
                )
                : MessageBubble.next(message: message['msg'], isMe: isMe);
          },
        );
      },
    );
  }
}
