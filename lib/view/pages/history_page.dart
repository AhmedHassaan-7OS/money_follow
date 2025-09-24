import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/control/sqlcontrol.dart';
import 'package:money_follow/model/expense_model.dart';
import 'package:money_follow/model/income_model.dart';
import 'package:money_follow/providers/currency_provider.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';
import 'package:money_follow/model/commitment_model.dart';
import 'package:money_follow/view/pages/edit_income_page.dart';
import 'package:money_follow/view/pages/edit_expense_page.dart';
import 'package:money_follow/view/pages/edit_commitment_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final SqlControl _sqlControl = SqlControl();
  List<HistoryItem> historyItems = [];
  bool isLoading = true;
  String selectedFilter = 'All';

  final List<String> filterOptions = ['All', 'Income', 'Expenses', 'Commitments'];
  final Map<String, String> filterMapping = {
    'All': 'All',
    'Income': 'Income',
    'Expenses': 'Expense',
    'Commitments': 'Commitment',
  };

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<HistoryItem> items = [];

      // Load expenses
      final expenseData = await _sqlControl.getData('expenses');
      for (var expense in expenseData) {
        final expenseModel = ExpenseModel.fromMap(expense);
        items.add(HistoryItem(
          id: expenseModel.id.toString(),
          type: 'Expense',
          title: expenseModel.category,
          amount: -expenseModel.amount, // Negative for expenses
          date: DateTime.parse(expenseModel.date),
          note: expenseModel.note,
          icon: _getCategoryIcon(expenseModel.category),
          color: AppTheme.errorColor,
        ));
      }

      // Load income
      final incomeData = await _sqlControl.getData('incomes');
      for (var income in incomeData) {
        final incomeModel = IncomeModel.fromMap(income);
        items.add(HistoryItem(
          id: incomeModel.id.toString(),
          type: 'Income',
          title: incomeModel.source,
          amount: incomeModel.amount, // Positive for income
          date: DateTime.parse(incomeModel.date),
          note: null,
          icon: _getIncomeIcon(incomeModel.source),
          color: AppTheme.accentGreen,
        ));
      }

      // Load commitments
      final commitmentData = await _sqlControl.getData('commitments');
      for (var commitment in commitmentData) {
        final commitmentModel = CommitmentModel.fromMap(commitment);
        items.add(HistoryItem(
          id: commitmentModel.id.toString(),
          type: 'Commitment',
          title: commitmentModel.title,
          amount: -commitmentModel.amount, // Negative for commitments
          date: DateTime.parse(commitmentModel.dueDate),
          note: null,
          icon: _getCommitmentIcon(commitmentModel.title),
          color: AppTheme.warningColor,
        ));
      }

      // Sort by date (newest first)
      items.sort((a, b) => b.date.compareTo(a.date));

      setState(() {
        historyItems = items;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading history: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<HistoryItem> get filteredItems {
    if (selectedFilter == 'All') return historyItems;
    final actualType = filterMapping[selectedFilter];
    return historyItems.where((item) => item.type == actualType).toList();
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      case 'bills':
        return Icons.receipt;
      case 'healthcare':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      default:
        return Icons.category;
    }
  }

  IconData _getIncomeIcon(String source) {
    switch (source.toLowerCase()) {
      case 'salary':
        return Icons.work;
      case 'freelance':
        return Icons.laptop;
      case 'business':
        return Icons.business;
      case 'investment':
        return Icons.trending_up;
      case 'gift':
        return Icons.card_giftcard;
      case 'bonus':
        return Icons.star;
      default:
        return Icons.attach_money;
    }
  }

  IconData _getCommitmentIcon(String title) {
    final titleLower = title.toLowerCase();
    if (titleLower.contains('rent')) return Icons.home;
    if (titleLower.contains('electricity') || titleLower.contains('electric')) return Icons.flash_on;
    if (titleLower.contains('water')) return Icons.water_drop;
    if (titleLower.contains('internet') || titleLower.contains('wifi')) return Icons.wifi;
    if (titleLower.contains('phone') || titleLower.contains('mobile')) return Icons.phone;
    if (titleLower.contains('car') || titleLower.contains('loan')) return Icons.directions_car;
    if (titleLower.contains('insurance')) return Icons.security;
    if (titleLower.contains('gym') || titleLower.contains('fitness')) return Icons.fitness_center;
    return Icons.schedule;
  }

  Future<void> _navigateToEdit(HistoryItem item) async {
    Widget? editPage;
    
    switch (item.type) {
      case 'Income':
        final income = await _getIncomeById(item.id);
        if (income != null) {
          editPage = EditIncomePage(
            income: income,
            onUpdated: _loadHistory,
          );
        }
        break;
      case 'Expense':
        final expense = await _getExpenseById(item.id);
        if (expense != null) {
          editPage = EditExpensePage(
            expense: expense,
            onUpdated: _loadHistory,
          );
        }
        break;
      case 'Commitment':
        final commitment = await _getCommitmentById(item.id);
        if (commitment != null) {
          editPage = EditCommitmentPage(
            commitment: commitment,
            onUpdated: _loadHistory,
          );
        }
        break;
    }

    if (editPage != null && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => editPage!),
      );
    }
  }

  Future<IncomeModel?> _getIncomeById(String id) async {
    try {
      final data = await _sqlControl.getData('incomes');
      final targetId = int.parse(id);
      for (var item in data) {
        if (item['id'] == targetId) {
          return IncomeModel.fromMap(item);
        }
      }
    } catch (e) {
      print('Error getting income: $e');
    }
    return null;
  }

  Future<ExpenseModel?> _getExpenseById(String id) async {
    try {
      final data = await _sqlControl.getData('expenses');
      final targetId = int.parse(id);
      for (var item in data) {
        if (item['id'] == targetId) {
          return ExpenseModel.fromMap(item);
        }
      }
    } catch (e) {
      print('Error getting expense: $e');
    }
    return null;
  }

  Future<CommitmentModel?> _getCommitmentById(String id) async {
    try {
      final data = await _sqlControl.getData('commitments');
      final targetId = int.parse(id);
      for (var item in data) {
        if (item['id'] == targetId) {
          return CommitmentModel.fromMap(item);
        }
      }
    } catch (e) {
      print('Error getting commitment: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Transaction ${l10n.history}',
                    style: AppTheme.getHeadingMedium(context),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.getCardColor(context),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${filteredItems.length} items',
                      style: AppTheme.getBodyMedium(context),
                    ),
                  ),
                ],
              ),
            ),

            // Filter Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: filterOptions.map((filter) {
                  final isSelected = selectedFilter == filter;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedFilter = filter;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? AppTheme.primaryBlue 
                              : AppTheme.getCardColor(context),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ] : [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05
                              ),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          filter,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected 
                                ? Colors.white 
                                : AppTheme.getTextPrimary(context),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // History List
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryBlue,
                      ),
                    )
                  : filteredItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No transactions yet',
                                style: AppTheme.getHeadingSmall(context).copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start adding income, expenses, or commitments',
                                style: AppTheme.getBodyMedium(context),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadHistory,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              return _buildHistoryCard(item, index, currencyProvider);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(HistoryItem item, int index, CurrencyProvider currencyProvider) {
    final isToday = DateFormat('yyyy-MM-dd').format(item.date) == 
                   DateFormat('yyyy-MM-dd').format(DateTime.now());
    final isYesterday = DateFormat('yyyy-MM-dd').format(item.date) == 
                       DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 1)));
    
    String dateText;
    if (isToday) {
      dateText = 'Today';
    } else if (isYesterday) {
      dateText = 'Yesterday';
    } else {
      dateText = DateFormat('MMM dd, yyyy').format(item.date);
    }

    // Show date header if this is the first item or date changed
    bool showDateHeader = index == 0 || 
        DateFormat('yyyy-MM-dd').format(item.date) != 
        DateFormat('yyyy-MM-dd').format(filteredItems[index - 1].date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDateHeader) ...[
          if (index > 0) const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              dateText,
              style: AppTheme.getHeadingSmall(context).copyWith(
                fontSize: 16,
              ),
            ),
          ),
        ],
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05
                ),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: () => _navigateToEdit(item),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item.icon,
                      color: item.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: AppTheme.getBodyLarge(context),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: item.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.type,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: item.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('HH:mm').format(item.date),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.getTextSecondary(context),
                              ),
                            ),
                          ],
                        ),
                        if (item.note != null && item.note!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.getSurfaceColor(context),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.note,
                                  size: 14,
                                  color: AppTheme.getTextSecondary(context),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    item.note!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.getTextSecondary(context),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Amount and Edit Icon
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${item.amount >= 0 ? '+' : ''}${currencyProvider.formatAmount(item.amount.abs())}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: item.amount >= 0 ? AppTheme.accentGreen : AppTheme.errorColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: AppTheme.getTextSecondary(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class HistoryItem {
  final String id;
  final String type;
  final String title;
  final double amount;
  final DateTime date;
  final String? note;
  final IconData icon;
  final Color color;

  HistoryItem({
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
