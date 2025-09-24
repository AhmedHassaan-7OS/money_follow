import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/control/sqlcontrol.dart';
import 'package:money_follow/model/expense_model.dart';
import 'package:money_follow/model/income_model.dart';
import 'package:money_follow/model/commitment_model.dart';
import 'package:money_follow/view/pages/settings_page.dart';
import 'package:money_follow/providers/currency_provider.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SqlControl _sqlControl = SqlControl();
  double totalBalance = 0.0;
  double monthlyExpenses = 0.0;
  List<ExpenseModel> expenses = [];
  List<CommitmentModel> commitments = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _calculateBalance();
    await _loadExpenses();
    await _loadCommitments();
    setState(() {});
  }

  Future<void> _calculateBalance() async {
    // Get all incomes
    final incomeData = await _sqlControl.getData('incomes');
    final incomes = incomeData.map((e) => IncomeModel.fromMap(e)).toList();
    
    // Get all expenses
    final expenseData = await _sqlControl.getData('expenses');
    final allExpenses = expenseData.map((e) => ExpenseModel.fromMap(e)).toList();
    
    double totalIncome = incomes.fold(0.0, (sum, income) => sum + income.amount);
    double totalExpense = allExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
    
    totalBalance = totalIncome - totalExpense;
    
    // Calculate this month's expenses
    final now = DateTime.now();
    final currentMonth = DateFormat('yyyy-MM').format(now);
    
    monthlyExpenses = allExpenses
        .where((expense) => expense.date.startsWith(currentMonth))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Future<void> _loadExpenses() async {
    final expenseData = await _sqlControl.getData('expenses');
    expenses = expenseData.map((e) => ExpenseModel.fromMap(e)).toList();
  }

  Future<void> _loadCommitments() async {
    final commitmentData = await _sqlControl.getData('commitments');
    commitments = commitmentData.map((e) => CommitmentModel.fromMap(e)).toList();
    
    // Sort by due date
    commitments.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  Map<String, double> _getExpensesByCategory() {
    Map<String, double> categoryTotals = {};
    
    for (var expense in expenses) {
      categoryTotals[expense.category] = 
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    
    return categoryTotals;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.overview,
                      style: AppTheme.getHeadingMedium(context),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.settings_outlined),
                      color: AppTheme.getTextSecondary(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Total Balance Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.totalBalance,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currencyProvider.formatAmount(totalBalance),
                        style: AppTheme.balanceText,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Monthly Expenses Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l10n.expenses} ${l10n.thisMonth}',
                        style: AppTheme.getBodyMedium(context),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currencyProvider.formatAmount(monthlyExpenses),
                        style: AppTheme.getHeadingMedium(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Expenses by Category
                if (expenses.isNotEmpty) ...[
                  Text(
                    '${l10n.expenses} by ${l10n.category}',
                    style: AppTheme.getHeadingSmall(context),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(16),
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
                    child: _buildExpenseChart(),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Upcoming Commitments
                Text(
                  '${l10n.upcoming} ${l10n.commitments}',
                  style: AppTheme.getHeadingSmall(context),
                ),
                const SizedBox(height: 16),
                
                if (commitments.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
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
                    child: Text(
                      l10n.noCommitmentsYet,
                      style: AppTheme.getBodyMedium(context),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  ...commitments.take(3).map((commitment) => _buildCommitmentCard(commitment, currencyProvider)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseChart() {
    final categoryData = _getExpensesByCategory();
    if (categoryData.isEmpty) return const SizedBox();
    final currencyProvider = Provider.of<CurrencyProvider>(context, listen: false);

    final colors = [
      AppTheme.primaryBlue,
      AppTheme.accentGreen,
      AppTheme.warningColor,
      AppTheme.errorColor,
      AppTheme.lightBlue,
    ];

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: categoryData.entries.map((entry) {
          final index = categoryData.keys.toList().indexOf(entry.key);
          return PieChartSectionData(
            color: colors[index % colors.length],
            value: entry.value,
            title: '${entry.key}\n${currencyProvider.currencySymbol}${entry.value.toStringAsFixed(0)}',
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCommitmentCard(CommitmentModel commitment, CurrencyProvider currencyProvider) {
    final dueDate = DateTime.tryParse(commitment.dueDate);
    final isOverdue = dueDate != null && dueDate.isBefore(DateTime.now());
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: isOverdue 
            ? Border.all(color: AppTheme.errorColor, width: 1)
            : null,
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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isOverdue 
                  ? AppTheme.errorColor.withOpacity(0.1)
                  : AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.schedule,
              color: isOverdue ? AppTheme.errorColor : AppTheme.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  commitment.title,
                  style: AppTheme.getBodyLarge(context),
                ),
                const SizedBox(height: 4),
                Text(
                  dueDate != null 
                      ? 'Due on ${DateFormat('MMM dd').format(dueDate)}'
                      : 'Due: ${commitment.dueDate}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isOverdue ? AppTheme.errorColor : AppTheme.getTextSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          Text(
            currencyProvider.formatAmount(commitment.amount),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isOverdue ? AppTheme.errorColor : AppTheme.getTextPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}
