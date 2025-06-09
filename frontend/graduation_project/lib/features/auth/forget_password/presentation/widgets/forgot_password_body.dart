import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/widgets/custem_button.dart';
import 'package:graduation_project/core/widgets/custom_appbar.dart';
import 'package:graduation_project/core/widgets/custom_text_field.dart';
import 'package:graduation_project/features/auth/forget_password/cubit/forgot_password_cubit.dart';
import 'package:graduation_project/features/auth/forget_password/data/repos/forgot_password_repo.dart';
import 'package:graduation_project/features/auth/forget_password/presentation/screens/verify_view.dart';

class ForgotPasswordBody extends StatelessWidget {
  ForgotPasswordBody({super.key});

  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ForgotPasswordCubit(ForgotPasswordRepo(dio: Dio())),
      child: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ForgotPasswordLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
          } else {
            Navigator.of(context, rootNavigator: true).pop(); // close loading
          }

          if (state is ForgotPasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VerifyView(email: state.email),
                ),
              );
            });
          } else if (state is ForgotPasswordFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomAppBar(screenTitle: ""),
                      const SizedBox(height: 24),
                      const Text(
                        "Forgot Password",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Don't worry, just enter your email and we will send you a verification code.",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Color(0xff6C7278),
                        ),
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        hintText: "Email",
                        isPassword: false,
                        controller: emailController,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: "Send Code",
                        backgroundcolor: const Color(0xff26864E),
                        onPressed: () {
                          final email = emailController.text.trim();
                          if (email.isNotEmpty) {
                            context.read<ForgotPasswordCubit>().sendResetCode(
                              email,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter your email"),
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
