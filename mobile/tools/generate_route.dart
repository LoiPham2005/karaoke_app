// =============================================================================
// 🌉  Route Generator Tool
// =============================================================================
// Triết lý:
// 1. Dùng RouteNames để giữ Path Constant (bắt buộc cho @TypedGoRoute annotation).
// 2. Tham số truyền hoàn toàn qua Typed Route Class (IntroRoute(...)).
// 3. Scan tự động file có marker // @route: <path> [Group] trong features/.
// =============================================================================

import 'dart:io';

// Quét tất cả thư mục có thể chứa page với `// @route:` marker.
// Mở rộng list này nếu thêm thư mục mới (vd: 'lib/admin', 'lib/shared_pages').
const _scanDirs = ['lib/features', 'lib/modules'];
const _routesFile = 'lib/routes/config/app_routes.dart';
const _routerFile = 'lib/routes/config/app_router.dart';
const _routeNamesFile = 'lib/routes/config/route_names.dart'; // ← moved from constants/

// ─── ANSI Colors ──────────────────────────────────────────────────────────────
const _reset = '\x1B[0m';
const _green = '\x1B[32m';
const _yellow = '\x1B[33m';
const _red = '\x1B[31m';
const _cyan = '\x1B[36m';
const _bold = '\x1B[1m';

void main(List<String> args) {
  final params = _parseArgs(args);

  if (params.containsKey('help')) {
    _printHelp();
    return;
  }
  if (params.containsKey('list')) {
    _listRoutes();
    return;
  }
  if (params.containsKey('scan')) {
    _scanAndGenerate();
    return;
  }

  _error('Vui lòng dùng --scan để tự động quét. Xem --help để biết thêm.');
}

// =============================================================================
// SCAN & GENERATE
// =============================================================================
void _scanAndGenerate() {
  stdout.writeln('\n$_bold$_cyan🌉  Quét Routes...$_reset\n');

  // Validate các file đích tồn tại trước khi bắt đầu
  for (final path in [_routesFile, _routerFile, _routeNamesFile]) {
    if (!File(path).existsSync()) {
      _error('File không tồn tại: $path');
      return;
    }
  }

  // Quét tất cả scan dirs (features, modules, …)
  final files = <File>[];
  for (final dir in _scanDirs) {
    final d = Directory(dir);
    if (!d.existsSync()) {
      _warn('⚠️   Bỏ qua (không tồn tại): $dir');
      continue;
    }
    stdout.writeln('  $_cyan📂 Quét $_reset$dir');
    files.addAll(
      d.listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart')),
    );
  }
  files.sort((a, b) => a.path.compareTo(b.path)); // deterministic order
  stdout.writeln('');

  int foundCount = 0;
  int addedCount = 0;

  for (final file in files) {
    final content = file.readAsStringSync();

    // Marker: // @route: /path [Group Name]
    final markerRegex = RegExp(
      r'//\s*@route:\s*([^\s\[]+)(?:\s*\[([^\]]+)\])?',
    );
    final match = markerRegex.firstMatch(content);
    if (match == null) continue;

    foundCount++;

    // Tìm class đầu tiên SAU marker
    final classRegex = RegExp(r'class\s+(\w+)\s+extends');
    final classMatch = classRegex
        .allMatches(content)
        .where((m) => m.start > match.start)
        .firstOrNull;

    if (classMatch == null) {
      _warn('⚠️  Tìm thấy @route marker nhưng không có class nào sau đó: ${file.path}');
      continue;
    }

    final className = classMatch.group(1)!;
    final routeClassName = className.endsWith('Page')
        ? className.replaceFirst('Page', 'Route')
        : '${className}Route';

    // Parse path từ marker
    final path = match.group(1)!;

    // Parse group: ưu tiên từ marker, fallback từ folder structure
    final group = _detectGroup(match.group(2), file.path);

    // Parse constructor properties (final fields trước Widget build)
    final props = _parseProperties(content, classMatch.start);

    // Import path tương đối từ lib/
    final importPath = _toLibRelativePath(file.path);

    final added = _generate(
      name: routeClassName,
      path: path,
      page: className,
      importPath: importPath,
      group: group,
      properties: props,
    );
    if (added) {
      addedCount++;
      stdout.writeln('  $_green✓$_reset $routeClassName → $path [$group]');
    }
  }

  stdout.writeln('\n${'─' * 50}');
  stdout.writeln('📊 Quét $_bold$foundCount$_reset file có marker | Thêm/cập nhật $_green$_bold$addedCount$_reset routes.');
  if (addedCount > 0) {
    stdout.writeln('$_yellow⚡ Chạy Build Runner để regenerate app_routes.g.dart$_reset');
  }
}

// =============================================================================
// GENERATE CORE
// =============================================================================
bool _generate({
  required String name,
  required String path,
  required String page,
  required String importPath,
  required String group,
  required List<Map<String, String>> properties,
}) {
  final routesContent = File(_routesFile).readAsStringSync();
  final routerContent = File(_routerFile).readAsStringSync();
  final routeNamesContent = File(_routeNamesFile).readAsStringSync();

  // constantName = camelCase từ routeClassName bỏ "Route"
  // VenueRoute → venue, GoogleMapRoute → googleMap
  final baseName = name.replaceFirst('Route', '');
  final constantName = baseName.substring(0, 1).toLowerCase() + baseName.substring(1);

  // 1. Inject import vào app_router.dart (app_router import tất cả pages)
  final newRouter = _injectImport(
    content: routerContent,
    importLine: "import 'package:flutter_base/$importPath';",
  );
  File(_routerFile).writeAsStringSync(newRouter);

  // 2. Thêm constant vào RouteNames nếu chưa có
  if (!routeNamesContent.contains('static const String $constantName =')) {
    final newNames = _injectConstant(
      content: routeNamesContent,
      name: constantName,
      path: path,
      group: group,
    );
    File(_routeNamesFile).writeAsStringSync(newNames);
  }

  // 3. Thêm route block vào app_routes.dart nếu chưa có
  if (routesContent.contains('class $name extends GoRouteData')) {
    return false; // đã tồn tại
  }

  final routeBlock = _buildRouteBlock(
    name: name,
    constantName: constantName,
    page: page,
    properties: properties,
  );
  final newRoutes = _injectRoute(
    content: routesContent,
    routeBlock: routeBlock,
    group: group,
  );
  File(_routesFile).writeAsStringSync(newRoutes);

  return true;
}

// =============================================================================
// BUILDERS
// =============================================================================
String _buildRouteBlock({
  required String name,
  required String constantName,
  required String page,
  required List<Map<String, String>> properties,
}) {
  final fields = properties.map((p) => '  final ${p['type']} ${p['name']};').join('\n');

  final ctorParams = properties.map((p) {
    final type = p['type']!;
    final paramName = p['name']!;
    // Nullable types → default null, primitives → default values, complex → required
    if (type.endsWith('?')) return 'this.$paramName = null';
    return switch (type) {
      'bool' => 'this.$paramName = false',
      'int' => 'this.$paramName = 0',
      'double' => 'this.$paramName = 0.0',
      'String' => 'this.$paramName = ""',
      _ => 'required this.$paramName', // complex/enum → required
    };
  }).join(', ');

  final constructor = properties.isEmpty
      ? '  const $name();'
      : '  const $name({$ctorParams});';

  final passArgs = properties.map((p) => '${p['name']}: ${p['name']}').join(', ');
  final buildReturn = properties.isEmpty ? 'const $page()' : '$page($passArgs)';

  return '''
@TypedGoRoute<$name>(path: RouteNames.$constantName)
class $name extends GoRouteData with \$$name {
${fields.isNotEmpty ? '$fields\n' : ''}$constructor

  @override
  Widget build(BuildContext context, GoRouterState state) => $buildReturn;
}
''';
}

// =============================================================================
// INJECTORS
// =============================================================================
String _injectConstant({
  required String content,
  required String name,
  required String path,
  required String group,
}) {
  final newLine = "  static const String $name = '$path';";
  final groupMarker = '// ── $group';

  // Tìm group marker (// ── Auth, // ── Main App, ...)
  final markerIndex = content.indexOf(groupMarker);

  if (markerIndex == -1) {
    // Group chưa tồn tại → thêm section mới trước dấu } cuối
    final lastBrace = content.lastIndexOf('}');
    if (lastBrace == -1) return content;
    final before = content.substring(0, lastBrace).trimRight();
    return '$before\n\n  // ── $group ────────────────────────────────────────\n$newLine\n}';
  }

  // Tìm vị trí cuối của group hiện tại (trước group tiếp theo hoặc trước })
  final afterMarker = content.indexOf('\n', markerIndex) + 1;
  final nextSection = content.indexOf('\n  // ──', afterMarker);
  final closingBrace = content.lastIndexOf('}');

  final insertAt = (nextSection != -1 && nextSection < closingBrace)
      ? nextSection
      : closingBrace;

  return '${content.substring(0, insertAt).trimRight()}\n$newLine\n${content.substring(insertAt).trimLeft()}';
}

String _injectRoute({
  required String content,
  required String routeBlock,
  required String group,
}) {
  // Tìm group comment trong app_routes.dart: // ─── Group ───
  final groupComment = '// ─── $group';
  final groupIndex = content.indexOf(groupComment);

  if (groupIndex != -1) {
    // Insert trước group section tiếp theo
    final nextGroup = content.indexOf('\n// ───', groupIndex + groupComment.length);
    final insertAt = nextGroup != -1 ? nextGroup : content.length;
    return '${content.substring(0, insertAt).trimRight()}\n\n$routeBlock\n${content.substring(insertAt).trimLeft()}';
  }

  // Không có group section → append cuối file
  return '${content.trimRight()}\n\n// ─── $group ─────────────────────────────────────────\n$routeBlock\n';
}

String _injectImport({required String content, required String importLine}) {
  if (content.contains(importLine)) return content;
  final lines = content.split('\n');
  final lastImportIdx = lines.lastIndexWhere((l) => l.trimLeft().startsWith('import '));
  if (lastImportIdx == -1) {
    return '$importLine\n$content';
  }
  lines.insert(lastImportIdx + 1, importLine);
  return lines.join('\n');
}

// =============================================================================
// HELPERS
// =============================================================================
List<Map<String, String>> _parseProperties(String content, int classStart) {
  final buildIndex = content.indexOf('Widget build', classStart);
  final propRegex = RegExp(r'^\s*final\s+([\w<>?,\s]+)\s+(\w+);', multiLine: true);
  final result = <Map<String, String>>[];

  for (final m in propRegex.allMatches(content)) {
    if (m.start <= classStart) continue;
    if (buildIndex != -1 && m.start >= buildIndex) break;
    final propName = m.group(2)!;
    if (propName == 'key') continue; // skip GlobalKey/Key fields
    result.add({'type': m.group(1)!.trim(), 'name': propName});
  }
  return result;
}

String _detectGroup(String? markerGroup, String filePath) {
  if (markerGroup != null && markerGroup.isNotEmpty) return markerGroup;
  // Auto-detect từ folder structure
  if (filePath.contains('/venue_staff/') || filePath.contains('\\venue_staff\\')) return 'Staff';
  if (filePath.contains('/owner/') || filePath.contains('\\owner\\')) return 'Owner';
  if (filePath.contains('/auth/') || filePath.contains('\\auth\\')) return 'Auth';
  return 'Main App';
}

String _toLibRelativePath(String filePath) {
  // Normalize path separator
  final normalized = filePath.replaceAll('\\', '/');
  final libIndex = normalized.lastIndexOf('/lib/');
  if (libIndex != -1) return normalized.substring(libIndex + 1); // includes "lib/"
  if (normalized.startsWith('lib/')) return normalized;
  return normalized;
}

Map<String, String> _parseArgs(List<String> args) {
  final map = <String, String>{};
  for (int i = 0; i < args.length; i++) {
    if (args[i].startsWith('--')) {
      final key = args[i].substring(2);
      map[key] = (i + 1 < args.length && !args[i + 1].startsWith('--'))
          ? args[++i]
          : 'true';
    }
  }
  return map;
}

void _listRoutes() {
  final content = File(_routesFile).readAsStringSync();
  final regex = RegExp(r"@TypedGoRoute<(\w+)>\(path: (?:RouteNames\.(\w+)|'([^']+)')\)");
  stdout.writeln('\n$_bold$_cyan🛣️  Danh sách Routes:$_reset\n');
  var count = 0;
  for (final m in regex.allMatches(content)) {
    final routeName = m.group(1);
    final path = m.group(2) != null ? 'RouteNames.${m.group(2)}' : m.group(3);
    stdout.writeln('  $_green●$_reset $_bold$routeName$_reset → $path');
    count++;
  }
  stdout.writeln('\n  Tổng: $_bold$count$_reset routes');
}

void _printHelp() {
  stdout.writeln('''
$_bold$_cyan🛣️  Route Generator$_reset

Cách dùng:
  dart run tools/generate_route.dart --scan    Quét features/ và generate routes
  dart run tools/generate_route.dart --list    Liệt kê routes hiện có
  dart run tools/generate_route.dart --help    Hiển thị help này

Đánh dấu page để scan:
  // @route: /my-path
  // @route: /my-path [Group Name]
  class MyPage extends StatelessWidget { ... }

Sau khi chạy --scan, nhớ chạy Build Runner để regenerate app_routes.g.dart.
''');
}

void _error(String msg) => stdout.writeln('$_red❌  $msg$_reset');
void _warn(String msg) => stdout.writeln('$_yellow⚠️   $msg$_reset');
