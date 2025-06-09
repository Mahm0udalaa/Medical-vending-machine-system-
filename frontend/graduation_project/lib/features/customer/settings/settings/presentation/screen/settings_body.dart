import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/constants/my_colors.dart';
import 'package:graduation_project/features/auth/login/cubit/login_cubit.dart';
import 'package:graduation_project/features/auth/login/cubit/login_state.dart';
import 'package:graduation_project/features/auth/login/presentation/screens/login_view.dart';
import 'package:graduation_project/features/customer/settings/history/presentation/screens/history_view.dart';
import 'package:graduation_project/features/customer/settings/my_favorite_medicine/presentation/screens/fav_medicines_screen.dart';
import 'package:graduation_project/features/customer/settings/profile/cubit/cubit/profile_update_cubit.dart';
import 'package:graduation_project/features/customer/settings/profile/cubit/cubit/profile_update_state.dart';
import 'package:graduation_project/features/customer/settings/profile/presentation/profile_screen.dart';
import 'package:graduation_project/features/customer/settings/settings/cubit/cubit/delete_account_cubit.dart';
import 'package:graduation_project/features/customer/settings/settings/cubit/cubit/delete_account_state.dart';
import 'package:graduation_project/features/customer/settings/settings/presentation/widgets/custom_row_privacy_details.dart';

class SettingsBody extends StatefulWidget {
  const SettingsBody({super.key});

  @override
  State<SettingsBody> createState() => _SettingsBodyState();
}

class _SettingsBodyState extends State<SettingsBody> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state is LoginLoggedOut) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginView()),
                (route) => false,
              );
            }
          },
        ),
        BlocListener<DeleteAccountCubit, DeleteAccountState>(
          listener: (context, state) {
            if (state is DeleteAccountSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Account has been deleted successfully"),
                  backgroundColor: Colors.green,
                ),
              );
              context.read<LoginCubit>().logout();
            } else if (state is DeleteAccountError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff26864E),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Settings",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Container(
          width: double.infinity,
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      BlocBuilder<ProfileUpdateCubit, ProfileUpdateState>(
                        builder: (context, state) {
                          String imagePath = "assets/mahmod.png";

                          if (state is ProfileUpdateWithImage) {
                            if (state.imagePath.isNotEmpty) {
                              imagePath = state.imagePath;
                            }
                          }

                          return Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: 35,
                                backgroundImage: AssetImage(imagePath),
                              ),
                              Positioned(
                                bottom: -15,
                                child: IconButton(
                                  iconSize: 24,
                                  color: const Color(0xff1B5E37),
                                  onPressed: () {
                                    _showCenteredImageDialog(context, (
                                      selectedImage,
                                    ) {
                                      context
                                          .read<ProfileUpdateCubit>()
                                          .selectImage(selectedImage);
                                    });
                                  },
                                  icon: const Icon(Icons.camera_alt_outlined),
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 8),
                      const Text(
                        "ahmed shehata",
                        style: TextStyle(
                          color: Color(0xff131F46),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text(
                        "+20 1212186636",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff888FA0),
                        ),
                      ),
                      const SizedBox(height: 24),
                      CustomRowPrivacyDetails(
                        navigateView: const ProfileScreen(),
                        title: "MyProfile",
                      ),
                      const SizedBox(height: 24),
                      CustomRowPrivacyDetails(
                        navigateView: const MyFavoriteMedicineScreen(),
                        title: "My Favorite Medicines",
                      ),
                      const SizedBox(height: 24),
                      CustomRowPrivacyDetails(
                        navigateView: const HistoryView(),
                        title: "My History",
                      ),
                      const SizedBox(height: 48),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              logoutDialog(context);
                            },
                            child: const Text(
                              "LogOut",
                              style: TextStyle(
                                color: Color(0xffD97474),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              deleteAccountDialog(context);
                            },
                            child: const Text(
                              "Delete Account",
                              style: TextStyle(
                                color: Color(0xffD97474),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Eng.Spider",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.black,
                          decorationThickness: 1.0,
                        ),
                      ),
                      const Text(
                        "Version 1.0 April, 2025",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void deleteAccountDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Delete Account Dialog",
      barrierColor: Colors.black.withAlpha((0.3 * 255).toInt()), 
      pageBuilder: (context, animation, secondaryAnimation) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0), 
          child: Material(
            type: MaterialType.transparency,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Confirm Account Deletion",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "are you sure you want to delete your account? This action cannot be undone.",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              context
                                  .read<DeleteAccountCubit>()
                                  .deleteAccount();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[400],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('delete account'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void logoutDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Logout Dialog",
      barrierColor: Colors.black.withAlpha((0.3 * 255).toInt()),
      pageBuilder: (context, animation, secondaryAnimation) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
          child: Material(
            type: MaterialType.transparency,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "confirm logout",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "are you sure you want to logout? This action cannot be undone.",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.read<LoginCubit>().logout();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[400],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("logout"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCenteredImageDialog(
    BuildContext context,
    Function(String) onImageSelected,
  ) {
    final List<String> imagePaths = [
      "assets/child_image.png",
      "assets/madam_photo.png",
      "assets/person (1).png",
      "assets/person_photo.png",
      "assets/person_image.png",
    ];

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Choose Profile Image Dialog",
      barrierColor: Colors.black.withAlpha((0.3 * 255).toInt()),
      pageBuilder: (context, animation, secondaryAnimation) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
          child: Material(
            type: MaterialType.transparency,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Choose a Profile Image",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xff26864E),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      height: 280,
                      width: double.maxFinite,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1,
                            ),
                        itemCount: imagePaths.length,
                        itemBuilder: (context, index) {
                          final image = imagePaths[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                              onImageSelected(image);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(image, fit: BoxFit.cover),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
