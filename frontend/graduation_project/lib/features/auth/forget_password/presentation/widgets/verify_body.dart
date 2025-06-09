import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/constants/my_colors.dart';
import 'package:graduation_project/core/widgets/custem_button.dart';
import 'package:graduation_project/core/widgets/custom_appbar.dart';
import 'package:graduation_project/features/auth/forget_password/cubit/verify_code_cubit.dart';
import 'package:graduation_project/features/auth/forget_password/presentation/screens/new_passowrd_view.dart';
import 'package:pinput/pinput.dart';

class VerifyBody extends StatefulWidget {
  final String email;

  const VerifyBody({super.key, required this.email});

  @override
  State<VerifyBody> createState() => _VerifyBodyState();
}

class _VerifyBodyState extends State<VerifyBody> {
  final TextEditingController pinController = TextEditingController();

  // ✅ دالة إخفاء الإيميل
  String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final username = parts[0];
    final domain = parts[1];

    final visibleCount = username.length >= 6 ? 6 : username.length;
    final visiblePart = username.substring(0, visibleCount);
    final maskedPart = '*' * (username.length - visibleCount);

    return '$visiblePart$maskedPart@$domain';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VerifyCodeCubit, VerifyCodeState>(
      listener: (context, state) {
        // Show loading
        if (state is VerifyCodeLoading || state is VerifyCodeResending) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );
        } else {
          // Close loading
          Navigator.of(context, rootNavigator: true).pop();
        }

        if (state is VerifyCodeSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      NewPassowrdView(email: state.email, code: state.code),
            ),
          );
        } else if (state is VerifyCodeInvalidOrExpired) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
          pinController.clear();
        } else if (state is VerifyCodeFailureWithMessage) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
          pinController.clear();
        } else if (state is VerifyCodeFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
          pinController.clear();
        } else if (state is VerifyCodeResendSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        return Container(
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomCenter,
              colors: MyColors.backgroundColor,
            ),
          ),
          child: CustomScrollView(
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
                        "Verification Code",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Enter the code we sent to the following email address:\n${maskEmail(widget.email)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: Color(0xff6C7278),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Pinput(
                        length: 6,
                        controller: pinController,
                        keyboardType: TextInputType.number,
                        animationCurve: Curves.easeInQuart,
                        animationDuration: const Duration(milliseconds: 300),
                        autofocus: true,
                        closeKeyboardWhenCompleted: true,
                        defaultPinTheme: PinTheme(
                          textStyle: const TextStyle(fontSize: 22),
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        onPressed: () {
                          final code = pinController.text.trim();
                          if (code.length == 6) {
                            context.read<VerifyCodeCubit>().verifyCode(
                              widget.email,
                              code,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter a 6-digit code"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        text: "Verify the code",
                        backgroundcolor: const Color(0xff26864E),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            context.read<VerifyCodeCubit>().resendCode(
                              widget.email,
                            );
                          },
                          child: const Text(
                            "Resend verification code",
                            style: TextStyle(
                              color: Color(0xff07AA59),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
