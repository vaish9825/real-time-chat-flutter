import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _msgController = TextEditingController();
  final _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final enteredText = _msgController.text;
    if (enteredText.isEmpty) return;

    FocusScope.of(context).unfocus();
    _msgController.clear();

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Fetch user data before inserting the message
    final userData =
        await _supabase
            .from('users')
            .select('username, image_url')
            .eq('id', userId)
            .single();

    final username = userData['username'];
    final userImg = userData['image_url'];

    await _supabase.from('chat').insert({
      'user_id': userId,
      'created_at': DateTime.now().toIso8601String(),
      'msg': enteredText,
      'username': username,
      'user_img': userImg,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 1, bottom: 15),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgController,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: const InputDecoration(labelText: 'Send a message...'),
            ),
          ),
          IconButton(onPressed: _submitMessage, icon: const Icon(Icons.send)),
        ],
      ),
    );
  }
}
