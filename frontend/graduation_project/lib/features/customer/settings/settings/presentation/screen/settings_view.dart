import 'package:flutter/material.dart';
import 'package:graduation_project/core/constants/my_colors.dart';
import 'package:graduation_project/features/customer/settings/settings/presentation/screen/settings_body.dart';


class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomCenter,
            colors: MyColors.backgroundColor,
          ),
        ),
        child: SettingsBody(),
      ),
    );
  }
}
