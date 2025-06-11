# Flutter RTC Chat App

A real-time chat application built with Flutter and Supabase, featuring authentication, push notifications, and a modern UI.

## Features
- User authentication (sign up, sign in, sign out)
- Real-time chat with Supabase as backend
- Push notifications using Firebase Cloud Messaging (FCM)
- Clean and modern UI
- Secure environment variable management

## Project Structure
```
lib/
  main.dart                # App entry point, Supabase and dotenv setup
  screens/
    auth.dart              # Authentication screen
    chat.dart              # Main chat screen
  widgets/
    chat_messages.dart     # Chat message list widget
    msg_bubble.dart        # Individual message bubble widget
    new_message.dart       # Message input widget
    user_image_picker.dart # User image picker widget
supabase/
  functions/
    chat_notif/            # Supabase Edge Function for FCM push notifications
    service-account.json   # Firebase service account for FCM
  config.toml              # Supabase config
.env                       # Environment variables (not committed)
```

## Getting Started

### Prerequisites
- Flutter SDK
- Supabase project
- Firebase project (for FCM)

### Setup
1. **Clone the repository**
2. **Install dependencies**
   ```sh
   flutter pub get
   ```
3. **Configure environment variables**
   - Create a `.env` file in the project root:
     ```env
     SUPABASE_URL=your-supabase-url
     SUPABASE_ANON_KEY=your-supabase-anon-key
     ```
   - Do not commit `.env` to version control.
4. **Set up Supabase Edge Function**
   - Place your Firebase service account in `supabase/functions/service-account.json`.
   - Configure `supabase/functions/chat_notif/index.ts` to use environment variables.

### Running the App
- For Android/iOS:
  ```sh
  flutter run
  ```

## Commits & Structure
- Initial project setup
- Add authentication and chat screens
- Integrate Supabase for real-time chat
- Add push notification support (Supabase Edge Function + FCM)
- Secure keys with dotenv
- Remove desktop/web support for mobile focus

## License
MIT
