// ════════════════════════════════════════════════════════════════
// 📁 lib/core/data/network/api_paginated_data.dart
// ════════════════════════════════════════════════════════════════

/// 🎯 Wrapper cho response từ API có phân trang
/// Viết tay để tối ưu linh hoạt, không phụ thuộc vào gencode
class ApiPaginatedData<T> {
  final List<T> data;
  final ApiMeta? meta;

  ApiPaginatedData({
    required this.data,
    this.meta,
  });

  /// Factory bóc tách Map JSON thành List<T> và Metadata
  /// - [json]: Dữ liệu thô từ API
  /// - [fromJsonT]: Hàm callback để parse từng item sang model tương ứng
  factory ApiPaginatedData.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    final rawData = json['data'] as List<dynamic>?;
    final metaData = json['meta'] as Map<String, dynamic>?;

    return ApiPaginatedData<T>(
      data: rawData?.map((item) => fromJsonT(item)).toList() ?? [],
      meta: metaData != null ? ApiMeta.fromJson(metaData) : null,
    );
  }

  /// Chuyển ngược sang JSON (nếu cần thiết cho việc cache hoặc unit test)
  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) {
    return {
      'data': data.map((item) => toJsonT(item)).toList(),
      if (meta != null) 'meta': meta!.toJson(),
    };
  }
}

/// 📊 Metadata phân trang từ API
class ApiMeta {
  static const int defaultPage = 1;
  static const int defaultLimit = 10;

  final int total;
  final int page;
  final int limit;
  final int totalPages;

  ApiMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;
  bool get isFirstPage => page == 1;
  int? get nextPage => hasMore ? page + 1 : null;
  int? get prevPage => page > 1 ? page - 1 : null;

  factory ApiMeta.fromJson(Map<String, dynamic> json) {
    return ApiMeta(
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? defaultPage,
      limit: (json['limit'] as num?)?.toInt() ?? defaultLimit,
      totalPages: (json['totalPages'] as num?)?.toInt() ??
          (json['total_pages'] as num?)?.toInt() ??
          1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'page': page,
      'limit': limit,
      'totalPages': totalPages,
    };
  }
}
