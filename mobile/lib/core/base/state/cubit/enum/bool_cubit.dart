import 'package:flutter_bloc/flutter_bloc.dart';

class BoolCubit extends Cubit<bool> {
  BoolCubit() : super(false);

  void toggle() => emit(!state); // đảo trạng thái hiện tại
  void setValue(bool value) => emit(value); // set trực tiếp giá trị
}
