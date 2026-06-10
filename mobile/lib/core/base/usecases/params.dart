// ════════════════════════════════════════════════════════════════
// 📁 lib/core/usecases/params.dart
// ════════════════════════════════════════════════════════════════

import 'package:equatable/equatable.dart';

/// Dùng khi UseCase không cần params
class NoParams extends Equatable {
  const NoParams();
  @override
  List<Object?> get props => [];
}

/// Base class cho params phức tạp
abstract class Params extends Equatable {
  const Params();
  Map<String, dynamic> toJson() => {};
}

// ════════════════════════════════════════════════════════════════
// Sentinel — dùng để phân biệt "không truyền" vs "truyền null"
// ════════════════════════════════════════════════════════════════

// ignore: prefer_void_to_null
const _absent = Object();
bool _isAbsent(Object? v) => identical(v, _absent);

// ════════════════════════════════════════════════════════════════
// PaginationParams
// ════════════════════════════════════════════════════════════════

class PaginationParams extends Params {
  final int page;
  final int limit;
  final String? sortBy;
  final bool ascending;

  const PaginationParams({this.page = 1, this.limit = 20, this.sortBy, this.ascending = true});

  @override
  List<Object?> get props => [page, limit, sortBy, ascending];

  @override
  Map<String, dynamic> toJson() => {
    'page': page,
    'limit': limit,
    if (sortBy != null) 'sort_by': sortBy,
    if (sortBy != null) 'order': ascending ? 'asc' : 'desc',
  };

  /// [sortBy] dùng sentinel — có thể reset về null bằng `sortBy: null`
  PaginationParams copyWith({int? page, int? limit, Object? sortBy = _absent, bool? ascending}) =>
      PaginationParams(
        page: page ?? this.page,
        limit: limit ?? this.limit,
        sortBy: _isAbsent(sortBy) ? this.sortBy : sortBy as String?,
        ascending: ascending ?? this.ascending,
      );

  PaginationParams nextPage() => copyWith(page: page + 1);
  PaginationParams reset() => copyWith(page: 1);
}

// ════════════════════════════════════════════════════════════════
// IdParam
// ════════════════════════════════════════════════════════════════

class IdParam extends Params {
  final String id;
  const IdParam(this.id);

  @override
  List<Object?> get props => [id];
}

// ════════════════════════════════════════════════════════════════
// SearchParams
// ════════════════════════════════════════════════════════════════

class SearchParams extends Params {
  final String? keyword;
  final int page;
  final int limit;
  final Map<String, dynamic>? filters;

  const SearchParams({this.keyword, this.page = 1, this.limit = 20, this.filters});

  @override
  List<Object?> get props => [keyword, page, limit, filters];

  @override
  Map<String, dynamic> toJson() => {
    if (keyword?.isNotEmpty == true) 'keyword': keyword,
    'page': page,
    'limit': limit,
    if (filters != null) ...filters!,
  };

  /// [keyword] và [filters] dùng sentinel — có thể reset về null
  SearchParams copyWith({
    Object? keyword = _absent,
    int? page,
    int? limit,
    Object? filters = _absent,
  }) => SearchParams(
    keyword: _isAbsent(keyword) ? this.keyword : keyword as String?,
    page: page ?? this.page,
    limit: limit ?? this.limit,
    filters: _isAbsent(filters) ? this.filters : filters as Map<String, dynamic>?,
  );

  SearchParams nextPage() => copyWith(page: page + 1);

  /// Reset về trạng thái ban đầu
  SearchParams clear() => const SearchParams();

  bool get hasKeyword => keyword?.isNotEmpty == true;
  bool get hasFilters => filters?.isNotEmpty == true;
}

// ════════════════════════════════════════════════════════════════
// DateRangeParams
// ════════════════════════════════════════════════════════════════

class DateRangeParams extends Params {
  final DateTime? startDate;
  final DateTime? endDate;

  const DateRangeParams({this.startDate, this.endDate});

  /// Factory có validation — throw AssertionError nếu endDate trước startDate
  factory DateRangeParams.validated({required DateTime startDate, required DateTime endDate}) {
    assert(!endDate.isBefore(startDate), 'endDate ($endDate) phải sau startDate ($startDate)');
    return DateRangeParams(startDate: startDate, endDate: endDate);
  }

  /// Hôm nay
  factory DateRangeParams.today() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1, microseconds: -1));
    return DateRangeParams(startDate: start, endDate: end);
  }

  /// 7 ngày gần nhất
  factory DateRangeParams.lastWeek() {
    final now = DateTime.now();
    return DateRangeParams(startDate: now.subtract(const Duration(days: 7)), endDate: now);
  }

  /// 30 ngày gần nhất
  factory DateRangeParams.lastMonth() {
    final now = DateTime.now();
    return DateRangeParams(startDate: now.subtract(const Duration(days: 30)), endDate: now);
  }

  @override
  List<Object?> get props => [startDate, endDate];

  @override
  Map<String, dynamic> toJson() => {
    if (startDate != null) 'start_date': startDate!.toIso8601String(),
    if (endDate != null) 'end_date': endDate!.toIso8601String(),
  };

  bool get isValid => startDate != null && endDate != null && !endDate!.isBefore(startDate!);

  Duration? get duration => isValid ? endDate!.difference(startDate!) : null;

  DateRangeParams copyWith({Object? startDate = _absent, Object? endDate = _absent}) =>
      DateRangeParams(
        startDate: _isAbsent(startDate) ? this.startDate : startDate as DateTime?,
        endDate: _isAbsent(endDate) ? this.endDate : endDate as DateTime?,
      );
}

// ════════════════════════════════════════════════════════════════
// Extension
// ════════════════════════════════════════════════════════════════

extension ParamsX on Params {
  /// Convert sang query string — dùng cho GET request
  String toQueryString() {
    final json = toJson();
    if (json.isEmpty) return '';
    return json.entries
        .where((e) => e.value != null)
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
  }
}
