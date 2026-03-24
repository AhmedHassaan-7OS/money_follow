import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/core/cubit/commitment_reminder/commitment_reminder_cubit.dart';
import 'package:money_follow/core/cubit/commitment_reminder/commitment_reminder_state.dart';
import 'package:money_follow/view/widgets/settings_toggle_tile.dart';
import 'package:money_follow/view/pages/settings/widgets/settings_layout_helpers.dart';

class CommitmentReminderSection extends StatelessWidget {
  const CommitmentReminderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Commitment Reminders'),
        BlocBuilder<CommitmentReminderCubit, CommitmentReminderState>(
          builder: (context, state) {
            if (state.isLoading) {
              return SettingsCard(
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            final cubit = context.read<CommitmentReminderCubit>();
            return SettingsCard(
              child: Column(
                children: [
                  SettingsToggleTile(
                    icon: Icons.notifications_active_outlined,
                    title: 'Remind before due date',
                    subtitle: 'Show notification before commitments are due',
                    value: state.enabled,
                    onChanged: (v) => cubit.toggleEnabled(v),
                  ),
                  const SettingsDivider(),
                  ListTile(
                    leading: const Icon(
                      Icons.schedule_outlined,
                      color: AppTheme.primaryBlue,
                    ),
                    title: const Text('Reminder time'),
                    subtitle: Text('${state.hoursBefore} hours before due date'),
                    trailing: DropdownButton<int>(
                      value: state.hoursBefore,
                      onChanged: state.enabled
                          ? (value) {
                              if (value != null) {
                                cubit.setHoursBefore(value);
                              }
                            }
                          : null,
                      items: [6, 12, 24, 48]
                          .map(
                            (hours) => DropdownMenuItem<int>(
                              value: hours,
                              child: Text('$hours h'),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
