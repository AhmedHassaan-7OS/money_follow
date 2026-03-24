import 'package:flutter/material.dart';
import 'package:money_follow/core/cubit/commitment/commitment_state.dart';

class CommitmentFilterChips extends StatelessWidget {
  const CommitmentFilterChips({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  final CommitmentFilter currentFilter;
  final ValueChanged<CommitmentFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _FilterChipItem(
          text: 'Pending',
          active: currentFilter == CommitmentFilter.pending,
          onTap: () => onFilterChanged(CommitmentFilter.pending),
        ),
        _FilterChipItem(
          text: 'Completed',
          active: currentFilter == CommitmentFilter.completed,
          onTap: () => onFilterChanged(CommitmentFilter.completed),
        ),
        _FilterChipItem(
          text: 'All',
          active: currentFilter == CommitmentFilter.all,
          onTap: () => onFilterChanged(CommitmentFilter.all),
        ),
      ],
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  const _FilterChipItem({
    required this.text,
    required this.active,
    required this.onTap,
  });

  final String text;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(text),
      selected: active,
      onSelected: (_) => onTap(),
    );
  }
}
