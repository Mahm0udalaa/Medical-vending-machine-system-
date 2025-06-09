import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/internet_connectivity_service.dart';
import 'package:graduation_project/core/internet_cubit.dart';
import 'package:graduation_project/core/networking/api.service.dart';
import 'package:graduation_project/features/auth/login/cubit/login_cubit.dart';
import 'package:graduation_project/features/auth/login/data/repos/login_repo.dart';
import 'package:graduation_project/features/auth/login/presentation/screens/login_view.dart';
import 'package:graduation_project/features/auth/register/presentation/screens/signup_view.dart';
import 'package:graduation_project/features/auth/splash/splash_screen.dart';
import 'package:graduation_project/features/customer/home/presentation/screens/home_view.dart';
import 'package:graduation_project/features/customer/settings/profile/cubit/cubit/profile_update_cubit.dart';
import 'package:graduation_project/features/customer/settings/profile/data/repos/profile_update_repo.dart';
import 'package:graduation_project/features/customer/settings/settings/cubit/cubit/delete_account_cubit.dart';
import 'package:graduation_project/features/customer/settings/settings/data/repos/delete_account_repo.dart';

void main() {
  final internetService = InternetConnectivityService();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<LoginCubit>(create: (context) => LoginCubit(LoginRepo())),
        BlocProvider<DeleteAccountCubit>(
          create:
              (_) => DeleteAccountCubit(DeleteAccountRepo(dio: ApiService.dio)),
        ),
        BlocProvider<ProfileUpdateCubit>(
          create:
              (_) => ProfileUpdateCubit(ProfileUpdateRepo(dio: ApiService.dio)),
        ),
        BlocProvider<InternetCubit>(
          create: (_) => InternetCubit(internetService),
        ),
        BlocProvider<InternetCubit>(
          create: (_) => InternetCubit(InternetConnectivityService()),
        ),
        // BlocProvider<ConfirmOrderCubit>(
        //   create: (_) => ConfirmOrderCubit(
        //     ConfirmOrderRepo(
        //       dio: Dio(),
        //       storage: const FlutterSecureStorage(),
        //     ),
        //   ),
        // ),
      ],
      child: const MedicalApp(),
    ),
  );
}

class MedicalApp extends StatelessWidget {
  const MedicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 👇 ده بيخلي الـ Widget بتاعت الانترنت تظهر على أي شاشة
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            BlocBuilder<InternetCubit, bool>(
              builder: (context, isConnected) {
                if (!isConnected) {
                  return buildNoInternetWidget();
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        );
      },

      // 👇 هنا شاشاتك الأساسية
      home: const SplashScreen(),
      routes: {
        '/login': (_) => const LoginView(),
        '/signup': (_) => const SignupView(),
        '/home': (_) => const HomeView(),
      },
    );
  }
}

  Widget buildNoInternetWidget() {
    return Center(
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Can\'t connect .. check internet',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.green, // تأكد إنها معرفة
                ),
              ),
            ),
            Image.asset('assets/no_internet.png'),
          ],
        ),
      ),
    );
  }

