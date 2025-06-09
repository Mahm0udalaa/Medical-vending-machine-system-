import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graduation_project/features/admin/medicine/data/models/medicine_model.dart';

class CustomCard extends StatefulWidget {
  final MedicineModel? medicine;
  const CustomCard({super.key, this.medicine});

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  bool isFavorite = false;
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    checkIfFavorite();
  }

  Future<void> checkIfFavorite() async {
  final customerId = await storage.read(key: 'id');
  final medicineId = widget.medicine?.medicineId;
  if (customerId == null || medicineId == null) return;

  final dio = Dio();
  try {
    final response = await dio.get(
      'https://your-api.com/api/FavoritesMedicine/check',
      queryParameters: {
        'customerId': customerId,
        'medicineId': medicineId,
      },
    );

    setState(() {
      isFavorite = response.data == true;
    });
  } catch (e) {
     
  }
}

Future<void> toggleFavorite() async {
  final customerId = await storage.read(key: 'id');
  final medicineId = widget.medicine?.medicineId;

  if (customerId == null || medicineId == null) return;

  final dio = Dio();

  try {
    await dio.post(
      'https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net/api/FavoritesMedicine',
      data: {
        'customerId': customerId,
        'medicineId': medicineId,
      },
    );

    setState(() {
      isFavorite = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("medicine added to favorites ❤️")),
    );
  } on DioException catch (e) {
    if (e.response?.statusCode == 409 &&
        e.response?.data['Message'] == 'Medicine already in favorites') {
      // إذا كان موجود، نحذفه
      try {
        await dio.delete(
          'https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net/api/FavoritesMedicine',
          queryParameters: {
            'customerId': customerId,
            'medicineId': medicineId,
          },
        );

        setState(() {
          isFavorite = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("medicine removed from favorites ❌")),
        );
      } catch (deleteError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("failed to remove favorite: $deleteError")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to toggle favorite status ❌")),
      );
    }
  }
}



  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: widget.medicine?.imagePath != null && widget.medicine!.imagePath!.isNotEmpty
                      ? Image.network(widget.medicine!.imagePath!, height: 80, width: 80, fit: BoxFit.cover)
                      : Image.asset("assets/med.png", height: 80, width: 80),
                ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: toggleFavorite,
                ),
              ],
            ),
            Text(
              "${widget.medicine?.medicinePrice ?? widget.medicine?.price ?? 0} EGP",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: const Color.fromARGB(255, 255, 0, 0),
              ),
            ),
            Row(
              children: [
                Text(
                  "Slot: ${widget.medicine?.slot ?? '-'}",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xff6C7278),
                  ),
                ),
                // SizedBox(width: 8),
                // Text(
                //   "ID: ${widget.medicine?.medicineId ?? '-'}",
                //   style: TextStyle(
                //     fontWeight: FontWeight.w500,
                //     fontSize: 14,
                //     color: const Color.fromARGB(255, 0, 38, 255),
                //   ),
                // ),
              ],
            ),
            Text(
              widget.medicine?.medicineName ?? '',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              "Quantity: ${widget.medicine?.quantity ?? '-'}",
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
