import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/profile_update_model.dart';
import '../../data/repos/profile_update_repo.dart';
import 'profile_update_state.dart';

class ProfileUpdateCubit extends Cubit<ProfileUpdateState> {
  final ProfileUpdateRepo repo;
  ProfileUpdateCubit(this.repo) : super(ProfileUpdateInitial());

  /// يستخدم لتحديد صورة جديدة قبل رفع البيانات
  void selectImage(String imagePath) {
    emit(ProfileUpdateWithImage(imagePath));
  }

  /// يستخدم لتحديث البروفايل في السيرفر
  Future<void> updateProfile(ProfileUpdateModel model) async {
    emit(ProfileUpdateLoading());
    try {
      final errorMsg = await repo.updateProfile(model);
      if (errorMsg == null) {
        emit(ProfileUpdateSuccess());
      } else {
        emit(ProfileUpdateError(errorMsg));
      }
    } catch (e) {
      emit(ProfileUpdateError(e.toString()));
    }
  }
}
