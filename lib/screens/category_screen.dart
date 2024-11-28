import 'package:flutter/material.dart';
import 'package:category_album/models/category.dart';
import 'package:category_album/models/photo.dart';
import 'package:category_album/screens/photo_view_screen.dart';
import 'package:category_album/services/database_helper.dart';
import 'dart:io';
///啊啊啊我为什么不接着写注释
///有请GitHub Copilot(逃
/// 这个文件定义了CategoryScreen小部件，它显示了一个类别列表供用户选择。
/// 每个类别都可以点击以导航到显示该类别内项目的屏幕。

/// A screen that displays photos of a specific category and allows the user to
/// view, delete, and change the category of photos.
///
/// The [CategoryScreen] is a stateful widget that takes a [Category] object as
/// a required parameter. It manages the state of the photos, selected photos,
/// and selection mode.
///
/// The [_CategoryScreenState] class handles the loading of photos from the
/// database, deleting photos, changing the category of photos, and managing
/// the selection mode. It also builds the UI for displaying the photos in a
/// grid view and provides options for deleting and changing the category of
/// photos.
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

  /// Loads the photos of the specified category from the database and updates
  /// the state with the loaded photos.
  Future<void> _loadPhotos() async {
    final loadedPhotos = await DatabaseHelper.instance.getPhotosByCategory(widget.category.id!);
    setState(() {
      photos = loadedPhotos;
    });
  }

  /// Deletes the specified photo from the database and reloads the photos.
  Future<void> _deletePhoto(Photo photo) async {
    await DatabaseHelper.instance.deletePhoto(photo.id!);
    _loadPhotos();
  }

  /// Deletes the selected photos from the database, clears the selection, and
  /// reloads the photos.
  Future<void> _deleteSelectedPhotos() async {
    for (var photo in selectedPhotos) {
      await DatabaseHelper.instance.deletePhoto(photo.id!);
    }
    setState(() {
      selectedPhotos.clear();
      isSelectionMode = false;
    });
    _loadPhotos();
  }

  /// Changes the category of the specified photo by showing a dialog with the
  /// available categories and updating the photo's category in the database.
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