import 'package:flutter_bloc/flutter_bloc.dart';
import 'delete_account_state.dart';
import '../../data/repos/delete_account_repo.dart';

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  final DeleteAccountRepo repo;
  DeleteAccountCubit(this.repo) : super(DeleteAccountInitial());

  Future<void> deleteAccount() async {
    emit(DeleteAccountLoading());
    try {
      await repo.deleteAccount();
      emit(DeleteAccountSuccess());
    } catch (e) {
      emit(DeleteAccountError(e.toString()));
    }
  }
} 