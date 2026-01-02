import 'package:chat_app_provider/Themes/theme_provider.dart';
import 'package:chat_app_provider/firebase_options.dart';
import 'package:chat_app_provider/services/Ai_service/language_provider.dart';
import 'package:chat_app_provider/services/Isar_services/Isar_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:provider/provider.dart';
import 'services/auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  await IsarService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'update code ',
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: AuthGate(),
    );
  }
}
 
//   static const String apiKey =
//       "AIzaSyAQHLMnLAznmgEILlmrqaeDbjIId3WfOR0";

 
//   static const String apiUrl =
//       "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";

//   Future<String> sendMessage(String message) async {
//     print("📡 Sending to: $apiUrl");

//     try {
//       final uri = Uri.parse("$apiUrl?key=$apiKey");

//       final response = await http.post(
//         uri,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "contents": [
//             {
//               "parts": [
//                 {"text": message},
//               ],
//             },
//           ],
//         }),
//       );

 

 

  