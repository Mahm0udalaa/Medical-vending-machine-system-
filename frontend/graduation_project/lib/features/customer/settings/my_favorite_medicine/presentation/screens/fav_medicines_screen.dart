import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graduation_project/core/networking/dio_factory.dart';
import 'package:graduation_project/features/customer/settings/my_favorite_medicine/cubit/cubit/fav_medicine_cubit.dart';
import 'package:graduation_project/features/customer/settings/my_favorite_medicine/data/models/fav_medicine_model.dart';
import 'package:graduation_project/features/customer/settings/my_favorite_medicine/data/repos/fav_medicine_repo.dart';
import 'package:graduation_project/features/customer/settings/my_favorite_medicine/presentation/widgets/fav_medicine_card.dart';

class MyFavoriteMedicineScreen extends StatelessWidget {
  const MyFavoriteMedicineScreen({super.key});

  Future<String?> getUserId() async {
    final storage = const FlutterSecureStorage();
    return await storage.read(key: 'id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        backgroundColor: Color(0xff26864E),
        centerTitle: true,
        elevation: 0,
        title: Text(
          "My Favorite Medicines",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder(
        future: DioFactory.getDio(),
        builder: (context, dioSnapshot) {
          if (!dioSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final repo = FavMedicineRepo(dio: dioSnapshot.data!);
          return BlocProvider(
            create: (_) => FavMedicineCubit(repo)..fetchFavMedicines(),
            child: BlocBuilder<FavMedicineCubit, FavMedicineState>(
              builder: (context, state) {
                if (state is FavMedicineLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is FavMedicineError) {
                  return Center(child: Text(state.message));
                } else if (state is FavMedicineEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 100,
                          color: Color(0xff26864E),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "No favorite medicines yet!",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is FavMedicineLoaded) {
                  final favs = state.favMedicines as List<FavMedicineModel>;
                  return ListView.builder(
                    itemCount: favs.length,
                    itemBuilder: (context, index) => FavMedicinecard(medicine: favs[index]),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }
}