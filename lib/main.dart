// lib/main.dart
import 'package:flutter/material.dart';
import 'package:category_album/screens/home_screen.dart';
import 'package:category_album/services/database_helper.dart';

void main() async {
  //确保Flutter框架与引擎绑定,使用异步操作必须加上下面这一行
  WidgetsFlutterBinding.ensureInitialized();
  //初始化数据库(异步操作,等待数据库初始化完成)
  await DatabaseHelper.instance.database;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Album App',
      theme: ThemeData(
        // 设置应用程序的主色调为蓝色。
        // 这种颜色用作应用程序主题的基础颜色， 影响各种UI元素，如AppBar、按钮等
        // 感觉怎么没用呢(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}