import 'package:flutter/material.dart';

class HistoryItem {
  final String id;
  final String type;
  final String title;
  final double amount;
  final DateTime date;
  final String? note;
  final IconData icon;
  final Color color;

  const HistoryItem({
    required this.id,
    required this.type,
    required this.title,
    required this.amount,
    required this.date,
    this.note,
    required this.icon,
    required this.color,
  });
}

class HistoryState {
  final List<HistoryItem> items;
  final String selectedFilter;
  final bool isLoading;

  const HistoryState({
    this.items = const [],
    this.selectedFilter = 'All',
    this.isLoading = true,
  });

  List<HistoryItem> get filtered {
    if (selectedFilter == 'All') return items;
    const mapping = {
      'Income': 'Income',
      'Expenses': 'Expense',
      'Commitments': 'Commitment',
    };
    final type = mapping[selectedFilter];
    return items.where((i) => i.type == type).toList();
  }

  HistoryState copyWith({
    List<HistoryItem>? items,
    String? selectedFilter,
    bool? isLoading,
  }) {
    return HistoryState(
      items: items ?? this.items,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
