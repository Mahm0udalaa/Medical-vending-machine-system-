import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/widgets/custem_button.dart';
import 'package:graduation_project/core/widgets/custom_text_field.dart';
import 'package:graduation_project/core/widgets/dont_have_account.dart';
import 'package:graduation_project/features/admin/admin_home/presentation/screens/admin_home_view.dart';
import 'package:graduation_project/features/auth/forget_password/presentation/screens/forgot_password_view.dart';
import 'package:graduation_project/features/auth/login/cubit/login_cubit.dart';
import 'package:graduation_project/features/auth/login/cubit/login_state.dart';
import 'package:graduation_project/features/auth/login/data/models/login_request_model.dart';
import 'package:graduation_project/features/customer/home/presentation/screens/home_view.dart';

class LoginBody extends StatefulWidget {
  const LoginBody({super.key});

  @override
  State<LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    final pattern = r'^[^@]+@[^@]+\.[^@]+';
    if (!RegExp(pattern).hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    if (value.length < 6) return 'Password must be at least 6 chars';
    return null;
  }

  void onLoginPressed(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      final loginModel = LoginRequestModel(
        email: emailController.text,
        password: passwordController.text,
      );
      context.read<LoginCubit>().login(loginModel);
    }
  }

  void navigateToRoleBasedScreen(String role) {
    switch (role) {
      case "Admin":
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => AdminHomeView()));
        break;
      case "Customer":
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => HomeView()));
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unknown role")),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text("Login successful"),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      navigateToRoleBasedScreen(state.response.role);
    });
  } else if (state is LoginFailure) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
        },
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 70.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        const Text(
                          "Log in to your Account",
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        CustomTextField(
                          controller: emailController,
                          hintText: "Email",
                          icon: Icons.email,
                          isPassword: false,
                          validator: validateEmail,
                        ),
                        CustomTextField(
                          controller: passwordController,
                          hintText: "Password",
                          icon: Icons.lock,
                          isPassword: true,
                          validator: validatePassword,
                        ),
                        const SizedBox(height: 24),
                         Row(
                           children: [
                            Spacer(),
                             GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => ForgotPasswordView()),
                                );
                              },
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: Color(0xff26864E),
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                  fontSize: 18,
                                ),
                              ),
                                                     ),
                           ],
                         ),

                        const SizedBox(height: 16),
                        state is LoginLoading
                            ? const CircularProgressIndicator()
                            : CustomButton(
                                text: "Log In",
                                backgroundcolor: const Color(0xff26864E),
                                onPressed: () => onLoginPressed(context),
                              ),
                        const SizedBox(height: 50),
                        
                       DontHaveAccount(),
                       
                      ],
                    ),
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
