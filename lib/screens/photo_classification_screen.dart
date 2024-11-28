import 'package:flutter/material.dart';
import 'package:category_album/models/category.dart';
import 'package:category_album/models/photo.dart';
import 'package:category_album/services/database_helper.dart';
import 'dart:io';

///这个我懒得写注释了,刚把AI写的一坨改好(
class PhotoClassificationScreen extends StatefulWidget {
  final String imagePath;

  PhotoClassificationScreen({required this.imagePath});

  @override
  _PhotoClassificationScreenState createState() => _PhotoClassificationScreenState();
}

class _PhotoClassificationScreenState extends State<PhotoClassificationScreen> {
  List<Category> categories = [];
  Category? selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final loadedCategories = await DatabaseHelper.instance.getCategories();
    setState(() {
      categories = loadedCategories;
    });
  }

  Future<void> _savePhoto() async {
    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请先选择一个类别')),
      );
      return;
    }

    final newPhoto = Photo(path: widget.imagePath, categoryId: selectedCategory!.id!);
    await DatabaseHelper.instance.insertPhoto(newPhoto);
    Navigator.of(context).pop();
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
                  final id = await DatabaseHelper.instance.insertCategory(newCategory);
                  newCategory.id = id;
                  Navigator.pop(context);
                  setState(() {
                    categories.add(newCategory);
                    selectedCategory = newCategory;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('选择照片类别'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Image.file(
              File(widget.imagePath),
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                if (index == categories.length) {
                  return ListTile(
                    title: Text('新建类别'),
                    leading: Icon(Icons.add),
                    onTap: _addCategory,
                  );
                }
                return ListTile(
                  title: Text(categories[index].name),
                  leading: Radio<Category>(
                    value: categories[index],
                    groupValue: selectedCategory,
                    onChanged: (Category? value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _savePhoto,
        child: Icon(Icons.save),
        tooltip: '保存照片',
      ),
    );
  }
}