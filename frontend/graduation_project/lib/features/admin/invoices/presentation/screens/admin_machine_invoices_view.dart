import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/constants/my_colors.dart';
import 'package:graduation_project/features/admin/invoices/cubit/admin_machine_invoices_cubit.dart';
import 'package:graduation_project/features/admin/invoices/presentation/screens/admin_invoice_details_view.dart';
import 'package:graduation_project/features/admin/invoices/presentation/widgets/admin_invoice_card.dart';

class AdminMachineInvoicesView extends StatelessWidget {
  final int machineId;
  final String machineLocation;
  const AdminMachineInvoicesView({
    super.key,
    required this.machineId,
    required this.machineLocation,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminMachineInvoicesCubit()..fetchInvoices(machineId),
      child: Scaffold(
        appBar: AppBar(title: Text('Invoices for $machineLocation', style: const TextStyle(color: Colors.white)),
          backgroundColor: MyColors.primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: BlocBuilder<AdminMachineInvoicesCubit, AdminMachineInvoicesState>(
          builder: (context, state) {
            if (state is AdminMachineInvoicesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AdminMachineInvoicesError) {
              return Center(
                child: Text(state.message, style: TextStyle(color: Colors.red)),
              );
            } else if (state is AdminMachineInvoicesLoaded) {
              final invoices = state.invoices;
              if (invoices.isEmpty) {
                return const Center(child: Text('No invoices found for this machine.'));
              }
              return Container(
                padding: const EdgeInsets.symmetric( vertical: 20),
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomCenter,
                    colors: MyColors.backgroundColor,
                  ),
                ),
                child: ListView.builder(
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {
                    final invoice = invoices[index];
                    return AdminInvoiceCard(
                      numberOfOrders: invoice.items.length,
                      invoice: invoice,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    AdminInvoiceDetailsView(invoice: invoice),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
