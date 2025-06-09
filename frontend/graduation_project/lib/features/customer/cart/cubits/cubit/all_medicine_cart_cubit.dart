import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repos/all_medicines_cart_repo.dart';

part 'all_medicine_cart_state.dart';

class AllMedicineCartCubit extends Cubit<AllMedicineCartState> {
  final AllMedicinesCartRepo repo;
  AllMedicineCartCubit(this.repo) : super(AllMedicineCartInitial());

  Future<void> fetchCartMedicines() async {
    emit(AllMedicineCartLoading());
    try {
      final medicines = await repo.fetchCartMedicines();
      if (medicines.isEmpty) {
        emit(AllMedicineCartEmpty());
      } else {
        emit(AllMedicineCartLoaded(medicines));
      }
    } catch (e) {
      emit(AllMedicineCartError(e.toString()));
    }
  }

  Future<void> deleteCartMedicine(int medicineId) async {
    try {
      await repo.deleteCartMedicine(medicineId);
      // بعد الحذف، أعد تحميل السلة
      await fetchCartMedicines();
    } catch (e) {
      emit(AllMedicineCartError(e.toString()));
    }
  }

  Future<String?> deleteAllCartMedicines() async {
    try {
      final message = await repo.deleteAllCartMedicines();
      await fetchCartMedicines();
      return message;
    } catch (e) {
      emit(AllMedicineCartError(e.toString()));
      return null;
    }
  }

  Future<void> updateCartMedicineQuantity(int medicineId, int quantity) async {
    try {
      await repo.updateCartMedicineQuantity(medicineId: medicineId, quantity: quantity);
      await fetchCartMedicines();
    } catch (e) {
      emit(AllMedicineCartError(e.toString()));
    }
  }
}
