part of 'history_cubit.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();
  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {}
class HistoryLoading extends HistoryState {}
class HistoryLoaded extends HistoryState {
  final List<PurchaseHistoryModel> history;
  const HistoryLoaded(this.history);
  @override
  List<Object?> get props => [history];
}
class HistoryError extends HistoryState {
  final String message;
  const HistoryError(this.message);
  @override
  List<Object?> get props => [message];
}
