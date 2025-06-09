import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/widgets/custom_view.dart';
import 'package:graduation_project/features/auth/login/cubit/login_cubit.dart';
import 'package:graduation_project/features/auth/login/data/repos/login_repo.dart';
import 'package:graduation_project/features/auth/login/presentation/screens/login_body.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(LoginRepo()),
      child: CustomView(body: LoginBody()),
    );
  }
}
