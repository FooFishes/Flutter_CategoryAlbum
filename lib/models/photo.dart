/// 这个函数接受一个整数列表，并返回一个每个整数都增加一的新的列表。
/// 
/// - 参数 numbers: 一个需要增加的整数列表。
/// - 返回: 一个新的整数列表，其中每个整数都增加了一。

/// 这个和catagory.dart文件类似，只是这个是用来存储图片的,都是给数据库用的
class Photo {
  int? id;
  String path;
  int categoryId;

  Photo({this.id, required this.path, required this.categoryId});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'path': path,
      'category_id': categoryId,
    };
  }

  factory Photo.fromMap(Map<String, dynamic> map) {
    return Photo(
      id: map['id'],
      path: map['path'],
      categoryId: map['category_id'],
    );
  }
}