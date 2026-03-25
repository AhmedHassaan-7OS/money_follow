import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/core/cubit/history/history_cubit.dart';
import 'package:money_follow/core/cubit/history/history_state.dart';
import 'package:money_follow/core/cubit/statistics/statistics_cubit.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';

import 'package:money_follow/view/widgets/history/history_header.dart';
import 'package:money_follow/view/widgets/history/history_filter_tabs.dart';
import 'package:money_follow/view/widgets/history/history_list_view.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<HistoryCubit>().loadHistory();
    context.read<StatisticsCubit>().loadStatistics();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: BlocBuilder<HistoryCubit, HistoryState>(
          builder: (context, state) {
            return Column(
              children: [
                HistoryHeader(itemCount: state.filtered.length, l10n: l10n),
                HistoryFilterTabs(
                  selectedFilter: state.selectedFilter,
                  onFilterSelected: (f) => context.read<HistoryCubit>().setFilter(f),
                ),
                const SizedBox(height: 16),
                Expanded(child: HistoryListView(state: state)),
              ],
            );
          },
        ),
      ),
    );
  }
}
