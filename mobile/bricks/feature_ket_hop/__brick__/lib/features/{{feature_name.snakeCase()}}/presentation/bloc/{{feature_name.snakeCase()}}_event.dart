import 'package:flutter_base/core/base/state/bloc/base_event.dart';

/// Load list of {{feature_name.camelCase()}}s
class Load{{feature_name.pascalCase()}}s extends BaseEvent {
  final Map<String, dynamic>? params;
  final bool refresh;

  const Load{{feature_name.pascalCase()}}s({this.params, this.refresh = false});

  @override
  List<Object?> get props => [params, refresh];
}
