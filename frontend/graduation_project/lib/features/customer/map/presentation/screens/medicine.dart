// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:graduation_project/features/admin/medicine/data/models/medicine_model.dart';
// import 'package:graduation_project/features/admin/medicine/data/repos/medicine_repo.dart';
// import 'package:graduation_project/features/customer/home/presentation/widgets/custom_card.dart';

// class MachineMedicinesCubit extends Cubit<List<MedicineModel>> {
//   final MedicineRepo repo;
//   MachineMedicinesCubit(this.repo) : super([]);

//   Future<void> fetchMachineMedicines(int machineId) async {
//     try {
//       final medicines = await repo.getMachineMedicines(machineId);
//       emit(medicines);
//     } catch (e) {
//       emit([]);
//     }
//   }
// }

// class MedicineGridScreen extends StatelessWidget {
//   final int id;
//   final String location;

//   const MedicineGridScreen({
//     Key? key,
//     required this.id,
//     required this.location,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => MachineMedicinesCubit(MedicineRepo())..fetchMachineMedicines(id),
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text('Machine at $location'),
//         ),
//         body: BlocBuilder<MachineMedicinesCubit, List<MedicineModel>>(
//           builder: (context, medicines) {
//             if (medicines.isEmpty) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             return Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: GridView.builder(
//                 itemCount: medicines.length,
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 10,
//                   mainAxisSpacing: 10,
//                   childAspectRatio: 0.78,
//                 ),
//                 itemBuilder: (context, index) {
//                   final medicine = medicines[index];
//                   return GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => ProductView(medicine: medicine),
//                         ),
//                       );
//                     },
//                     child: CustumCard(medicine: medicine),
//                   );
//                 },
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
