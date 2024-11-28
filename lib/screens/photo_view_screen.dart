// lib/screens/photo_view_screen.dart
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:category_album/models/photo.dart';
import 'dart:io';

class PhotoViewScreen extends StatelessWidget {
  final Photo photo;

  PhotoViewScreen({required this.photo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('查看照片'),
      ),
      body: PhotoView(
        imageProvider: FileImage(File(photo.path)),
        // 设置最小缩放比例，默认值是0.0,这里表示最小可以缩小到适应屏幕尺寸的 80%
        minScale: PhotoViewComputedScale.contained * 0.8,
        // 设置最大缩放比例，默认值是无穷大,这里表示最大可以放大到填充屏幕尺寸的 2 倍
        maxScale: PhotoViewComputedScale.covered * 2,
        // 初始缩放比例,这里表示初始状态下图片会适应屏幕尺寸
        initialScale: PhotoViewComputedScale.contained,
        // 初始位置,这里表示初始状态下图片会居中显示
        basePosition: Alignment.center,
      ),
    );
  }
}
