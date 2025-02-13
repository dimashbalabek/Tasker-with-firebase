import 'package:flutter_bloc/flutter_bloc.dart';

class TaskAnimationCubit extends Cubit<Map<int, double>> {
  TaskAnimationCubit() : super({});

  void hideTask(int index) {
    emit({...state, index: 0.0}); 
  }

  void resetTask(int index) {
    final newState = Map.of(state);
    newState.remove(index); 
    emit(newState);
  }
}
