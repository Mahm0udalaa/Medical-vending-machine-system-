import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/widgets/custem_button.dart';
import 'package:graduation_project/core/widgets/custom_appbar.dart';
import 'package:graduation_project/core/widgets/custom_text_field.dart';
import 'package:graduation_project/features/auth/forget_password/cubit/new_password_cubit.dart';
import 'package:graduation_project/features/auth/forget_password/cubit/new_password_state.dart';
import 'package:graduation_project/features/auth/forget_password/presentation/widgets/popupsuccess.dart';

class NewPasswordBody extends StatefulWidget {
  final String email;
  final String code;

  const NewPasswordBody({
    super.key,
    required this.email,
    required this.code,
  });

  @override
  State<NewPasswordBody> createState() => _NewPasswordBodyState();
}

class _NewPasswordBodyState extends State<NewPasswordBody> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _rePasswordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final password = _passwordController.text.trim();
    final rePassword = _rePasswordController.text.trim();

    if (password.isEmpty || rePassword.isEmpty) {
      _showError('Please fill all password fields');
      return;
    }

    if (password != rePassword) {
      _showError('Passwords do not match');
      return;
    }

    context.read<NewPasswordCubit>().resetPassword(
          email: widget.email,
          code: widget.code,
          newPassword: password,
        );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NewPasswordCubit, NewPasswordState>(
      listener: (context, state) {
        if (state is NewPasswordSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          showDialog(
            context: context,
            barrierColor: Colors.black.withAlpha((0.5 * 255).toInt()),
            barrierDismissible: false,
            builder: (context) => const Popupsuccess(),
          );
        } else if (state is NewPasswordError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CustomAppBar(screenTitle: ""),
                        const SizedBox(),
                        const Text(
                          "New Password",
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Your password must contain at least one uppercase letter, one lowercase letter, one number, and one special character .",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Color(0xff6C7278),
                          ),
                        ),
                        const SizedBox(height: 24),
                        CustomTextField(
                          hintText: "Password",
                          isPassword: true,
                          controller: _passwordController,
                        ),
                        CustomTextField(
                          hintText: "Re-enter Password",
                          isPassword: true,
                          controller: _rePasswordController,
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: "Create New Password",
                          backgroundcolor: const Color(0xff26864E),
                          onPressed: () => _submit(context),
                        ),
                        const SizedBox(height: 200),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (state is NewPasswordLoading)
              Container(
                color:  Colors.black.withAlpha((0.5 * 255).toInt()),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        );
      },
    );
  }
}
