import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class HistoryItem extends Equatable {
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

  @override
  List<Object?> get props => [id, type, title, amount, date, note, icon, color];
}

class HistoryState extends Equatable {
  final List<HistoryItem> items;
  final String selectedFilter;
  final bool isLoading;
  final String? errorMessage;

  const HistoryState({
    this.items = const [],
    this.selectedFilter = 'All',
    this.isLoading = true,
    this.errorMessage,
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
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return HistoryState(
      items: items ?? this.items,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [items, selectedFilter, isLoading, errorMessage];
}
