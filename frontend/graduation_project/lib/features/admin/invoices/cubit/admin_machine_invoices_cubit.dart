import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/admin/invoices/data/models/admin_invoice_model.dart';
import 'package:graduation_project/features/admin/invoices/data/repos/admin_machine_invoices_repo.dart';
import 'package:graduation_project/core/networking/api.service.dart';

abstract class AdminMachineInvoicesState {}
class AdminMachineInvoicesInitial extends AdminMachineInvoicesState {}
class AdminMachineInvoicesLoading extends AdminMachineInvoicesState {}
class AdminMachineInvoicesLoaded extends AdminMachineInvoicesState {
  final List<AdminInvoiceModel> invoices;
  AdminMachineInvoicesLoaded(this.invoices);
}
class AdminMachineInvoicesError extends AdminMachineInvoicesState {
  final String message;
  AdminMachineInvoicesError(this.message);
}

class AdminMachineInvoicesCubit extends Cubit<AdminMachineInvoicesState> {
  final AdminMachineInvoicesRepo repo;
  AdminMachineInvoicesCubit({AdminMachineInvoicesRepo? repo})
      : repo = repo ?? AdminMachineInvoicesRepo(ApiService.dio),
        super(AdminMachineInvoicesInitial());

  Future<void> fetchInvoices(int machineId) async {
    emit(AdminMachineInvoicesLoading());
    try {
      final invoices = await repo.fetchInvoices(machineId);
      emit(AdminMachineInvoicesLoaded(invoices));
    } catch (e) {
      emit(AdminMachineInvoicesError(e.toString()));
    }
  }
} 