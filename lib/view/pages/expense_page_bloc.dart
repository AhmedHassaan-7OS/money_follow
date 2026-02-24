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
import 'package:money_follow/view/widgets/section_label.dart' show SectionLabel;
import 'package:provider/provider.dart';
import 'package:money_follow/bloc/expense/expense_bloc.dart';
import 'package:money_follow/bloc/expense/expense_event.dart';
import 'package:money_follow/bloc/expense/expense_state.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/providers/currency_provider.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';

/// ============================================================
/// ExpensePageBloc — صفحة إضافة المصاريف (النسخة النهائية).
///
/// هذا الملف يحل محل ملفين قديمين:
///   ❌ Expense_page.dart      (بيتحذف)
///   ❌ expense_page_bloc.dart (بيتحذف)
///
/// قبل الـ Refactor: ~394 + ~500 = ~894 سطر في ملفين.
/// بعد الـ Refactor:  ~200 سطر في ملف واحد.
///
/// SOLID:
///  • SRP : الصفحة مسئولة عن الـ UI فقط، الـ BLoC عن اللوجيك.
///  • DIP : تتعامل مع ExpenseBloc (abstraction) مش DB مباشرةً.
/// ============================================================
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
    context.read<ExpenseBloc>().add(LoadExpenses());
    _notesController.addListener(_onNotesChanged);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  // ─── AI Category Suggestion ───────────────────────────────────────────────

  void _onNotesChanged() {
    final text = _notesController.text;
    if (text.length <= 3) return;

    final bloc = context.read<ExpenseBloc>();
    final suggested = bloc.suggestCategoryFromDescription(text);
    final current = bloc.state;

    if (current is ExpenseLoaded &&
        current.selectedCategory == AppConstants.defaultExpenseCategory &&
        suggested != AppConstants.defaultExpenseCategory &&
        suggested != 'Other') {
      bloc.add(ChangeCategoryExpense(suggested));

      AppSnackBar.info(
        context,
        '💡 AI suggests: $suggested',
        action: SnackBarAction(
          label: AppLocalizations.of(context).undo,
          textColor: Colors.white,
          onPressed: () => bloc.add(
            ChangeCategoryExpense(AppConstants.defaultExpenseCategory),
          ),
        ),
      );
    }
  }

  // ─── Save ─────────────────────────────────────────────────────────────────

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final bloc = context.read<ExpenseBloc>();
    final state = bloc.state;
    if (state is! ExpenseLoaded) return;

    String category = state.selectedCategory;
    if (state.isCustomCategory &&
        _customCategoryController.text.trim().isNotEmpty) {
      category = _customCategoryController.text.trim();
    }

    bloc.add(
      AddExpense(
        amount: double.parse(_amountController.text),
        category: category,
        date: bloc.getFormattedDate(state.selectedDate),
        note: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      ),
    );
  }

  void _clearForm() {
    _amountController.clear();
    _notesController.clear();
    _customCategoryController.clear();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currency = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        child: BlocConsumer<ExpenseBloc, ExpenseState>(
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
                    // Header
                    Center(
                      child: Text(
                        'Add ${l10n.expenses}',
                        style: AppTheme.getHeadingMedium(context),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Amount
                    SectionLabel(l10n.amount),
                    AmountInputField(
                      controller: _amountController,
                      currencySymbol: currency.currencySymbol,
                    ),
                    const SizedBox(height: 24),

                    // Category
                    SectionLabel(l10n.category),
                    CategoryDropdown(
                      value: state is ExpenseLoaded
                          ? state.selectedCategory
                          : AppConstants.defaultExpenseCategory,
                      onChanged: (v) => context.read<ExpenseBloc>().add(
                        ChangeCategoryExpense(v),
                      ),
                    ),

                    // Custom category field
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

                    // Date
                    SectionLabel(l10n.date),
                    DatePickerField(
                      selectedDate: state is ExpenseLoaded
                          ? state.selectedDate
                          : DateTime.now(),
                      onDateChanged: (d) =>
                          context.read<ExpenseBloc>().add(ChangeDateExpense(d)),
                    ),
                    const SizedBox(height: 24),

                    // Notes
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

                    // AI Insights
                    _AIInsightsCard(state: state),
                    const SizedBox(height: 24),

                    // Save Button
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

// ─── Private Widget ────────────────────────────────────────────────────────

/// بطاقة AI Insights — مفصولة كـ widget (SRP).
class _AIInsightsCard extends StatelessWidget {
  const _AIInsightsCard({required this.state});

  final ExpenseState state;

  @override
  Widget build(BuildContext context) {
    if (state is! ExpenseLoaded || (state as ExpenseLoaded).expenses.isEmpty) {
      return const SizedBox.shrink();
    }

    final bloc = context.read<ExpenseBloc>();
    final insights = bloc.getSpendingInsights();
    final tips = bloc.getFinancialTips(3000);

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
          Row(
            children: [
              const Icon(
                Icons.psychology,
                color: AppTheme.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '🤖 AI Insights',
                style: AppTheme.getHeadingSmall(
                  context,
                ).copyWith(color: AppTheme.primaryBlue),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...insights.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• ${e.value}',
                style: AppTheme.getBodyMedium(context),
              ),
            ),
          ),
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
            ...tips
                .take(2)
                .map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(tip, style: AppTheme.getBodySmall(context)),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}
