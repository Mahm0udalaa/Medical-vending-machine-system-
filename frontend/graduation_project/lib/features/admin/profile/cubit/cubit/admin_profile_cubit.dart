import 'package:flutter_bloc/flutter_bloc.dart';
import 'admin_profile_state.dart'; // Keep this import
import '../../data/models/admin_profile_model.dart';
import '../../data/repos/admin_profile_repo.dart';

class AdminProfileCubit extends Cubit<AdminProfileState> {
  final AdminProfileRepo repo;
  AdminProfileCubit(this.repo) : super(AdminProfileInitial());

  Future<void> updateProfile(AdminProfileModel model) async {
    emit(AdminProfileLoading());
    try {
      final msg = await repo.updateProfile(model);
      emit(AdminProfileSuccess(msg));
    } catch (e) {
      emit(AdminProfileError(e.toString()));
    }
  }
}