import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/constants/my_colors.dart';
import 'package:graduation_project/core/networking/dio_factory.dart';
import 'package:graduation_project/core/widgets/custem_button.dart';
import 'package:graduation_project/core/widgets/custom_text_field.dart';

import '../cubit/cubit/profile_update_cubit.dart';
import '../cubit/cubit/profile_update_state.dart';
import '../data/models/profile_update_model.dart';
import '../data/repos/profile_update_repo.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final currentPassController = TextEditingController();
  final newPassController = TextEditingController();
  final confirmPassController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    currentPassController.dispose();
    newPassController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  void _updateProfile(BuildContext context) async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final currentPass = currentPassController.text.trim();
    final newPass = newPassController.text.trim();
    final confirmPass = confirmPassController.text.trim();

    if (name.isEmpty &&
        email.isEmpty &&
        phone.isEmpty &&
        currentPass.isEmpty &&
        newPass.isEmpty &&
        confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your data'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newPass.isNotEmpty ||
        confirmPass.isNotEmpty ||
        currentPass.isNotEmpty) {
      if (currentPass.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Current password is required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (newPass.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('New password is required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (confirmPass.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please confirm your new password'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (newPass != confirmPass) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('New password and confirmation do not match'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final model = ProfileUpdateModel(
      customerName: name.isEmpty ? null : name,
      customerEmail: email.isEmpty ? null : email,
      customerPhone: phone.isEmpty ? null : phone,
      customerPass: newPass.isEmpty ? null : newPass,
      currentPassword: currentPass.isEmpty ? null : currentPass,
      age: null,
      imagePath: "",
    );

    context.read<ProfileUpdateCubit>().updateProfile(model);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DioFactory.getDio(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final repo = ProfileUpdateRepo(dio: snapshot.data!);
        return BlocProvider(
          create: (_) => ProfileUpdateCubit(repo),
          child: BlocListener<ProfileUpdateCubit, ProfileUpdateState>(
            listener: (context, state) {
              if (state is ProfileUpdateSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Profile updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is ProfileUpdateError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: SafeArea(
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Color(0xff26864E),
                  centerTitle: true,
                  elevation: 0,
                  title: Text(
                    "Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                body: Container(
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
                              SizedBox(height: 32),
                              Text(
                                "Personal Information",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 12),
                              CustomTextField(
                                hintText: "full name",
                                isPassword: false,
                                controller: nameController,
                                keyboardType: TextInputType.name,
                              ),
                              CustomTextField(
                                hintText: "email",
                                isPassword: false,
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              CustomTextField(
                                hintText: "phone number",
                                isPassword: false,
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                              ),
                              SizedBox(height: 24),
                              Text(
                                "Change Password",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 12),
                              CustomTextField(
                                hintText: "current password",
                                isPassword: true,
                                controller: currentPassController,
                                keyboardType: TextInputType.visiblePassword,
                              ),

                              CustomTextField(
                                hintText: "new password",
                                isPassword: true,
                                controller: newPassController,
                                keyboardType: TextInputType.visiblePassword,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return "Please enter password";
                                  }
                                  if (v.length < 8) {
                                    return "Password must be at least 8 characters long";
                                  }

                                  final hasUppercase = v.contains(
                                    RegExp(r'[A-Z]'),
                                  );
                                  final hasLowercase = v.contains(
                                    RegExp(r'[a-z]'),
                                  );
                                  final hasDigit = v.contains(RegExp(r'[0-9]'));
                                  final hasSpecialChar = v.contains(
                                    RegExp(
                                      r'[!@#\$&*~%^()\-_=+{}[\]|;:"<>,./?]',
                                    ),
                                  );

                                  if (!hasUppercase ||
                                      !hasLowercase ||
                                      !hasDigit ||
                                      !hasSpecialChar) {
                                    return "Password must contain uppercase, lowercase, digit, and special character";
                                  }

                                  return null;
                                },
                              ),

                              CustomTextField(
                                hintText: "confirm password",
                                isPassword: true,
                                controller: confirmPassController,
                                keyboardType: TextInputType.visiblePassword,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return "Please confirm your password";
                                  }
                                  if (v != newPassController.text) {
                                    return "Passwords do not match";
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 24),
                              BlocBuilder<
                                ProfileUpdateCubit,
                                ProfileUpdateState
                              >(
                                builder: (context, state) {
                                  return CustomButton(
                                    text:
                                        state is ProfileUpdateLoading
                                            ? " Updating..."
                                            : "Update Profile",
                                    backgroundcolor: Color(0xff26864E),
                                    onPressed:
                                        state is ProfileUpdateLoading
                                            ? null
                                            : () => _updateProfile(context),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
