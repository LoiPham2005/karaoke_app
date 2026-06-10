import 'package:freezed_annotation/freezed_annotation.dart';

class StringToDoubleConverter implements JsonConverter<double, dynamic> {
  const StringToDoubleConverter();

  @override
  double fromJson(dynamic json) {
    if (json == null) return 0.0;
    if (json is num) return json.toDouble();
    if (json is String) {
      return double.tryParse(json) ?? 0.0;
    }
    return 0.0;
  }

  @override
  dynamic toJson(double object) => object;
}

class StringToDoubleNullableConverter implements JsonConverter<double?, dynamic> {
  const StringToDoubleNullableConverter();

  @override
  double? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is num) return json.toDouble();
    if (json is String) {
      return double.tryParse(json);
    }
    return null;
  }

  @override
  dynamic toJson(double? object) => object;
}

class StringToIntConverter implements JsonConverter<int, dynamic> {
  const StringToIntConverter();

  @override
  int fromJson(dynamic json) {
    if (json == null) return 0;
    if (json is num) return json.toInt();
    if (json is String) {
      return int.tryParse(json) ?? 0;
    }
    return 0;
  }

  @override
  dynamic toJson(int object) => object;
}
