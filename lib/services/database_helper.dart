/// 这个文件定义了一个 `DatabaseHelper` 类，用于管理 SQLite 数据库的创建、初始化和基本的 CRUD 操作。
/// 
/// 主要功能包括：
/// - 初始化数据库：通过 `_initDB` 方法创建或打开一个名为 `photo_album.db` 的数据库。
/// - 创建数据库表：在数据库首次创建时，通过 `_createDB` 方法创建 `categories` 和 `photos` 两个表。
/// - 插入数据：提供 `insertCategory` 和 `insertPhoto` 方法分别向 `categories` 和 `photos` 表中插入数据。
/// - 查询数据：提供 `getCategories` 和 `getPhotosByCategory` 方法分别查询所有类别和根据类别 ID 查询照片。
/// - 更新数据：提供 `updateCategory` 和 `updatePhoto` 方法分别更新 `categories` 和 `photos` 表中的数据。
/// - 删除数据：提供 `deleteCategory` 和 `deletePhoto` 方法分别删除 `categories` 和 `photos` 表中的数据。
///  (怎么还是学了CURD
/// 该类使用单例模式，确保整个应用程序中只有一个 `DatabaseHelper` 实例。
/// 依赖库：
/// - `sqflite`：用于 SQLite 数据库操作。
/// - `path`：用于处理文件路径。
/// - `category_album/models/category.dart` 和 `category_album/models/photo.dart`：定义了 `Category` 和 `Photo` 模型类。
/// 这个database_helper是在AI的帮助下写出来的(((bug是我改的,还有注释(

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:category_album/models/category.dart';
import 'package:category_album/models/photo.dart';


class DatabaseHelper {
  //database_helper使用单例模式,确保整个应用程序中只有一个DatabaseHelper实例
  //所以这里用了final修饰,并且提供了一个私有的构造方法_init()
  static final DatabaseHelper instance = DatabaseHelper._init();
  //database是一个私有的静态成员变量,用于保存数据库实例,可以为null(即未初始化),用于稍后初始化
  static Database? _database;

  DatabaseHelper._init();

  //所有数据库操作都是异步的,可以避免阻塞UI线程
  //存在直接返回,不存在开始初始化photo_album.db数据库
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('photo_album.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    //join()方法用于连接两个路径(path包引入),这里用于连接数据库文件的路径
    return await openDatabase(path, version: 1, onCreate: _createDB);
    //openDatabase()方法用于打开数据库,如果数据库不存在则创建一个新的数据库
    //onCreate参数用于指定数据库首次创建时的回调函数,这里指定为_createDB
  }

  //创建catagories表,有两个字段:id和name(id为自增主键)
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT
      )
    ''');

  //创建photos表,有三个字段:id,path和category_id(category_id为外键,关联catagories表的id)
    await db.execute('''
      CREATE TABLE photos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        path TEXT,
        category_id INTEGER,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');
  }
//新建分类(插入)
  Future<int> insertCategory(Category category) async {
    final db = await instance.database;
    return await db.insert('categories', category.toMap());
  }
//新建照片(插入)
  Future<int> insertPhoto(Photo photo) async {
    final db = await instance.database;
    return await db.insert('photos', photo.toMap());
  }
//获取所有分类
  Future<List<Category>> getCategories() async {
    final db = await instance.database;
    final maps = await db.query('categories');
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }
//根据分类id获取照片
  Future<List<Photo>> getPhotosByCategory(int categoryId) async {
    final db = await instance.database;
    final maps = await db.query('photos', where: 'category_id = ?', whereArgs: [categoryId]);
    return List.generate(maps.length, (i) => Photo.fromMap(maps[i]));
  }
//更新分类
  Future<int> updateCategory(Category category) async {
    final db = await instance.database;
    return await db.update('categories', category.toMap(), where: 'id = ?', whereArgs: [category.id]);
  }
//更新照片
  Future<int> updatePhoto(Photo photo) async {
    final db = await instance.database;
    return await db.update('photos', photo.toMap(), where: 'id = ?', whereArgs: [photo.id]);
  }
//删除分类
  Future<int> deleteCategory(int id) async {
    final db = await instance.database;
    await db.delete('photos', where: 'category_id = ?', whereArgs: [id]);
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
//删除照片
  Future<int> deletePhoto(int id) async {
    final db = await instance.database;
    return await db.delete('photos', where: 'id = ?', whereArgs: [id]);
  }
}
