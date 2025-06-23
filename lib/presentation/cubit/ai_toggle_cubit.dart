import 'package:flutter_bloc/flutter_bloc.dart';

class AiToggleCubit extends Cubit<bool> {
  AiToggleCubit() : super(false);

  void toggle() {
    emit(!state);
  }

  void setEnabled(bool enabled) {
    emit(enabled);
  }
}
