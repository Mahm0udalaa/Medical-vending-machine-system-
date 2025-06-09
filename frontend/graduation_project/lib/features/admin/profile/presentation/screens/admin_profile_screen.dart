import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/constants/my_colors.dart';
import 'package:graduation_project/core/widgets/custem_button.dart';
import 'package:graduation_project/core/widgets/custom_text_field.dart';
import 'package:graduation_project/features/admin/profile/cubit/cubit/admin_profile_state.dart';

import '../../cubit/cubit/admin_profile_cubit.dart';
import '../../data/models/admin_profile_model.dart';
import '../../data/repos/admin_profile_repo.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }


  String? nameValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }
    final isValid = RegExp(r'^[a-zA-Z0-9\u0600-\u06FF\s]+$').hasMatch(value.trim());
    if (!isValid) {
      return 'Name must contain only letters and numbers';
    }
    return null;
  }

  String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    final isValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim());
    if (!isValid) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter password";
    }
    if (value.length < 8) {
      return "Password must be at least 8 characters";
    }
    final hasUppercase = value.contains(RegExp(r'[A-Z]'));
    final hasLowercase = value.contains(RegExp(r'[a-z]'));
    final hasDigit = value.contains(RegExp(r'[0-9]'));
    final hasSpecial = value.contains(RegExp(r'[!@#\$&*~%^()\-_=+{}[\]|;:"<>,./?]'));
    if (!hasUppercase || !hasLowercase || !hasDigit || !hasSpecial) {
      return "Password must include upper, lower, digit, special char";
    }
    return null;
  }

  String? confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Please confirm your password";
    }
    if (value != newPasswordController.text) {
      return "Passwords do not match";
    }
    return null;
  }

  void onSubmit(BuildContext context) {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final currentPass = currentPasswordController.text.trim();
    final newPass = newPasswordController.text.trim();
    final confirmPass = confirmPasswordController.text.trim();

    if (name.isEmpty && email.isEmpty && currentPass.isEmpty && newPass.isEmpty && confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter the data you want to update."), 
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newPass.isNotEmpty || confirmPass.isNotEmpty || currentPass.isNotEmpty) {
      if (currentPass.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Current password is required."),
            backgroundColor: Colors.red,         ),
        );
        return;
      }
      if (newPass.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text( "New password is required."),
            backgroundColor: Colors.red,   
          ),
        );
        return;
      }
      if (confirmPass.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please confirm the new password."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (newPass != confirmPass) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text( "New password and confirmation do not match."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final model = AdminProfileModel(
      adminName: name.isEmpty ? null : name,
      adminEmail: email.isEmpty ? null : email,
      adminPass: newPass.isEmpty ? null : newPass,
      currentPassword: currentPass.isEmpty ? null : currentPass,
    );
    context.read<AdminProfileCubit>().updateProfile(model);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminProfileCubit(AdminProfileRepo()),
      child: BlocListener<AdminProfileCubit, AdminProfileState>(
        listener: (context, state) {
          if (state is AdminProfileSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          } else if (state is AdminProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xff26864E),
              centerTitle: true,
              elevation: 0,
              title: const Text(
                "Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 32),
                            const Text(
                              "Personal Information",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            CustomTextField(
                              hintText: "full name",
                              isPassword: false,
                              controller: nameController,
                              keyboardType: TextInputType.name,
                              validator: nameValidator,
                            ),
                            CustomTextField(
                              hintText: "email",
                              isPassword: false,
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: emailValidator,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              "Change Password",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            CustomTextField(
                              hintText: "current password",
                              isPassword: true,
                              controller: currentPasswordController,
                              keyboardType: TextInputType.visiblePassword,
                              validator: passwordValidator,
                            ),
                            CustomTextField(
                              hintText: "new password",
                              isPassword: true,
                              controller: newPasswordController,
                              keyboardType: TextInputType.visiblePassword,
                              validator: passwordValidator,
                            ),
                            CustomTextField(
                              hintText: "confirm password",
                              isPassword: true,
                              controller: confirmPasswordController,
                              keyboardType: TextInputType.visiblePassword,
                              validator: confirmPasswordValidator,
                            ),
                            const SizedBox(height: 24),
                            BlocBuilder<AdminProfileCubit, AdminProfileState>(
                              builder: (context, state) {
                                return CustomButton(
                                  text: state is AdminProfileLoading ? "Updating..." : "Update Profile",
                                  backgroundcolor: const Color(0xff26864E),
                                  onPressed: state is AdminProfileLoading ? null : () => onSubmit(context),
                                );
                              },
                            ),
                          ],
                        ),
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
  }
}
