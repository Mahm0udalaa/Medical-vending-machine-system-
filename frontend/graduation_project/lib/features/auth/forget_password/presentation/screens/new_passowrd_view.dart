import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/widgets/custom_view.dart';
import 'package:graduation_project/features/auth/forget_password/cubit/new_password_cubit.dart';
import 'package:graduation_project/features/auth/forget_password/data/repos/new_password_repo.dart';
import 'package:graduation_project/features/auth/forget_password/presentation/widgets/new_password_body.dart';

class NewPassowrdView extends StatelessWidget {
  final String email;
  final String code;

  const NewPassowrdView({
    super.key,
    required this.email,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    return CustomView(
      body: BlocProvider(
        create: (_) => NewPasswordCubit(newPasswordRepo: NewPasswordRepo()),
        child: NewPasswordBody(
          email: email,
          code: code,
        ),
      ),
    );
  }
}
