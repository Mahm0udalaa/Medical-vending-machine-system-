import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graduation_project/core/networking/api.service.dart';
import 'package:graduation_project/features/customer/settings/history/cubit/cubit/history_cubit.dart';
import 'package:graduation_project/features/customer/settings/history/data/repos/history_repo.dart';
import 'package:graduation_project/features/customer/settings/history/presentation/screens/history_screen.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  late final HistoryCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = HistoryCubit(
      HistoryRepo(
        dio: ApiService.dio,
        storage: const FlutterSecureStorage(),
      ),
    );
    _cubit.fetchHistory();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return 
       BlocProvider.value(
        value: _cubit,
        child: const HistoryScreen(),
      );
    
  }
}
