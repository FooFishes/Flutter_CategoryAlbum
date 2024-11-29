import 'package:flutter/material.dart';
import 'package:category_album/models/category.dart';
import 'package:category_album/screens/category_screen.dart';
import 'package:category_album/services/database_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:category_album/screens/photo_classification_screen.dart';
import 'package:category_album/models/photo.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Category> categories = [];
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final loadedCategories = await DatabaseHelper.instance.getCategories();
    for (var category in loadedCategories) {
      final photos = await DatabaseHelper.instance.getPhotosByCategory(category.id!);
      if (photos.isNotEmpty) {
        category.latestPhoto = photos.last;
      }
    }
    setState(() {
      categories = loadedCategories;
    });
  }

  Future<void> _addCategory() async {
    final nameController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('新建类别'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: "输入类别名称"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('取消'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('确定'),
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  final newCategory = Category(name: nameController.text);
                  await DatabaseHelper.instance.insertCategory(newCategory);
                  Navigator.pop(context);
                  _loadCategories();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _takePhoto() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoClassificationScreen(imagePath: image.path),
        ),
      ).then((_) => _loadCategories());
    }
  }

  Future<void> _deleteCategory(Category category) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认删除'),
        content: Text('确定要删除类别 "${category.name}" 及其所有照片吗？'),
        actions: [
          TextButton(
            child: Text('取消'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('确定'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm) {
      await DatabaseHelper.instance.deleteCategory(category.id!);
      _loadCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('分类相册'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryScreen(category: categories[index]),
                ),
              ).then((_) => _loadCategories());
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (categories[index].latestPhoto != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(categories[index].latestPhoto!.path),
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        categories[index].name[0].toUpperCase(),
                        style: TextStyle(fontSize: 40, color: Colors.white),
                      ),
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      categories[index].name,
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: IconButton(
                    icon: Icon(Icons.delete, color: Colors.white),
                    onPressed: () => _deleteCategory(categories[index]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "button1",
            onPressed: _addCategory,
            child: Icon(Icons.add),
            tooltip: '新建类别',
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "button2",
            onPressed: _takePhoto,
            child: Icon(Icons.camera_alt),
            tooltip: '拍照',
          ),
        ],
      ),
    );
  }
}
