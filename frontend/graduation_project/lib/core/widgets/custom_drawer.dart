// import 'dart:ui';

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:graduation_project/core/constants/drawer_item_model.dart';
// import 'package:graduation_project/core/constants/my_colors.dart';
// import 'package:graduation_project/features/auth/login/cubit/login_cubit.dart';
// import 'package:graduation_project/features/auth/login/cubit/login_state.dart';
// import 'package:graduation_project/features/auth/login/presentation/screens/login_view.dart';

// class CustomDrawer extends StatelessWidget {
//   const CustomDrawer({super.key});

//   static const List<DrawerItemModel> items = [
//     DrawerItemModel(title: 'Home', icon: Icons.home),
//     DrawerItemModel(title: 'Profile', icon: Icons.person),
//     DrawerItemModel(title: "Invoices", icon: FontAwesomeIcons.fileInvoice),
//     DrawerItemModel(title: 'Settings', icon: Icons.settings),
//   ];
//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<LoginCubit, LoginState>(
//           listener: (context, state) {
//             if (state is LoginLoggedOut) {
//               Navigator.of(context).pushAndRemoveUntil(
//                 MaterialPageRoute(builder: (_) => const LoginView()),
//                 (route) => false,
//               );
//             }
//           },
//       child: Drawer(
//         child: Container(
//           height: double.infinity,
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topRight,
//               end: Alignment.bottomCenter,
//               colors: MyColors.backgroundColor,
//             ),
//           ),
//           child: Column(
//             children: [
//               Spacer(),
//               ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: items.length,
//                 itemBuilder: (context, index) {
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 12.0),
//                     child: CustomDrawerItem(drawerItemModel: items[index]),
//                   );
//                 },
//               ),
//               Spacer(flex: 10),
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: TextButton(
//                   onPressed: () {
//                     logout_dialog(context);
//                   },
//                   child: Row(
//                     children: [
//                       Icon(Icons.logout, color: Colors.red, size: 30),
//                       SizedBox(width: 10),
//                       Text(
//                         "log out",
//                         style: TextStyle(fontSize: 24, color: Colors.red),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Spacer(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// void logout_dialog(BuildContext context) {
//   showGeneralDialog(
//     context: context,
//     barrierDismissible: true,
//     barrierLabel: "Logout Dialog",
//     barrierColor: Colors.black.withOpacity(0.3), // خلفية شفافة
//     pageBuilder: (context, animation, secondaryAnimation) {
//       return BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0), // تأثير ضبابي
//         child: Material(
//           type: MaterialType.transparency,
//           child: Center(
//             child: Container(
//               width: MediaQuery.of(context).size.width * 0.85,
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(24),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 20,
//                     offset: Offset(0, 10),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Text(
//                     'تأكيد تسجيل الخروج',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 20),
//                   const Text(
//                     'هل أنت متأكد أنك تريد تسجيل الخروج؟',
//                     style: TextStyle(fontSize: 14, color: Colors.black54),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 30),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () => Navigator.pop(context),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.grey[200],
//                             foregroundColor: Colors.black,
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: const Text('إلغاء'),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () {
//                             Navigator.of(context).pop();
//                             context.read<LoginCubit>().logout();
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.red[400],
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: const Text('تسجيل الخروج'),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }

// class CustomDrawerItem extends StatelessWidget {
//   const CustomDrawerItem({super.key, required this.drawerItemModel});
//   final DrawerItemModel drawerItemModel;
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       leading: Icon(
//         drawerItemModel.icon,
//         color: const Color.fromARGB(255, 48, 48, 48),
//       ),
//       title: FittedBox(
//         fit: BoxFit.scaleDown,
//         alignment: Alignment.centerLeft,
//         child: Text(
//           drawerItemModel.title,
//           style: const TextStyle(
//             fontWeight: FontWeight.w500,
//             fontSize: 24,
//             color: Color.fromARGB(255, 48, 48, 48),
//           ),
//         ),
//       ),
//     );
//   }
// }
