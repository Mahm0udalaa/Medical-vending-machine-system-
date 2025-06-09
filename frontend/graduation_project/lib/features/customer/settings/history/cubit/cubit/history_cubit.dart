import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/history_model.dart';
import '../../data/repos/history_repo.dart';

part 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final HistoryRepo repo;
  HistoryCubit(this.repo) : super(HistoryInitial());

  Future<void> fetchHistory() async {
    emit(HistoryLoading());
    try {
      final history = await repo.fetchHistory();
      emit(HistoryLoaded(history));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }
}
