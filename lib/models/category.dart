/// 这个文件定义了`Category`
/// `Category`是一个数据模型类，用于表示一个分类
class Category {
  //创建新实例时id可以为null
  int? id;
  String name;
  //name不可空,所以必须加required..
  Category({this.id, required this.name});

  //前面说明了该方法的返回值是Map<String, dynamic>,键是String类型,值是dynamic类型
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  //这是一个工厂方法,用于从Map<String, dynamic>类型的map中创建一个Category对象
  //这里是AI帮我优化的(逃
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
    );
  }
}