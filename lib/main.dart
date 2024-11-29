import 'package:flutter/material.dart';
import 'package:category_album/screens/home_screen.dart';
import 'package:category_album/services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Album App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        textTheme: Typography.material2021().black,
      ),
      home: HomeScreen(),
    );
  }
}
