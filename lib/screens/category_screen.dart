import 'package:flutter/material.dart';
import 'package:category_album/models/category.dart';
import 'package:category_album/models/photo.dart';
import 'package:category_album/screens/photo_view_screen.dart';
import 'package:category_album/services/database_helper.dart';
import 'dart:io';

class CategoryScreen extends StatefulWidget {
  final Category category;

  CategoryScreen({required this.category});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Photo> photos = [];
  Set<Photo> selectedPhotos = {};
  bool isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final loadedPhotos = await DatabaseHelper.instance.getPhotosByCategory(widget.category.id!);
    setState(() {
      photos = loadedPhotos;
    });
  }

  Future<void> _deletePhoto(Photo photo) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认删除'),
        content: Text('确定要删除这张照片吗？'),
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
      await DatabaseHelper.instance.deletePhoto(photo.id!);
      _loadPhotos();
    }
  }

  Future<void> _deleteSelectedPhotos() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认删除'),
        content: Text('确定要删除选中的照片吗？'),
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
      for (var photo in selectedPhotos) {
        await DatabaseHelper.instance.deletePhoto(photo.id!);
      }
      setState(() {
        selectedPhotos.clear();
        isSelectionMode = false;
      });
      _loadPhotos();
    }
  }

  Future<void> _changeCategoryForPhoto(Photo photo) async {
    final categories = await DatabaseHelper.instance.getCategories();
    final selectedCategory = await showDialog<Category>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('选择新类别'),
          children: categories.map((category) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, category);
              },
              child: Text(category.name),
            );
          }).toList(),
        );
      },
    );

    if (selectedCategory != null && selectedCategory.id != widget.category.id) {
      photo.categoryId = selectedCategory.id!;
      await DatabaseHelper.instance.updatePhoto(photo);
      _loadPhotos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        actions: [
          if (isSelectionMode)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteSelectedPhotos,
            ),
          IconButton(
            icon: Icon(isSelectionMode ? Icons.close : Icons.select_all),
            onPressed: () {
              setState(() {
                if (isSelectionMode) {
                  selectedPhotos.clear();
                }
                isSelectionMode = !isSelectionMode;
              });
            },
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (isSelectionMode) {
                setState(() {
                  if (selectedPhotos.contains(photos[index])) {
                    selectedPhotos.remove(photos[index]);
                  } else {
                    selectedPhotos.add(photos[index]);
                  }
                });
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PhotoViewScreen(photo: photos[index]),
                  ),
                );
              }
            },
            onLongPress: () {
              setState(() {
                isSelectionMode = true;
                selectedPhotos.add(photos[index]);
              });
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  File(photos[index].path),
                  fit: BoxFit.cover,
                ),
                if (isSelectionMode)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Icon(
                      selectedPhotos.contains(photos[index])
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: Colors.white,
                    ),
                  ),
                if (!isSelectionMode)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.white),
                          onPressed: () => _deletePhoto(photos[index]),
                        ),
                        IconButton(
                          icon: Icon(Icons.category, color: Colors.white),
                          onPressed: () => _changeCategoryForPhoto(photos[index]),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
