import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/core/cubit/currency/currency_cubit.dart';
import 'package:money_follow/core/cubit/statistics/statistics_cubit.dart';
import 'package:money_follow/core/cubit/statistics/statistics_state.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';
import 'package:money_follow/utils/localization_extensions.dart';

class HistoryDateHeader extends StatelessWidget {
  const HistoryDateHeader({
    super.key,
    required this.dateText,
    required this.date,
  });

  final String dateText;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final currency = context.read<CurrencyCubit>();
    final l10n = AppLocalizations.of(context);
    final dateKey = DateFormat('yyyy-MM-dd').format(date);

    return BlocBuilder<StatisticsCubit, StatisticsState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateText,
                style: AppTheme.getHeadingSmall(context).copyWith(fontSize: 16),
              ),
              if (state is StatisticsLoaded &&
                  state.dailySummaries.containsKey(dateKey)) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (state.dailySummaries[dateKey]!['expense']! > 0) ...[
                      Icon(
                        Icons.arrow_downward,
                        size: 14,
                        color: AppTheme.errorColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.spentLabel(
                          currency.formatAmount(
                            state.dailySummaries[dateKey]!['expense']!,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (state.dailySummaries[dateKey]!['expense']! > 0 &&
                        state.dailySummaries[dateKey]!['income']! > 0)
                      const SizedBox(width: 16),
                    if (state.dailySummaries[dateKey]!['income']! > 0) ...[
                      Icon(
                        Icons.arrow_upward,
                        size: 14,
                        color: AppTheme.accentGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.earnedLabel(
                          currency.formatAmount(
                            state.dailySummaries[dateKey]!['income']!,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.accentGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
