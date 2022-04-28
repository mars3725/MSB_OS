import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:msb_os/views/schedule_view.dart';
import 'firebase_options.dart';

import 'views/home_view.dart';

const robotID = '1234';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeView(),
      routes: {
        '/schedule': (context) => const ScheduleView()
      },
    );
  }
}
