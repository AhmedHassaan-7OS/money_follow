import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_follow/core/constants/app_constants.dart'
    show AppConstants;
import 'package:money_follow/view/widgets/amount_input_field.dart'
    show AmountInputField;
import 'package:money_follow/view/widgets/app_card.dart' show AppCard;
import 'package:money_follow/view/widgets/app_snack_bar.dart' show AppSnackBar;
import 'package:money_follow/view/widgets/category_dropdown.dart'
    show CategoryDropdown;
import 'package:money_follow/view/widgets/date_picker_field.dart'
    show DatePickerField;
import 'package:money_follow/view/widgets/primary_button.dart'
    show PrimaryButton;
import 'package:money_follow/view/pages/category_selector_page.dart';
import 'package:money_follow/view/widgets/section_label.dart' show SectionLabel;
import 'package:money_follow/core/cubit/expense/expense_cubit.dart';
import 'package:money_follow/core/cubit/expense/expense_state.dart';
import 'package:money_follow/core/cubit/currency/currency_cubit.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';

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
    context.read<ExpenseCubit>().loadExpenses();
    _notesController.addListener(_onNotesChanged);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  void _onNotesChanged() {
    final text = _notesController.text;
    if (text.length <= 3) return;

    final cubit = context.read<ExpenseCubit>();
    final suggested = cubit.suggestCategory(text);
    final current = cubit.state;

    if (current is ExpenseLoaded &&
        current.selectedCategory == AppConstants.defaultExpenseCategory &&
        suggested != AppConstants.defaultExpenseCategory &&
        suggested != 'Other') {
      cubit.changeCategory(suggested);
      AppSnackBar.info(
        context,
        '💡 AI suggests: $suggested',
        action: SnackBarAction(
          label: AppLocalizations.of(context).undo,
          textColor: Colors.white,
          onPressed: () =>
              cubit.changeCategory(AppConstants.defaultExpenseCategory),
        ),
      );
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<ExpenseCubit>();
    final state = cubit.state;
    if (state is! ExpenseLoaded) return;

    String category = state.selectedCategory;
    if (state.isCustomCategory &&
        _customCategoryController.text.trim().isNotEmpty) {
      category = _customCategoryController.text.trim();
    }

    cubit.addExpense(
      amount: double.parse(_amountController.text),
      category: category,
      date: cubit.getFormattedDate(state.selectedDate),
      note: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
  }

  void _clearForm() {
    _amountController.clear();
    _notesController.clear();
    _customCategoryController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currency = context.read<CurrencyCubit>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: BlocConsumer<ExpenseCubit, ExpenseState>(
          listener: (context, state) {
            if (state is ExpenseSaved) {
              AppSnackBar.success(context, state.message);
              _clearForm();
            }
            if (state is ExpenseError) {
              AppSnackBar.error(context, state.message);
            }
          },
          builder: (context, state) {
            if (state is ExpenseLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryBlue),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Add ${l10n.expenses}',
                        style: AppTheme.getHeadingMedium(context),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SectionLabel(l10n.amount),
                    AmountInputField(
                      controller: _amountController,
                      currencySymbol: currency.state.currencySymbol,
                    ),
                    const SizedBox(height: 24),
                    SectionLabel(l10n.category),
                    CategoryDropdown(
                      value: state is ExpenseLoaded
                          ? state.selectedCategory
                          : AppConstants.defaultExpenseCategory,
                      onChanged: (v) async {
                        if (v == 'Other') {
                          final newCat = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CategorySelectorPage()),
                          );
                          if (newCat != null && newCat is String) {
                            if (context.mounted) context.read<ExpenseCubit>().changeCategory(newCat);
                          } else {
                            if (context.mounted) context.read<ExpenseCubit>().changeCategory(AppConstants.defaultExpenseCategory);
                          }
                        } else {
                          context.read<ExpenseCubit>().changeCategory(v);
                        }
                      },
                    ),
                    if (state is ExpenseLoaded && state.isCustomCategory) ...[
                      const SizedBox(height: 16),
                      AppCard(
                        border: Border.all(
                          color: AppTheme.primaryBlue.withOpacity(0.4),
                          width: 2,
                        ),
                        child: TextFormField(
                          controller: _customCategoryController,
                          decoration: InputDecoration(
                            hintText: 'Enter custom category...',
                            prefixIcon: const Icon(
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
                          validator: (v) {
                            if (state.isCustomCategory &&
                                (v == null || v.trim().isEmpty)) {
                              return 'Please enter a custom category';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SectionLabel(l10n.date),
                    DatePickerField(
                      selectedDate: state is ExpenseLoaded
                          ? state.selectedDate
                          : DateTime.now(),
                      onDateChanged: (d) =>
                          context.read<ExpenseCubit>().changeDate(d),
                    ),
                    const SizedBox(height: 24),
                    SectionLabel(l10n.notes),
                    AppCard(
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
                    const SizedBox(height: 32),
                    _AIInsightsCard(state: state),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: '${l10n.save} ${l10n.expenses}',
                      onPressed: _save,
                      isLoading: state is ExpenseSaving,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AIInsightsCard extends StatelessWidget {
  const _AIInsightsCard({required this.state});
  final ExpenseState state;

  @override
  Widget build(BuildContext context) {
    if (state is! ExpenseLoaded ||
        (state as ExpenseLoaded).expenses.isEmpty) {
      return const SizedBox.shrink();
    }
    final cubit = context.read<ExpenseCubit>();
    final insights = cubit.getSpendingInsights();
    final tips = cubit.getFinancialTips(3000);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withOpacity(0.08),
            AppTheme.accentGreen.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.psychology,
                color: AppTheme.primaryBlue, size: 20),
            const SizedBox(width: 8),
            Text('🤖 AI Insights',
                style: AppTheme.getHeadingSmall(context)
                    .copyWith(color: AppTheme.primaryBlue)),
          ]),
          const SizedBox(height: 12),
          ...insights.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• ${e.value}',
                    style: AppTheme.getBodyMedium(context)),
              )),
          if (tips.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('💡 Smart Tips:',
                style: AppTheme.getBodyMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentGreen)),
            const SizedBox(height: 4),
            ...tips.take(2).map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(tip, style: AppTheme.getBodySmall(context)),
                )),
          ],
        ],
      ),
    );
  }
}
