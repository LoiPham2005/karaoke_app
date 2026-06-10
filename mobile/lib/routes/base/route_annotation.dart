// 📁 lib/core/base/annotations.dart

/// Annotation để đánh dấu một Widget là một Route Page.
/// Dùng cho tool generate_route.dart quét tự động.
class RouteAnnotation {
  final String? path;
  final String? name;
  final String? group;

  const RouteAnnotation({this.path, this.name, this.group});
}

const route = RouteAnnotation();
