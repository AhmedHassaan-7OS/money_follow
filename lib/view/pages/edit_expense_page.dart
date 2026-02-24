import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_follow/core/constants/app_constants.dart'
    show AppConstants;
import 'package:money_follow/repository/expense_repository.dart'
    show ExpenseRepository;
import 'package:money_follow/view/widgets/amount_input_field.dart'
    show AmountInputField;
import 'package:money_follow/view/widgets/app_card.dart' show AppCard;
import 'package:money_follow/view/widgets/app_snack_bar.dart' show AppSnackBar;
import 'package:money_follow/view/widgets/category_dropdown.dart'
    show CategoryDropdown;
import 'package:money_follow/view/widgets/confirm_delete_dialog.dart'
    show ConfirmDeleteDialog;
import 'package:money_follow/view/widgets/date_picker_field.dart'
    show DatePickerField;
import 'package:money_follow/view/widgets/primary_button.dart'
    show PrimaryButton;
import 'package:money_follow/view/widgets/section_label.dart' show SectionLabel;
import 'package:provider/provider.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/model/expense_model.dart';
import 'package:money_follow/providers/currency_provider.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';

/// ============================================================
/// EditExpensePage — صفحة تعديل/حذف مصروف.
///
/// قبل الـ Refactor: ~250 سطر (كود مكرر من الصفر).
/// بعد الـ Refactor:  ~120 سطر (يستخدم الـ Shared Widgets).
///
/// SOLID:
///  • SRP : بتتعامل بس مع الـ UI للتعديل — الـ DB عبر Repository.
///  • DIP : تعتمد على ExpenseRepository مش SqlControl مباشرةً.
/// ============================================================
class EditExpensePage extends StatefulWidget {
  const EditExpensePage({super.key, required this.expense, this.onUpdated});

  final ExpenseModel expense;
  final VoidCallback? onUpdated;

  @override
  State<EditExpensePage> createState() => _EditExpensePageState();
}

class _EditExpensePageState extends State<EditExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _repository = ExpenseRepository();

  late String _selectedCategory;
  late DateTime _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.expense.amount.toString();
    _notesController.text = widget.expense.note ?? '';
    _selectedCategory = widget.expense.category;
    _selectedDate = DateTime.parse(widget.expense.date);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final updated = ExpenseModel(
        id: widget.expense.id,
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        date: DateFormat(AppConstants.dbDateFormat).format(_selectedDate),
        note: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      await _repository.update(updated, widget.expense.id!);

      if (mounted) {
        AppSnackBar.success(
          context,
          AppLocalizations.of(context).expenseUpdatedSuccess,
        );
        widget.onUpdated?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(
          context,
          '${AppLocalizations.of(context).errorUpdatingExpense}: $e',
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await ConfirmDeleteDialog.show(
      context,
      title: '${l10n.delete} ${l10n.expenses}',
      message: l10n.deleteExpenseConfirm,
    );
    if (!confirmed) return;

    try {
      await _repository.delete(widget.expense.id!);
      if (mounted) {
        AppSnackBar.error(context, l10n.expenseDeletedSuccess);
        widget.onUpdated?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, '${l10n.errorDeletingExpense}: $e');
      }
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currency = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: _buildAppBar(l10n),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  value: _selectedCategory,
                  onChanged: (v) => setState(() => _selectedCategory = v),
                ),
                const SizedBox(height: 24),

                // Date
                SectionLabel(l10n.date),
                DatePickerField(
                  selectedDate: _selectedDate,
                  onDateChanged: (d) => setState(() => _selectedDate = d),
                  accentColor: AppTheme.primaryBlue,
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
                const SizedBox(height: 40),

                // Save Button
                PrimaryButton(
                  label: '${l10n.edit} ${l10n.expenses}',
                  onPressed: _update,
                  isLoading: _isSaving,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      backgroundColor: AppTheme.getBackgroundColor(context),
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back),
        color: AppTheme.getTextSecondary(context),
      ),
      title: Text(
        '${l10n.edit} ${l10n.expenses}',
        style: AppTheme.getHeadingMedium(context),
      ),
      actions: [
        IconButton(
          onPressed: _delete,
          icon: const Icon(Icons.delete_outline),
          color: AppTheme.errorColor,
        ),
      ],
    );
  }
}
