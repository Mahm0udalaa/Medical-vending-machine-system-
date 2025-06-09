import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/widgets/custom_text_field.dart';
import 'package:graduation_project/features/customer/settings/profile/cubit/cubit/profile_update_cubit.dart';
import 'package:graduation_project/features/customer/settings/profile/cubit/cubit/profile_update_state.dart';
import 'package:graduation_project/features/customer/settings/settings/presentation/screen/settings_view.dart';


class SearchHomeView extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  const SearchHomeView({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            hintText: "Search",
            isPassword: false,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 8),

        BlocBuilder<ProfileUpdateCubit, ProfileUpdateState>(
          builder: (context, state) {
            String imagePath = "assets/mahmod.png"; 
            if (state is ProfileUpdateWithImage && state.imagePath.isNotEmpty) {
              imagePath = state.imagePath;
            }

            return GestureDetector(
              child: CircleAvatar(child: Image.asset(imagePath, width: 50),),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsView(),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
