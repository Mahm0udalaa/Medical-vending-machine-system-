import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repos/cart_repo.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepo repo;
  CartCubit(this.repo) : super(CartInitial());

  Future<void> addToCart({
    required int machineId,
    required int medicineId,
    required int quantity,
  }) async {
    emit(CartLoading());
    try {
      final result = await repo.addToCart(
        machineId: machineId,
        medicineId: medicineId,
        quantity: quantity,
      );
      if (result['status'] == 'Success') {
        emit(CartSuccess(result));
      } else if (result['status'] == 'Error') {
        emit(CartError(result['message'] ?? 'Unknown error', result));
      } else {
        emit(CartError('Unknown response', result));
      }
    } catch (e) {
      emit(CartError(e.toString(), null));
    }
  }
} 