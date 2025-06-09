import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/constants/my_colors.dart';
import 'package:graduation_project/features/customer/settings/history/cubit/cubit/history_cubit.dart';
import 'package:graduation_project/features/customer/settings/history/presentation/widgets/history_card.dart';

import 'order_details_history_view.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Your History",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                )),
            backgroundColor: Color(0xff1B5E37),
            centerTitle: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Container(
            width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomCenter,
              colors: MyColors.backgroundColor,
            ),
          ),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // CustomAppBar(screenTitle: "History"),
                        // const SizedBox(height: 32),
                        if (state is HistoryLoading)
                          const Center(child: CircularProgressIndicator()),
                        if (state is HistoryError)
                          Center(child: Text(state.message, style: const TextStyle(color: Colors.red))),
                        if (state is HistoryLoaded)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.history.length,
                            itemBuilder: (context, index) {
                              final order = state.history[index];
                              return HistoryCard(
                                image: "assets/order.png",
                                orderNumber: order.purchaseId.toString(),
                                date: order.purchaseDate.toString().split('T').first,
                                price: order.totalPrice.toString(),
                                numberOfOrders: order.items.length.toString(),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderDetailsHistoryView(
                                        items: order.items,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
