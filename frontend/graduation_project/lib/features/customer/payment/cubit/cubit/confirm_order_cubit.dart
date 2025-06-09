import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repos/confirm_order_repo.dart';
import 'package:graduation_project/features/customer/cart/data/models/all_medicines_cart_model.dart';

part 'confirm_order_state.dart';

class ConfirmOrderCubit extends Cubit<ConfirmOrderState> {
  final ConfirmOrderRepo repo;
  ConfirmOrderCubit(this.repo) : super(ConfirmOrderInitial());

  Future<void> moveMotorForMedicines(List<CartMedicineModel> medicines) async {
    emit(ConfirmOrderLoading());
    final result = await repo.moveMotorForMedicines(medicines);
    if (result['success'] == true) {
      emit(ConfirmOrderMotorSuccess(result['message']));
    } else {
      emit(ConfirmOrderMotorError(result['message']));
    }
  }

  Future<void> confirmOrder() async {
    emit(ConfirmOrderLoading());
    final result = await repo.confirmOrder();
    if (result['success'] == true) {
      emit(ConfirmOrderSuccess(result['message']));
    } else {
      emit(ConfirmOrderError(result['message']));
    }
  }

  Future<void> confirmOrderWithDispense(List<CartMedicineModel> medicines) async {
    emit(ConfirmOrderLoading());
    final dispenseResult = await repo.moveMotorForMedicines(medicines);
    if (dispenseResult['success'] == true) {
      final orderResult = await repo.confirmOrder();
      if (orderResult['success'] == true) {
        emit(ConfirmOrderSuccess(orderResult['message']));
      } else {
        emit(ConfirmOrderError(orderResult['message'] ?? 'Failed to confirm order.'));
      }
    } else {
      String errorMsg = dispenseResult['message'] ?? 'Failed to dispense some medicines.';
      if (dispenseResult['errors'] != null && dispenseResult['errors'].isNotEmpty) {
        errorMsg += '\n${dispenseResult['errors'].join('\n')}';
      }
      emit(ConfirmOrderMotorError(errorMsg));
    }
  }
}
