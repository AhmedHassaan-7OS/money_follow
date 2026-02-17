import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:money_follow/bloc/expense/expense_bloc.dart';
import 'package:money_follow/bloc/expense/expense_event.dart';
import 'package:money_follow/bloc/expense/expense_state.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/providers/currency_provider.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';

/// Improved Expense Page using BLoC pattern
/// This page is now much cleaner with separated business logic
class ExpensePageBloc extends StatefulWidget {
  const ExpensePageBloc({super.key});

  @override
  State<ExpensePageBloc> createState() => _ExpensePageBlocState();
}

class _ExpensePageBlocState extends State<ExpensePageBloc> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _customCategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the BLoC with default values
    context.read<ExpenseBloc>().add(LoadExpenses());
    
    // Add listener to notes field for AI category suggestion
    _notesController.addListener(_onNotesChanged);
  }

  /// Handle notes change for AI category suggestion
  void _onNotesChanged() {
    final text = _notesController.text;
    if (text.length > 3) { // Only suggest after user types a few characters
      final l10n = AppLocalizations.of(context);
      final suggestedCategory = context.read<ExpenseBloc>().suggestCategoryFromDescription(text);
      final currentState = context.read<ExpenseBloc>().state;
      
      // Only auto-suggest if current category is still default and suggestion is different and not "Other"
      if (currentState is ExpenseLoaded && 
          currentState.selectedCategory == 'Food' && 
          suggestedCategory != 'Food' &&
          suggestedCategory != 'Other') { // Don't auto-change to "Other"
        context.read<ExpenseBloc>().add(ChangeCategoryExpense(suggestedCategory));
        
        // Show a subtle hint to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('💡 AI suggests: $suggestedCategory category'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.primaryBlue.withOpacity(0.8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            action: SnackBarAction(
              label: l10n.undo,
              textColor: Colors.white,
              onPressed: () {
                context.read<ExpenseBloc>().add(ChangeCategoryExpense('Food'));
              },
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  /// Save expense using BLoC
  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final bloc = context.read<ExpenseBloc>();
      final state = bloc.state;
      
      if (state is ExpenseLoaded) {
        String category = state.selectedCategory;
        
        // If "Other" is selected and custom category is provided, use it
        if (state.isCustomCategory && _customCategoryController.text.isNotEmpty) {
          category = _customCategoryController.text.trim();
        }

        bloc.add(AddExpense(
          amount: double.parse(_amountController.text),
          category: category,
          date: bloc.getFormattedDate(state.selectedDate),
          note: _notesController.text.isEmpty ? null : _notesController.text,
        ));
      }
    }
  }

  /// Select date using BLoC
  Future<void> _selectDate() async {
    final bloc = context.read<ExpenseBloc>();
    final state = bloc.state;
    
    if (state is ExpenseLoaded) {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: state.selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppTheme.primaryBlue,
                brightness: Theme.of(context).brightness,
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null && picked != state.selectedDate) {
        bloc.add(ChangeDateExpense(picked));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        child: BlocConsumer<ExpenseBloc, ExpenseState>(
          listener: (context, state) {
            // Handle state changes that require UI feedback
            if (state is ExpenseSaved) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.accentGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
              
              // Clear form after successful save
              _amountController.clear();
              _notesController.clear();
              _customCategoryController.clear();
            }
            
            if (state is ExpenseError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.errorColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ExpenseLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryBlue,
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Center(
                      child: Text(
                        'Add ${l10n.expenses}',
                        style: AppTheme.getHeadingMedium(context),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Amount Input
                    _buildAmountInput(l10n, currencyProvider),
                    const SizedBox(height: 24),

                    // Category Selection
                    _buildCategorySelection(l10n, state),
                    const SizedBox(height: 24),

                    // Date Selection
                    _buildDateSelection(l10n, state),
                    const SizedBox(height: 24),

                    // Notes Input
                    _buildNotesInput(l10n),
                    const SizedBox(height: 40),

                    // AI Insights Section
                    _buildAIInsights(state),
                    const SizedBox(height: 24),

                    // Save Button
                    _buildSaveButton(l10n, state),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build amount input field
  Widget _buildAmountInput(AppLocalizations l10n, CurrencyProvider currencyProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.amount, style: AppTheme.getHeadingSmall(context)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05,
                ),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimary(context),
            ),
            decoration: InputDecoration(
              hintText: '0.00',
              prefixIcon: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  currencyProvider.currencySymbol,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextSecondary(context),
                  ),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.all(20),
            ),
            validator: context.read<ExpenseBloc>().validateAmount,
          ),
        ),
      ],
    );
  }

  /// Build improved category selection with dark mode support
  Widget _buildCategorySelection(AppLocalizations l10n, ExpenseState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.category, style: AppTheme.getHeadingSmall(context)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[600]!
                  : Colors.grey[300]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05,
                ),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: state is ExpenseLoaded ? state.selectedCategory : 'Food',
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            dropdownColor: AppTheme.getCardColor(context),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: AppTheme.getTextSecondary(context),
            ),
            style: AppTheme.getBodyLarge(context),
            items: ExpenseBloc.categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getCategoryIcon(category),
                        size: 18,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(category),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                context.read<ExpenseBloc>().add(ChangeCategoryExpense(value));
              }
            },
          ),
        ),
        
        // Custom category input when "Other" is selected
        if (state is ExpenseLoaded && state.isCustomCategory) ...[
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.getCardColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryBlue.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: TextFormField(
              controller: _customCategoryController,
              decoration: InputDecoration(
                hintText: 'Enter custom category...',
                prefixIcon: Icon(
                  Icons.edit,
                  color: AppTheme.primaryBlue,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.all(16),
              ),
              validator: (value) {
                if (state.isCustomCategory && (value == null || value.trim().isEmpty)) {
                  return 'Please enter a custom category';
                }
                return null;
              },
            ),
          ),
        ],
      ],
    );
  }

  /// Build date selection
  Widget _buildDateSelection(AppLocalizations l10n, ExpenseState state) {
    final selectedDate = state is ExpenseLoaded ? state.selectedDate : DateTime.now();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.date, style: AppTheme.getHeadingSmall(context)),
        const SizedBox(height: 12),
        InkWell(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.getCardColor(context),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  DateFormat('MMM dd, yyyy').format(selectedDate),
                  style: AppTheme.getBodyLarge(context),
                ),
                const Spacer(),
                Icon(
                  Icons.keyboard_arrow_right,
                  color: AppTheme.getTextSecondary(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build notes input
  Widget _buildNotesInput(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.notes, style: AppTheme.getHeadingSmall(context)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05,
                ),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: l10n.addNote,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
      ],
    );
  }

  /// Build save button
  Widget _buildSaveButton(AppLocalizations l10n, ExpenseState state) {
    final isLoading = state is ExpenseSaving;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _saveExpense,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: AppTheme.primaryBlue.withOpacity(0.3),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                '${l10n.save} ${l10n.expenses}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  /// Build AI insights section
  Widget _buildAIInsights(ExpenseState state) {
    if (state is! ExpenseLoaded || state.expenses.isEmpty) {
      return const SizedBox.shrink();
    }

    final insights = context.read<ExpenseBloc>().getSpendingInsights();
    final tips = context.read<ExpenseBloc>().getFinancialTips(3000); // Default income for demo

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withOpacity(0.1),
            AppTheme.accentGreen.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: AppTheme.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '🤖 AI Insights',
                style: AppTheme.getHeadingSmall(context).copyWith(
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Spending insights
          ...insights.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '• ${entry.value}',
              style: AppTheme.getBodyMedium(context),
            ),
          )),
          
          if (tips.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '💡 Smart Tips:',
              style: AppTheme.getBodyMedium(context).copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.accentGreen,
              ),
            ),
            const SizedBox(height: 4),
            ...tips.take(2).map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                tip,
                style: AppTheme.getBodySmall(context),
              ),
            )),
          ],
        ],
      ),
    );
  }

  /// Get icon for category
  IconData _getCategoryIcon(String category) {
    const categoryIcons = {
      'Food': Icons.restaurant,
      'Transport': Icons.directions_car,
      'Shopping': Icons.shopping_bag,
      'Entertainment': Icons.movie,
      'Bills': Icons.receipt,
      'Healthcare': Icons.local_hospital,
      'Education': Icons.school,
      'Other': Icons.category,
    };
    return categoryIcons[category] ?? Icons.category;
  }
}
