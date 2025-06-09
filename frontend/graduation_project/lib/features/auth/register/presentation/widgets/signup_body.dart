import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/widgets/already_have_an_account.dart';
import 'package:graduation_project/core/widgets/custem_button.dart';
import 'package:graduation_project/core/widgets/custom_text_field.dart';
import 'package:graduation_project/features/auth/register/cubit/register_cubit.dart';
import 'package:graduation_project/features/auth/register/cubit/register_state.dart';
import 'package:graduation_project/features/auth/register/data/models/register_request.dart';
import 'package:graduation_project/features/auth/register/data/repos/register_repo.dart';
import 'package:graduation_project/features/customer/home/presentation/screens/home_view.dart';

class SignupBody extends StatefulWidget {
  const SignupBody({super.key});

  @override
  State<SignupBody> createState() => _SignupBodyState();
}

class _SignupBodyState extends State<SignupBody> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final ageController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterCubit(RegisterRepoImpl()),
      child: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );

            Future.delayed(const Duration(seconds: 2), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeView()),
              );
            });
          } else if (state is RegisterFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<RegisterCubit>();

          return CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 55.0),
                    child: Column(
                      children: [
                        const Text(
                          "Sign Up",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          child: Text(
                            "Create an account to continue!",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        CustomTextField(
                          keyboardType: TextInputType.name,
                          controller: usernameController,
                          hintText: "username",
                          icon: Icons.person,
                          isPassword: false,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "please enter your username";
                            }
                            if (v.length < 3) {
                              return "username must be at least 3 chars";
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          keyboardType: TextInputType.phone,
                          controller: phoneController,
                          hintText: "phone",
                          icon: Icons.phone,
                          isPassword: false,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "Please enter your phone number";
                            }
                            if (!RegExp(r'^01[0125][0-9]{8}$').hasMatch(v)) {
                              return "Invalid Egyptian phone number";
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          keyboardType: TextInputType.emailAddress,
                          controller: emailController,
                          hintText: "email",
                          icon: Icons.email,
                          isPassword: false,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "Please enter your email";
                            }
                            if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(v)) {
                              return "Invalid email address";
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          keyboardType: TextInputType.number,
                          controller: ageController,
                          hintText: "age",
                          icon: Icons.calendar_today,
                          isPassword: false,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "please enter your age";
                            }
                            final n = int.tryParse(v);
                            if (n == null || n < 10) return "age must be 10+";
                            return null;
                          },
                        ),
                        CustomTextField(
                          keyboardType: TextInputType.visiblePassword,
                          controller: passwordController,
                          hintText: "Password",
                          icon: Icons.lock,
                          isPassword: true,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "Please enter password";
                            }
                            if (v.length < 8) {
                              return "Password must be at least 8 characters long";
                            }
                            final hasUppercase = v.contains(RegExp(r'[A-Z]'));
                            final hasLowercase = v.contains(RegExp(r'[a-z]'));
                            final hasDigit = v.contains(RegExp(r'[0-9]'));
                            final hasSpecialChar =
                                v.contains(RegExp(r'[!@#\$&*~%^()\-_=+{}[\]|;:"<>,./?]'));

                            if (!hasUppercase || !hasLowercase || !hasDigit || !hasSpecialChar) {
                              return "Password must contain uppercase, lowercase, digit, and special character";
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          controller: confirmPasswordController,
                          hintText: "Confirm password",
                          isPassword: true,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "Please confirm your password";
                            }
                            if (v != passwordController.text) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        if (state is RegisterLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          CustomButton(
                            text: "Register",
                            backgroundcolor: const Color(0xff26864E),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                final model = RegisterRequestModel(
                                  username: usernameController.text,
                                  email: emailController.text,
                                  password: passwordController.text,
                                  phone: phoneController.text,
                                  age: int.parse(ageController.text),
                                  role: "Customer",
                                );
                                cubit.registerUser(model);
                              }
                            },
                          ),
                        const SizedBox(height: 40),
                        const AlreadyHaveAnAccount(),
                        const SizedBox(height: 20),
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
