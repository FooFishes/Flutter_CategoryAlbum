//主屏幕页面AI帮了大大大大忙了((((((((

import 'package:flutter/material.dart';
import 'package:category_album/models/category.dart';
import 'package:category_album/screens/category_screen.dart';
import 'package:category_album/services/database_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:category_album/screens/photo_classification_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  //创建状态
  _HomeScreenState createState() => _HomeScreenState();
}
//状态类
class _HomeScreenState extends State<HomeScreen> {
  //创建一个类别列表
  List<Category> categories = [];
  //声明了一个常量 _imagePicker，类型为 ImagePicker，用于选择图片
  final ImagePicker _imagePicker = ImagePicker();

  //重写initState方法,初始化父类状态,加载类别
  //重写此方法以执行初始化
  //这些初始化依赖于该对象被插入到树中的位置（即 [context]）
  //或用于配置此对象的部件（即 [widget]）
  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  //加载类别(使用异步操作)
  Future<void> _loadCategories() async {
    //调用数据库操作获取所有类别
    final loadedCategories = await DatabaseHelper.instance.getCategories();
    setState(() {
      categories = loadedCategories;
    });
    //setState() 方法：通知 Flutter，有状态已经发生变化，需重新构建界面。
//为什么使用 setState()？ 如果直接修改状态变量而不调用 setState()，界面不会更新。setState() 会触发界面的重绘。
  }
//新增类别
//啊啊啊懒得写注释了,现在我能看懂,过一周只有上帝能看懂了(逃)
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
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(categories[index].name),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryScreen(category: categories[index]),
                ),
              ).then((_) => _loadCategories());
            },
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteCategory(categories[index]),
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